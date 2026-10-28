"""Prepare reviewable queries; draft labels are never reported as human truth."""
import argparse
import csv
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
FIELDS = ('id', 'split', 'group', 'language', 'mode', 'kind', 'query',
          'relevant_ids', 'expected_none', 'review_status', 'reviewer', 'notes')


def split(group):
    return 'evaluation' if int(hashlib.sha256(group.encode()).hexdigest()[:8], 16) % 5 == 0 else 'development'


def draft(path):
    models = json.loads((ROOT / 'web/models/original-v1/manifest.json').read_text())
    rows = []
    for model in models:
        key = model['id'].removeprefix('sutols-')
        english = model.get('labelEn', key.replace('-', ' '))
        # A typo is a candidate test, not a guarantee of semantic relevance.
        parts = english.split()
        longest = max(range(len(parts)), key=lambda i: len(parts[i]))
        word = parts[longest]
        if len(word) >= 5:
            offset = next((i for i in range(1, len(word) - 1)
                           if word[i] != word[i + 1]), None)
            parts[longest] = (word[:offset] + word[offset + 1] + word[offset]
                             + word[offset + 2:]) if offset is not None else word[:-1]
        else:
            parts[longest] = word + 'x'
        variants = [('tr', 'manual', 'exact_name', model['label']),
                    ('en', 'manual', 'english_name', english),
                    ('tr', 'automatic', 'slide_context', model['label'] + ' hakkında bir açıklama'),
                    ('en', 'manual', 'typo', ' '.join(parts))]
        for index, (language, mode, kind, query) in enumerate(variants):
            rows.append(dict(zip(FIELDS, (f'{key}-{index}', split(key), key, language,
                mode, kind, query, model['id'], 'false', 'draft', '',
                'Agent-authored candidate; validate language, intent and every relevant model.'))))
    controls = [('tr', 'ambiguous', q) for q in ('çekirdek', 'hücre', 'ağ', 'kök', 'enerji', 'sistem', 'gelişim', 'yapı', 'güç', 'döngü')]
    controls += [('en', 'ambiguous', q) for q in ('core', 'cell', 'network', 'root', 'energy', 'system', 'development', 'structure', 'power', 'cycle')]
    controls += [('tr', 'out_of_domain', q) for q in ('mahkeme dilekçesi', 'iş başvurusu', 'tatil bütçesi', 'kira sözleşmesi', 'şiir eleştirisi', 'marka stratejisi', 'dil bilgisi', 'toplantı notları', 'müşteri anketi', 'zaman yönetimi')]
    controls += [('en', 'out_of_domain', q) for q in ('legal petition', 'job application', 'holiday budget', 'rental agreement', 'poetry criticism', 'brand strategy', 'grammar rules', 'meeting minutes', 'customer survey', 'time management')]
    controls += [('tr', 'missing_asset', q) for q in ('kahve değirmeni', 'ahtapot anatomisi', 'kemancı', 'arkeolojik kazı', 'meteoroloji balonu')]
    controls += [('en', 'missing_asset', q) for q in ('coffee grinder', 'octopus anatomy', 'violinist', 'archaeological excavation', 'weather balloon')]
    control_counts = {}
    for index, (language, kind, query) in enumerate(controls):
        counter_key = (kind, language)
        sequence = control_counts.get(counter_key, 0)
        control_counts[counter_key] = sequence + 1
        # Translation pairs stay together, so one cannot train on "core"
        # and evaluate its equivalent "çekirdek" as an independent concept.
        group = f'control-{kind}-{sequence}'
        rows.append(dict(zip(FIELDS, (f'control-{index}', split(group), group,
            language, 'automatic', kind, query, '', 'true', 'draft', '',
            'Candidate abstention only; a human must check the full local catalog.'))))
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('x', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=FIELDS)
        writer.writeheader(); writer.writerows(rows)
    print(json.dumps({'draft_queries': len(rows), 'human_reviewed': 0, 'path': str(path)}))


def lock(source, destination):
    with source.open(newline='') as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) < 200:
        raise ValueError('At least 200 reviewed queries are required')
    ids, queries = set(), set()
    for row in rows:
        if row['id'] in ids or not row['id']:
            raise ValueError('Duplicate/empty query id')
        ids.add(row['id'])
        query = row['query'].strip()
        normalized = (row['mode'], row['language'], query.casefold())
        if not query or normalized in queries:
            raise ValueError('Duplicate/empty query')
        queries.add(normalized)
        if row['review_status'] != 'reviewed' or not row['reviewer'].strip():
            raise ValueError('Every row requires a named human review before locking')
        if row['split'] != split(row['group']):
            raise ValueError('Group split must not be changed to tune evaluation')
        if row['mode'] not in ('manual', 'automatic') or row['language'] not in ('tr', 'en'):
            raise ValueError('Unsupported mode/language')
        if row['expected_none'] not in ('true', 'false'):
            raise ValueError('expected_none must be true/false')
        relevant = [value.strip() for value in row['relevant_ids'].split(';') if value.strip()]
        if (row['expected_none'] == 'true') == bool(relevant):
            raise ValueError('Abstention and relevant labels conflict')
        row['relevant_ids'] = relevant
        row['expected_none'] = row['expected_none'] == 'true'
    package = {'schemaVersion': 1, 'status': 'human-reviewed-locked',
               'sourceSha256': hashlib.sha256(source.read_bytes()).hexdigest(),
               'scope': 'local merged model catalog; no production queries', 'queries': rows}
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open('x') as stream:
        json.dump(package, stream, ensure_ascii=False, indent=2)
    print(json.dumps({'locked_queries': len(rows), 'path': str(destination)}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest='action', required=True)
    p = sub.add_parser('draft'); p.add_argument('path', type=Path)
    p = sub.add_parser('lock'); p.add_argument('source', type=Path); p.add_argument('destination', type=Path)
    args = parser.parse_args()
    if args.action == 'draft': draft(args.path)
    else: lock(args.source, args.destination)
