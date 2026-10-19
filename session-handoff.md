# Session handoff

## Verified now
- Native Compose/Room note foundation builds. Four ViewModel tests pass.
- ARM64 API 36 emulator: Room disk persistence and Compose journey tests pass.
- Saved note survives force-stop and fresh instrumentation/app processes.
- Standard startup passes; lint has no errors (dependency update warnings remain).
- Android Studio 2026.2.1, project-local JDK 21, SDK, and emulator installed.

## Changed this session
WalkingLab starter harness adapted, build/toolchain pinned, first saved-note slice,
behavior tests, CI workflow, runtime evidence scripts, and Room schema added.

## Broken or unverified
No remote exists: GitHub CI has not executed. API 28, optional managed API 35,
tablet, cloud physical hardware, and OS-initiated process-death recovery have not
been tested. The app intentionally uses explicit Save; pending text is not durable.
The local emulator is headless and remains available on emulator-5556.

## Next best step
notes-002: design and implement autosave with ordered writes, failure/retry state,
and explicit interruption guarantees. Do not weaken the saved-note persistence
checks or use destructive database migrations. Future feature work requires a user task.

## Commands
- Startup: ./init.sh
- Full checks: ./scripts/verify.sh all
- App: ./scripts/emulator.sh run
- Local CI device entry point: ANDROID_SERIAL=emulator-5556 ./scripts/ci-device.sh
- Stop local emulator: ./scripts/emulator.sh stop
- Evidence: claude-progress.md; reports under app/build/reports; local logs .artifacts/.
