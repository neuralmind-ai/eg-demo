# Verification

Run scripts from the repository root. `scripts/env.sh` chooses the local JDK/SDK
and ignored cache directories. No user-global Java setting is changed.

- `./init.sh`: harness validation, debug APK build, Android lint, JVM tests.
- `./scripts/verify.sh device`: boot/reuse the local ARM64 API 36 emulator and run
  Room disk-persistence and Compose journey tests. This does not claim process-death testing.
- `./scripts/process-smoke.sh`: build/install the APKs, save a synthetic
  note, force-stop, then verify it from a fresh instrumentation/app process.
- `./scripts/verify.sh all`: host, device, and process restart checks.
- `./scripts/verify.sh connected`: device tests on an already-running emulator (CI).
- `./scripts/emulator.sh run`: install and launch the debug app on emulator-5556.
- `./scripts/emulator.sh window`: restart this project's emulator with a visible window and launch the app.
- `./scripts/emulator.sh stop`: stop only this project's emulator.

Host reports: `app/build/reports/tests/testDebugUnitTest/` and
`app/build/reports/lint-results-debug.html`.
Device reports: `app/build/reports/androidTests/connected/debug/`.
Local transient logs/screenshots: `.artifacts/` (ignored).

CI runs equivalent build and device checks on Linux x86_64. Its device wrapper
collects Logcat and a screenshot on exit, before the runner tears down the emulator. The
`:app:pixelApi35DebugAndroidTest` Gradle Managed Device is an optional API 35
configuration; it is not verified by the local API 36 connected-device run.

For runtime failures collect `adb -s emulator-5556 logcat -d` and screenshots with
`adb -s emulator-5556 exec-out screencap -p`. Do not log note contents. Test data
must be synthetic. Do not accept a screenshot diff without inspecting it.

Adding a feature requires its relevant checks; changing a schema requires migration
coverage from supported old versions and committed exported schemas. Version 1 has
no migration to test yet. Activity recreation, force-stop/relaunch, and OS process
death are different scenarios; report exactly which ran.
