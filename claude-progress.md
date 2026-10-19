# Progress log (agent-neutral)

## Current verified state
- Repository: /Users/rafael/projects/android-note-taker
- Startup: `./init.sh`
- Full local verification: `./scripts/verify.sh all`
- Completed: foundation-001 (starter harness, pinned build, persisted-note slice).
- Highest-priority unfinished feature: notes-002 (autosave); not started.
- Current blocker: none for local development. No Git remote is configured, so
  GitHub-hosted CI execution is unverified.

## Session 001 — October 18–19, 2026

### Completed
- Read the WalkingLab quick start and actual starter templates at
  `38ddcd2bf8d65271f668b94e7c875ca1d629d622`. Adapted the four core artifacts and
  handoff/review/checklist; retained MIT attribution under third_party/.
- Installed Android Studio 2026.2.1 via Homebrew. Installed project-local Temurin
  JDK 21.0.10+7, SDK platform 36, build tools, ARM64 image, and emulator under
  ignored .tooling/. Pinned Gradle 8.13, AGP 8.13.2, Kotlin 2.2.10, dependencies,
  wrapper distribution checksum, and CI action commit hashes.
- Added one-module Kotlin/Compose/Material 3 app, ViewModel state, constructor
  injection, Room repository/database, and exported schema version 1.
- First slice: create, edit, explicitly save, list, and reopen text notes. Pending
  changes and write failures remain visible. Backup/transfer disabled pending design.
- Added scripts for bootstrap, baseline checks, local emulator, process restart
  smoke, feature-ledger validation, and CI evidence capture before emulator teardown.
- Added GitHub host/device workflow; it has not run remotely.

### Verification and evidence
- `./init.sh`: PASS. Debug APK, lint, and four ViewModel tests. Final lint refresh
  `./gradlew --console=plain :app:lintDebug --rerun-tasks` (through scripts/env.sh):
  PASS, 0 errors and 17 visible dependency/toolchain update warnings.
- `./scripts/verify.sh device`: PASS, 2 tests on ARM64 API 36. Room test closes and
  reopens an actual disk DB, checks Unicode contents, deterministic order, and update
  identity. Compose test saves/reopens a note and recreates the activity.
- `./scripts/process-smoke.sh`: PASS. Separate seed and verify instrumentation
  invocations, with force-stop between them. Each reports OK (1 test); fresh app
  launch and UI hierarchy also confirm the persisted synthetic note.
- `ANDROID_SERIAL=emulator-5556 ./scripts/ci-device.sh`: PASS locally. Re-ran the
  2 device tests and both restart phases through the exact CI device entry point;
  captured runtime logs and screen while emulator remained available.
- `bash -n init.sh scripts/*.sh`: PASS. CI YAML parses; all third-party actions
  resolve to pinned 40-character commits. `python3 scripts/check_harness.py`: PASS.
- Visually inspected the emulator's rendered notes list. Synthetic multiline,
  non-Latin text and emoji were displayed correctly.
- Reports: app/build/reports/tests/testDebugUnitTest/,
  app/build/reports/androidTests/connected/debug/, and lint-results-debug.html.
- Transient evidence (ignored): .artifacts/host-final.log, lint-final.log,
  device-checks.log, ci-device-local.log, process-seed.txt, process-verify.txt,
  note-reopened.png, ci-device.png, and ci-logcat.txt.

### Issue resolved during setup
The first restart smoke failed because connected-test cleanup removed the test APK.
The script now builds and installs both APKs itself before seeding/restarting.
Subsequent standalone and CI-entry-point runs passed. No app test was weakened.

### Remaining limits and next step
- Remote Linux CI, managed API 35, minimum API 28, tablet, real physical devices,
  and OS-initiated process-death recovery are unverified. Force-stop/relaunch is
  evidence only for already-saved note durability, not unsaved draft recovery.
- Explicit Save is intentional. Autosave, search, delete/undo, export/backup,
  production signing, and cloud test accounts are future work.
- Local emulator remains headless on emulator-5556; stop with
  `./scripts/emulator.sh stop`. .tooling/ uses about 10 GB, excluded from Git.
- Next task: notes-002 autosave design and tests when requested. Preserve the
  persistence checks and migration policy. See session-handoff.md.
- Checkpoint: initial foundation commit; exact hash is available in Git history.
