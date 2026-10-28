"""Build a local web release and attach verified source/build identity.
This command does not publish. The three feature switches are narrow rollback
controls; disabling them is not a substitute for restoring a previous release.
"""
import argparse
import datetime
import hashlib
import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FLAGS = ('SUTOLS_VISIBLE_SCENES', 'SUTOLS_ORIGINAL_MODELS', 'SUTOLS_INFLECTED_MATCHING')


def source_fingerprint():
    files = sorted([p for folder in ('lib', 'web', 'assets') for p in (ROOT / folder).rglob('*') if p.is_file()]
                   + [ROOT / 'pubspec.yaml', ROOT / 'pubspec.lock'])
    fingerprint = hashlib.sha256()
    for path in files:
        fingerprint.update(str(path.relative_to(ROOT)).encode())
        fingerprint.update(hashlib.sha256(path.read_bytes()).digest())
    return fingerprint.hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('web_build', type=Path)
    parser.add_argument('--disable', action='append', choices=FLAGS, default=[])
    args = parser.parse_args()
    destination = args.web_build.resolve()
    (destination / 'release-manifest.json').unlink(missing_ok=True)
    flags = {name: name not in args.disable for name in FLAGS}
    source_hash = source_fingerprint()
    subprocess.run(['flutter', 'build', 'web', '--release', '--no-pub', '--output', str(destination)]
                   + [f'--dart-define={name}={str(value).lower()}' for name, value in flags.items()], cwd=ROOT, check=True)
    if source_fingerprint() != source_hash:
        raise SystemExit('Source changed during build; no verified manifest was written. Rebuild after edits finish.')
    manifest = {
        'baseCommit': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
        'workingTreeDirty': bool(subprocess.check_output(['git', 'status', '--porcelain'], cwd=ROOT, text=True).strip()),
        'createdAtUtc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'sourceSha256': source_hash,
        'mainJsSha256': hashlib.sha256((destination / 'main.dart.js').read_bytes()).hexdigest(),
        'featureFlags': flags,
        'projectSchemaVersion': 2,
        'sceneStateAdditiveVersion': 1,
        'originalModelPackage': 'original-v1',
        'publicationStatus': 'local-validation-only',
    }
    (destination / 'release-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
    print(json.dumps(manifest, indent=2))


if __name__ == '__main__':
    main()
