import json,tempfile,unittest
from pathlib import Path
from work_queue import Queue,digest

class QueueTests(unittest.TestCase):
    def setUp(self):
        self.tmp=tempfile.TemporaryDirectory();self.root=Path(self.tmp.name);b=self.root/'model-improvements';(b/'records').mkdir(parents=True)
        (b/'inventory.json').write_text(json.dumps({'models':[{'recordKey':'a','candidateId':'Ambulans','sourceObjectKey':'Ambulans.glb','name':'Ambulans'},{'recordKey':'b','candidateId':'anitkabir','sourceObjectKey':'/models/anitkabir.glb','name':'Anıtkabir'}]}))
        (self.root/'candidate.glb').write_bytes(b'verified-fixture')
        (b/'records/b.json').write_text(json.dumps({'status':'candidate','modelId':'anitkabir','baseRevision':'baseline','candidateRevision':'r1','localCandidatePath':'candidate.glb','outputSha256':digest(self.root/'candidate.glb'),'nextAction':'App validation'}))
        (b/'access.json').write_text('{}');self.q=Queue(self.root)
    def tearDown(self):self.q.close();self.tmp.cleanup()
    def test_init_idempotent_and_candidate_not_restarted(self):
        self.assertEqual(self.q.initialize(),2);self.assertEqual(self.q.initialize(),0)
        self.assertEqual(self.q.snapshot()['counts'],{'pending_source':1,'awaiting_application_validation':1})
    def test_recover_outbox_after_commit_before_export(self):
        self.q.initialize()
        with self.q.db:self.q.log('a','crash-recovery-test')
        self.assertEqual(self.q.db.execute('SELECT COUNT(*) FROM outbox WHERE flushed=0').fetchone()[0],1)
        self.q.flush();lines=(self.q.base/'events.jsonl').read_text().splitlines()
        # Simulate interruption after log fsync but before marking the outbox flushed.
        with self.q.db:self.q.db.execute('UPDATE outbox SET flushed=0')
        self.q.flush();self.assertEqual((self.q.base/'events.jsonl').read_text().splitlines(),lines)
    def test_lock_excludes_second_writer(self):
        with self.assertRaises(RuntimeError):Queue(self.root)
    def test_hash_mismatch_prevents_resume(self):
        self.q.initialize();self.assertEqual(self.q.verify_artifacts(),[])
        (self.root/'candidate.glb').write_bytes(b'changed')
        self.assertEqual(self.q.verify_artifacts(),['b']);self.assertEqual(self.q.snapshot()['counts']['blocked_integrity'],1)
    def test_unpublished_cannot_be_done(self):
        self.q.initialize()
        with self.assertRaises(ValueError):self.q.set_phase('b','done','fake complete',['model-improvements/access.json'])
    def test_shared_auth_defer_does_not_claim_individual_probe(self):
        self.q.initialize();self.assertEqual(self.q.defer_domain('assets.sutols.com',['model-improvements/access.json']),1)
        row=self.q.db.execute("SELECT * FROM items WHERE record_key='a'").fetchone();self.assertEqual(row['attempts'],0);self.assertIn('NOT requested',row['next_action'])
    def test_snapshot_and_events_survive_reopen(self):
        self.q.initialize();self.q.set_phase('a','awaiting_access','403',['model-improvements/access.json'],attempt=True);before=self.q.snapshot();self.q.close();self.q=Queue(self.root);after=self.q.snapshot();self.assertEqual(before['counts'],after['counts']);self.assertEqual(after['lastRecordKey'],'a')
    def test_transaction_rollback_leaves_no_false_event(self):
        self.q.initialize();n=self.q.db.execute('SELECT COUNT(*) FROM outbox').fetchone()[0]
        try:
            with self.q.db:
                self.q.log('a','must rollback');raise RuntimeError('simulated crash before commit')
        except RuntimeError:pass
        self.assertEqual(self.q.db.execute('SELECT COUNT(*) FROM outbox').fetchone()[0],n)
if __name__=='__main__':unittest.main()
