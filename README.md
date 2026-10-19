# Android Note Taker

A native Kotlin/Compose Android app with local Room storage, built for verifiable
agent development. The first slice creates, explicitly saves, lists, and reopens
text notes. Unsaved changes require Save; autosave is a future feature.

## Local setup (Apple Silicon macOS)

```sh
# Downloads JDK 21, Android SDK/emulator, and an ARM64 API 36 image (~several GB).
# Review Google's Android SDK licenses before opting into automatic acceptance.
ACCEPT_ANDROID_LICENSES=1 ./scripts/bootstrap.sh
./init.sh
./scripts/verify.sh device
./scripts/process-smoke.sh
./scripts/emulator.sh run
```

Tools and caches stay in ignored `.tooling/`. `local.properties` contains only the
local SDK path. Bootstrap is explicit; normal startup doesn't accept licenses or
install system software. JDK 21.0.10+7 and Gradle downloads are checksum checked.
The SDK command-line tools build is pinned to 13114758. SDK package revisions are
resolved by sdkmanager; test logs should record versions when diagnosing drift.

Android Studio 2026.2.1 is installed on this machine and can open this directory for previews, debugging, and interactive
emulator use. Select JDK 21 (local `.tooling/jdk/Contents/Home`) for Gradle and SDK
`.tooling/android-sdk`. The command-line harness works independently of the IDE.
The local automated emulator uses port 5556; tests leave only synthetic notes.

For other hosts, install JDK 21 and the Android SDK normally, set `JAVA_HOME` and
`ANDROID_HOME`, and run `./init.sh`. Use an appropriate emulator image for the host
architecture and `./gradlew :app:connectedDebugAndroidTest`. Automatic bootstrap
and `scripts/emulator.sh` currently target this Apple Silicon machine.

## Agent entry points

Read [AGENTS.md](AGENTS.md), [progress](claude-progress.md),
[feature state](feature_list.json), and [handoff](session-handoff.md).
Startup is `./init.sh`; full local checks are `./scripts/verify.sh all`. See [verification](docs/verification.md),
[architecture](docs/decisions/0001-android-foundation.md),
[harness provenance](docs/harness/README.md), and
[initial research](docs/project-setup-research.md).

## CI and scope

`.github/workflows/android.yml` runs host checks and x86_64 emulator tests on GitHub
pushes/PRs, retaining reports and runtime evidence. A workflow file is not proof of
a remote run; no remote is configured yet. The optional Gradle-managed API 35 device
is separate from the verified local connected API 36 emulator.

No backend, Internet permission, cloud test account, signing keys, sync, autosave,
search, delete, export, or backup is configured. Minimum Android version is 9/API 28;
app ID `dev.local.notetaker` is provisional before publication.
