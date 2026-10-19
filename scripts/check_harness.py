#!/usr/bin/env python3
"""Fail closed on invalid feature state or missing evidence; no Android dependencies."""
import json
from pathlib import Path
root = Path(__file__).resolve().parents[1]
ledger = json.loads((root / 'feature_list.json').read_text())
features = ledger['features']
assert features, 'Feature ledger cannot be empty'
assert len({f['id'] for f in features}) == len(features), 'Duplicate feature IDs'
assert sum(f['status'] == 'in_progress' for f in features) <= 1, 'Only one active feature'
for feature in features:
    assert feature['status'] in ledger['status_legend'], f"Invalid status: {feature['id']}"
    assert feature['verification'], f"Missing acceptance checks: {feature['id']}"
    if feature['status'] == 'passing':
        assert feature['evidence'], f"Missing evidence: {feature['id']}"
for name in ('AGENTS.md', 'init.sh', 'claude-progress.md', 'session-handoff.md',
             'docs/verification.md', 'docs/decisions/0001-android-foundation.md'):
    assert (root / name).is_file(), f'Missing harness artifact: {name}'
print(f'Harness valid: {len(features)} features')
