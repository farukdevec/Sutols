"""Durable sequential model workflow. Schedules work; never fabricates model improvements.
SQLite transactions retain queue progress/outbox; canonical events.jsonl is append-only.
"""
import argparse, contextlib, datetime, fcntl, hashlib, json, os, sqlite3, sys, uuid
from pathlib import Path

PHASES={'pending_source','awaiting_access','awaiting_source_files','awaiting_identity','ready_for_inspection','awaiting_application_validation','blocked_integrity','done'}
def utc(): return datetime.datetime.now(datetime.timezone.utc).isoformat()
def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def atomic_json(path,value):
    tmp=path.with_name(path.name+'.tmp-'+uuid.uuid4().hex)
    with tmp.open('w') as f: json.dump(value,f,ensure_ascii=False,indent=2);f.write('\n');f.flush();os.fsync(f.fileno())
    os.replace(tmp,path)

class Queue:
    def __init__(self,root):
        self.root=Path(root).resolve();self.base=self.root/'model-improvements';self.base.mkdir(exist_ok=True)
        self.lock=(self.base/'.queue.lock').open('a+')
        try: fcntl.flock(self.lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        except BlockingIOError: self.lock.close();raise RuntimeError('Another queue writer holds the lock')
        self.db=sqlite3.connect(self.base/'queue.sqlite3');self.db.row_factory=sqlite3.Row
        self.db.execute('PRAGMA synchronous=FULL')
        self.db.executescript('CREATE TABLE IF NOT EXISTS items(record_key TEXT PRIMARY KEY, ordinal INTEGER UNIQUE, candidate TEXT NOT NULL, phase TEXT NOT NULL, next_action TEXT NOT NULL, attempts INTEGER NOT NULL DEFAULT 0, evidence TEXT NOT NULL DEFAULT "[]", updated_at TEXT NOT NULL); CREATE TABLE IF NOT EXISTS outbox(event_id TEXT PRIMARY KEY, payload TEXT NOT NULL, flushed INTEGER NOT NULL DEFAULT 0); CREATE TABLE IF NOT EXISTS meta(key TEXT PRIMARY KEY,value TEXT NOT NULL);')
        self.flush()
    def close(self): self.flush();self.db.close();fcntl.flock(self.lock,fcntl.LOCK_UN);self.lock.close()
    def record(self,key):
        p=self.base/'records'/f'{key}.json';return json.loads(p.read_text()) if p.exists() else None
    def log(self,key,action,evidence=None):
        r=self.record(key) if key else None
        e={'timestamp':utc(),'eventId':'queue-'+uuid.uuid4().hex,'recordKey':key,'modelId':r.get('modelId') if r else None,'fromStatus':r.get('status') if r else None,'toStatus':r.get('status') if r else None,'baseRevision':r.get('baseRevision') if r else None,'revision':r.get('candidateRevision') if r else None,'inputSha256':r.get('sourceSha256') if r else None,'outputSha256':r.get('outputSha256') if r else None,'action':action,'evidencePaths':evidence or [],'nextAction':action,'scope':'queue_scheduling_not_model_validation'}
        self.db.execute('INSERT INTO outbox(event_id,payload) VALUES(?,?)',(e['eventId'],json.dumps(e,ensure_ascii=False)))
    def flush(self):
        pending=self.db.execute('SELECT event_id,payload FROM outbox WHERE flushed=0 ORDER BY rowid').fetchall()
        if not pending:return
        path=self.base/'events.jsonl';seen=set()
        if path.exists():
            raw=path.read_bytes()
            if raw and not raw.endswith(b'\n'):raise RuntimeError('Incomplete event-log tail; preserve it and repair explicitly before resuming')
            for line in raw.splitlines():seen.add(json.loads(line)['eventId'])
        with path.open('a') as f:
            for row in pending:
                if row['event_id'] not in seen:f.write(row['payload']+'\n');seen.add(row['event_id'])
            f.flush();os.fsync(f.fileno())
        with self.db:self.db.executemany('UPDATE outbox SET flushed=1 WHERE event_id=?',[(r['event_id'],) for r in pending])
    def initialize(self):
        inv=json.loads((self.base/'inventory.json').read_text());items=inv['models']
        assert len({m['recordKey'] for m in items})==len(items)
        pilots=['Ambulans','helikopter_rotor_sistemi','elektrik_motoru_kesiti','otomobil_parcalari_motor_sistemi','kalp_dolasim_sistemi','anitkabir']
        ordered=sorted(enumerate(items),key=lambda v:(pilots.index(v[1]['candidateId']) if v[1]['candidateId'] in pilots else len(pilots),v[0]))
        with self.db:
            ordinal=self.db.execute('SELECT COALESCE(MAX(ordinal),-1)+1 FROM items').fetchone()[0];added=0
            for _,m in ordered:
                if self.db.execute('SELECT 1 FROM items WHERE record_key=?',(m['recordKey'],)).fetchone():continue
                r=self.record(m['recordKey']);status=r.get('status') if r else 'pending'
                phase='awaiting_application_validation' if status in ('candidate','validated') else 'done' if status=='published' else 'awaiting_access' if status=='blocked' else 'pending_source'
                action=r.get('nextAction') if r else 'Verify live identity/object key and acquire source; inspect individually before modifying.'
                self.db.execute('INSERT INTO items(record_key,ordinal,candidate,phase,next_action,updated_at) VALUES(?,?,?,?,?,?)',(m['recordKey'],ordinal,json.dumps(m,ensure_ascii=False),phase,action or 'Review existing record',utc()));ordinal+=1;added+=1
            if added:self.log(None,f'Added {added} candidates to durable queue. Existing model revisions preserved; this is not completed model work.',['model-improvements/inventory.json','model-improvements/queue.sqlite3'])
        self.flush();return added
    def set_phase(self,key,phase,action,evidence,attempt=False):
        if phase not in PHASES:raise ValueError('Unsupported phase')
        for name in evidence:
            resolved=(self.root/name).resolve()
            if not resolved.is_relative_to(self.root) or not resolved.exists():raise ValueError('Evidence path must exist inside project: '+name)
        old=self.db.execute('SELECT * FROM items WHERE record_key=?',(key,)).fetchone()
        if not old:raise KeyError(key)
        if old['phase']=='done' and phase not in ('done','blocked_integrity'):raise ValueError('Published model needs an explicitly recorded new revision before reopening')
        if phase=='done' and (not self.record(key) or self.record(key)['status']!='published'):raise ValueError('Queue cannot mark an unpublished model done')
        with self.db:
            self.db.execute('UPDATE items SET phase=?,next_action=?,evidence=?,attempts=attempts+?,updated_at=? WHERE record_key=?',(phase,action,json.dumps(evidence),int(attempt),utc(),key))
            self.log(key,f"Queue phase {old['phase']} -> {phase}: {action}",evidence)
            self.db.execute('INSERT OR REPLACE INTO meta VALUES(?,?)',('lastRecordKey',key))
        self.flush()
    def verify_artifacts(self):
        failures=[]
        for row in self.db.execute('SELECT record_key FROM items').fetchall():
            r=self.record(row['record_key'])
            if not r or r.get('status') not in ('candidate','validated','published'):continue
            path=r.get('localCandidatePath');expected=r.get('outputSha256')
            if path and expected and (not (self.root/path).is_file() or digest(self.root/path)!=expected):
                failures.append(row['record_key']);self.set_phase(row['record_key'],'blocked_integrity','Candidate hash differs or file is missing. Do not regenerate from old source; reconcile recorded revision.',['model-improvements/records/'+row['record_key']+'.json'])
        return failures
    def snapshot(self):
        rows=self.db.execute('SELECT * FROM items ORDER BY ordinal').fetchall();counts={}
        for r in rows:counts[r['phase']]=counts.get(r['phase'],0)+1
        s={'schemaVersion':1,'updatedAt':utc(),'candidateCount':len(rows),'liveUniqueModelCount':None,'counts':counts,'queueDatabase':'model-improvements/queue.sqlite3','completionAuthority':'records/*.json; queue phase is not model validation','nextRunnable':[{'recordKey':r['record_key'],'name':json.loads(r['candidate'])['name'],'phase':r['phase'],'nextAction':r['next_action']} for r in rows if r['phase'] in ('ready_for_inspection','awaiting_identity','pending_source')][:10],'lastRecordKey':self.db.execute("SELECT value FROM meta WHERE key='lastRecordKey'").fetchone(),'items':[{'recordKey':r['record_key'],'ordinal':r['ordinal'],'candidateId':json.loads(r['candidate'])['candidateId'],'phase':r['phase'],'attempts':r['attempts'],'nextAction':r['next_action'],'evidencePaths':json.loads(r['evidence']), 'modelId':(self.record(r['record_key']) or {}).get('modelId'), 'baseRevision':(self.record(r['record_key']) or {}).get('baseRevision'), 'candidateRevision':(self.record(r['record_key']) or {}).get('candidateRevision'), 'sourceSha256':(self.record(r['record_key']) or {}).get('sourceSha256'), 'outputSha256':(self.record(r['record_key']) or {}).get('outputSha256')} for r in rows]}
        if s['lastRecordKey']:s['lastRecordKey']=s['lastRecordKey'][0]
        atomic_json(self.base/'checkpoint.json',s);return {k:v for k,v in s.items() if k!='items'}
    def defer_domain(self,domain,evidence):
        from urllib.parse import urlparse
        count=0
        for row in self.db.execute("SELECT * FROM items WHERE phase='pending_source' ORDER BY ordinal").fetchall():
            m=json.loads(row['candidate']);source=m.get('sourceObjectKey') or ''
            host=urlparse(source).hostname if '://' in source else 'assets.sutols.com' if not source.startswith(('/','assets/')) else None
            if host==domain:
                self.set_phase(row['record_key'],'awaiting_access','Shared domain authentication prerequisite failed. This individual asset was NOT requested or inspected. Resume after authorized access is configured.',evidence);count+=1
        return count

def main():
    p=argparse.ArgumentParser();p.add_argument('--root',default=str(Path(__file__).resolve().parents[2]));sub=p.add_subparsers(dest='cmd',required=True)
    for name in ['init','status','verify','next']:sub.add_parser(name)
    s=sub.add_parser('checkpoint');s.add_argument('record_key');s.add_argument('phase',choices=sorted(PHASES));s.add_argument('--next-action',required=True);s.add_argument('--evidence',nargs='+',required=True)
    s=sub.add_parser('defer-domain');s.add_argument('domain');s.add_argument('--evidence',nargs='+',required=True)
    args=p.parse_args();q=Queue(args.root)
    try:
        if args.cmd=='init':q.initialize()
        elif args.cmd in ('verify','next'):print(json.dumps({'integrityFailures':q.verify_artifacts()}))
        elif args.cmd=='checkpoint':q.set_phase(args.record_key,args.phase,args.next_action,args.evidence,attempt=True)
        elif args.cmd=='defer-domain':print(json.dumps({'deferredUnprobed':q.defer_domain(args.domain,args.evidence)}))
        print(json.dumps(q.snapshot(),ensure_ascii=False,indent=2))
    finally:q.close()
if __name__=='__main__':main()
