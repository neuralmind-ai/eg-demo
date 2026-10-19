# Agent operating guide

Adapted from WalkingLab's starter templates; see docs/harness/README.md.

## Start every session
1. Confirm the repository with `pwd` and inspect `git status --short`.
2. Read `claude-progress.md` (agent-neutral despite its historical filename),
   `feature_list.json`, and recent commits (`git log --oneline -5`; an empty history is valid).
3. Read [architecture](docs/decisions/0001-android-foundation.md) and the relevant
   [verification instructions](docs/verification.md).
4. Run `./init.sh`. Fix a broken baseline before adding features. For UI/storage
   work also run the emulator baseline with `./scripts/verify.sh device`.
5. Choose one unfinished feature, respecting the user's requested scope.

## Working rules
- Implement one feature at a time; preserve unrelated user changes.
- Kotlin + Compose UI, ViewModels for state, repository for storage, Room for notes.
  No database access in composables, destructive migration fallback, or blocking UI I/O.
- Verify dependency APIs before introducing them. Pin versions; isolate upgrades.
- Use deterministic behavior tests and fakes; no arbitrary sleeps in app tests.
- Do not weaken tests, lint, acceptance criteria, or screenshot baselines to hide failures.
- Keep note contents out of logs. Keep SDKs, keys, caches, and personal data out of Git.
- Use repository scripts so IDE, CLI, and CI follow the same path. Do not claim a
  remote CI job ran just because the workflow file exists.

## Definition of done
Behavior works, required checks actually ran, evidence is recorded, and the standard
startup remains usable. Missing tools or permissions mean unverified/blocked, not passing.
For persistence, test reopening actual disk storage; activity recreation alone does
not prove durability or system process-death recovery.

## End every session
Update `feature_list.json`, `claude-progress.md`, and `session-handoff.md`. Use
[clean-state checklist](docs/harness/clean-state-checklist.md) and
[evaluator rubric](docs/harness/evaluator-rubric.md). Record commands, outcomes,
remaining risks, and the next feature. Commit a safe checkpoint with a descriptive
message when permitted; never include local tooling or generated test data.
