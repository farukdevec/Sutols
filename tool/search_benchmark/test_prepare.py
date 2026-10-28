import csv
import json
import tempfile
import unittest
from pathlib import Path
import prepare


class ReviewGateTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.csv = Path(self.directory.name) / 'draft.csv'
        self.json = Path(self.directory.name) / 'locked.json'
        prepare.draft(self.csv)
        with self.csv.open(newline='') as stream:
            self.rows = list(csv.DictReader(stream))

    def rewrite(self):
        with self.csv.open('w', newline='') as stream:
            writer = csv.DictWriter(stream, fieldnames=prepare.FIELDS)
            writer.writeheader(); writer.writerows(self.rows)

    def mark_fixture_review(self):
        # Synthetic review is only a unit-test fixture, never a quality claim.
        for row in self.rows:
            row['review_status'] = 'reviewed'
            row['reviewer'] = 'synthetic-unit-fixture'

    def test_draft_rejected_without_output(self):
        with self.assertRaisesRegex(ValueError, 'human review'):
            prepare.lock(self.csv, self.json)
        self.assertFalse(self.json.exists())

    def test_translation_pairs_stay_in_same_split(self):
        self.assertEqual(len(self.rows), len(json.loads((prepare.ROOT / 'web/models/original-v1/manifest.json').read_text())) * 4 + 50)
        controls = [row for row in self.rows if row['id'].startswith('control-')]
        for row in controls:
            pair = [r for r in controls if r['group'] == row['group']]
            self.assertEqual(len(pair), 2)
            self.assertEqual(len({r['split'] for r in pair}), 1)
        groups = {}
        for row in self.rows:
            groups.setdefault(row['group'], set()).add(row['split'])
        self.assertTrue(all(len(splits) == 1 for splits in groups.values()))

    def test_conflicting_labels_cannot_be_locked(self):
        self.mark_fixture_review()
        self.rows[0]['expected_none'] = 'true'
        self.rewrite()
        with self.assertRaisesRegex(ValueError, 'conflict'):
            prepare.lock(self.csv, self.json)

    def test_lock_is_write_once_and_tracks_source_hash(self):
        self.mark_fixture_review(); self.rewrite()
        prepare.lock(self.csv, self.json)
        data = json.loads(self.json.read_text())
        self.assertEqual(len(data['sourceSha256']), 64)
        self.assertEqual(len(data['queries']), len(self.rows))
        with self.assertRaises(FileExistsError):
            prepare.lock(self.csv, self.json)


if __name__ == '__main__':
    unittest.main()
