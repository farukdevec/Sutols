#!/usr/bin/env python3
"""Collect a repeatable baseline; production-dependent tests are opt-in."""
import argparse
import collections
import json
import pathlib
import platform
import subprocess
import sys
from datetime import datetime, timezone

ROOT = pathlib.Path(__file__).resolve().parents[1]
LIVE_TESTS = {
    'chernobyl_live_test.dart': 'Calls the production presentation generator',
    'matter_states_live_test.dart': 'Calls the production presentation generator',
    'live_production_benchmark_test.dart': 'Calls the production presentation generator',
    'real_generation_test.dart': 'Sends an inference request to the production proxy',
    'cors_verification_test.dart': 'Sends production OPTIONS and inference POST requests',
    'probe_nvidia_test.dart': 'Probes the production AI endpoint',
}

def run(command, destination):
    with destination.open('w') as stream:
        result = subprocess.run(command, cwd=ROOT, stdout=stream, stderr=subprocess.STDOUT)
    return {'command': command, 'exit_code': result.returncode, 'log': destination.name}

def test_summary(path):
    tests, suites, failures, errors = {}, {}, [], []
    for line in path.read_text(errors='replace').splitlines():
        try:
            event = json.loads(line)
        except (ValueError, TypeError):
            continue
        if event.get('type') == 'suite':
            suites[event['suite']['id']] = event['suite']['path']
        elif event.get('type') == 'testStart':
            tests[event['test']['id']] = event['test']
        elif event.get('type') == 'testDone':
            if event.get('hidden'):
                continue
            failures.append({'name': tests.get(event['testID'], {}).get('name', str(event['testID'])),
                             'file': suites.get(tests.get(event['testID'], {}).get('suiteID'), ''),
                             'result': event.get('result'), 'skipped': event.get('skipped', False)})
        elif event.get('type') == 'error':
            errors.append({'name': tests.get(event.get('testID'), {}).get('name', ''), 'error': event.get('error', '')})
    return {'counts': dict(collections.Counter('skipped' if f['skipped'] else f['result'] for f in failures)),
            'failed_tests': [f for f in failures if not f['skipped'] and f['result'] != 'success'],
            'errors': errors}

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=pathlib.Path, default=ROOT/'build/development_baseline')
    parser.add_argument('--tests-only', action='store_true', help='Run selected Flutter tests without unrelated backend checks')
    parser.add_argument('--live', action='store_true', help='Explicitly include production tests; can consume AI quota')
    parser.add_argument('--concurrency', type=int, choices=range(1, 33),
                        help='Optional test concurrency for constrained local machines')
    args = parser.parse_args()
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    files = sorted((ROOT/'test').rglob('*_test.dart'))
    excluded = [{'path': str(p.relative_to(ROOT)), 'reason': LIVE_TESTS[p.name]} for p in files
                if not args.live and p.name in LIVE_TESTS]
    selected = [str(p.relative_to(ROOT)) for p in files if args.live or p.name not in LIVE_TESTS]
    report = {'recorded_at_utc': datetime.now(timezone.utc).isoformat(), 'platform': platform.platform(),
              'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
              'initial_git_status': subprocess.check_output(['git', 'status', '--short'], cwd=ROOT, text=True),
              'live_tests_enabled': args.live, 'excluded_tests': excluded, 'selected_test_files': selected}
    report['versions'] = {}
    for name, command in [('flutter', ['flutter', '--version']), ('node', ['node', '--version']), ('python', [sys.executable, '--version'])]:
        result = subprocess.run(command, cwd=ROOT, capture_output=True, text=True)
        report['versions'][name] = (result.stdout + result.stderr).strip()
    print(f"Running {len(selected)} test files; excluded {len(excluded)} production-dependent files.", flush=True)
    concurrency = [] if args.concurrency is None else ['--concurrency', str(args.concurrency)]
    report['tests'] = run(['flutter', 'test', '--no-pub', '--reporter', 'json', *concurrency, *selected], output/'tests.jsonl')
    report['tests']['summary'] = test_summary(output/'tests.jsonl')
    print('Tests:', report['tests']['summary']['counts'], flush=True)
    if args.tests_only:
        (output/'baseline.json').write_text(json.dumps(report, ensure_ascii=False, indent=2))
        return report['tests']['exit_code']
    report['analysis'] = run(['flutter', 'analyze', '--no-pub'], output/'analysis.log')
    compiler = ROOT/'functions/node_modules/.bin/tsc'
    if compiler.exists():
        report['functions'] = run([str(compiler), '--project', 'functions/tsconfig.json', '--noEmit', '--pretty', 'false'], output/'functions.log')
    else:
        report['functions'] = {'status': 'not_run', 'reason': 'Install functions dependencies first'}
    (output/'baseline.json').write_text(json.dumps(report, ensure_ascii=False, indent=2))
    print('Saved', output/'baseline.json', flush=True)
    return 1 if any(report[k].get('exit_code', 0) for k in ['tests', 'analysis', 'functions']) else 0

if __name__ == '__main__':
    sys.exit(main())
