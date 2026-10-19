# Android note taker: project setup research

Researched October 18, 2026. This document records the original proposal.
The foundation has since been implemented; see [README](../README.md) and
[the progress log](../claude-progress.md) for current verified status.

## Recommendation

Build a native Kotlin app with Jetpack Compose and Material 3, local Room storage,
and a small, explicit architecture. Develop against the Android Emulator on this
Apple Silicon Mac. Use JVM tests for fast feedback, emulator instrumentation tests
for Android behavior, and Firebase Test Lab for occasional real-device coverage.

AI-generated code should pass the same reproducible checks as human-written code.
The key investment is a reliable feedback loop, rather than more agent tooling.

## Current environment

- The project directory was empty at inspection.
- The host reports `arm64`.
- `adb` and `emulator` were not found on PATH.
- Android Studio and the SDK were not found at `/Applications/Android Studio.app`
  and `~/Library/Android/sdk`. Other installation locations were not exhaustively searched.
- `/usr/libexec/java_home -V` reports Oracle JDK 23.0.2.
- No app was built or tested during this investigation.

## Stack and structure

| Area | Proposed choice | Reason |
| --- | --- | --- |
| Platform | Native Android, Kotlin | Direct access to Android APIs and official tooling |
| UI | Compose and Material 3 | Recommended Android UI toolkit; declarative state is easy to exercise in tests |
| Screens | Single activity, notes list and editor | Small initial product surface |
| State | ViewModels, immutable UI state, coroutines and Flow | Clear data flow and testable screen behavior |
| Notes | Room database behind a repository | Durable structured storage and explicit schema migrations |
| Preferences | DataStore when preferences are needed | Keep settings separate from notes |
| Dependencies | Constructor injection, small manual container initially | Easy replacement with test fakes without early framework overhead |
| Build | Gradle Kotlin DSL, wrapper, version catalog | Repeatable CLI builds and centralized dependency versions |

Start with one `:app` module, organized into `data`, `ui/notes`, `ui/editor`,
and `ui/theme` packages. Split modules only when boundaries or build times justify
it. Keep database operations out of composables. Introduce a domain/use-case layer
only when business logic needs it. Reconsider Hilt if navigation and dependency
scopes become complex.

Google recommends Compose, separate UI/data layers, repositories, unidirectional
data flow, and testable dependencies. The specific small-project choices above
are recommendations for this app, not mandatory Android requirements.
[Architecture recommendations](https://developer.android.com/topic/architecture/recommendations)

Start with an offline text-note MVP: create, edit, autosave, list, search, and
delete with recovery/undo. Treat sync, accounts, rich text, attachments, and any
in-app AI features as separate product decisions. AI-generated source code does
not itself require an AI SDK or backend in the app.

## Toolchain setup

1. Install the stable Apple Silicon Android Studio distribution, SDK command-line
   tools, platform-tools, emulator, and a stable Android SDK platform/system image.
2. Choose and record a compatible Android Gradle Plugin, Gradle, Kotlin/Compose,
   and JDK combination using official compatibility guidance. Do not assume the
   installed JDK 23 is the appropriate default. Align IDE, CLI, and CI Java versions.
3. Commit the Gradle wrapper and its JAR, explicit plugin/library versions, a
   version catalog, and build instructions. Avoid dynamic dependency versions.
4. Keep SDK paths in untracked local configuration; ignore SDKs, build outputs,
   emulator images, signing keys, and credentials. Keep release signing separate
   from ordinary agent development.
5. Decide `applicationId` and minimum supported Android version before scaffolding.
   Set compile/target SDKs from the current stable tooling and distribution needs.
   Do not choose an older minimum merely to copy a tutorial.

[Java and Gradle toolchains](https://developer.android.com/build/jdks)

## Testing without owning a phone

### Local interactive testing

Use an ARM64 (`arm64-v8a`) system image on this Mac so the emulator can use
hardware acceleration. Run it directly on macOS initially. The emulator runs the
actual Android application and is suitable for day-to-day development.

Keep a recent phone AVD for interactive work. Add minimum-supported-version and
tablet coverage as the app develops; run them sequentially if resources are tight.
Verify keyboard behavior, rotation, dark mode, large fonts, and edge-to-edge layout.

[Android Emulator](https://developer.android.com/studio/run/emulator),
[hardware acceleration](https://developer.android.com/studio/run/emulator-acceleration)

### Automated checks

| Check | Runs on | Initial coverage |
| --- | --- | --- |
| JVM unit tests | Developer machine and CI; no emulator | ViewModel transitions, search/sort rules, save coordination, error handling using fakes |
| Room integration tests | Android emulator | Real SQL queries, persisted contents, schema migrations |
| Compose UI tests | Android emulator | Create, edit, reopen, search, delete/undo, and navigation |
| Visual checks | Compose previews; optionally host screenshot tests | Empty/list/editor/error states, dark theme, large text |
| Real-device regression | Firebase Test Lab | Representative phones and manufacturer-specific behavior before releases |

Local JVM tests are fast, but do not implement the Android framework.
Robolectric can fill selected gaps later; it should not replace the emulator suite.
[Local unit tests](https://developer.android.com/training/testing/local-tests),
[Room testing](https://developer.android.com/training/data-storage/room/testing-db),
[Compose testing](https://developer.android.com/develop/ui/compose/testing)

Declare emulator test configurations through Gradle Managed Devices where supported
by the selected toolchain and host image. This gives agents and CI repeatable
device setup. First validate one device and one test before expanding the matrix.
GitHub-hosted Linux runners support Android hardware acceleration; CI will normally
use x86_64 images, while this Mac uses ARM64. Check runner virtualization and graphics
configuration rather than assuming local emulator settings will transfer unchanged.
[Managed devices](https://developer.android.com/studio/test/managed-devices),
[GitHub runner capabilities](https://docs.github.com/en/actions/reference/runners/github-hosted-runners)

Host screenshot tests can catch layout regressions without booting Android, but
Google's Compose Preview Screenshot Testing integration currently includes
experimental tooling. Adopt it only after validating compatibility. Screenshot
baselines need human visual review; agents should not automatically accept every diff.
[Screenshot testing](https://developer.android.com/training/testing/ui-tests/screenshot),
[Compose screenshot tooling](https://developer.android.com/studio/preview/compose-screenshot-testing)

Firebase Test Lab provides remotely hosted physical Android devices and test
artifacts including logs and videos. This supplies real-device checks without
buying a phone. Configure it later, check quotas/pricing before running a matrix,
and use synthetic notes. Using the lab does not require adding Firebase services
to the production app.
[Test Lab](https://firebase.google.com/docs/test-lab/),
[test results](https://firebase.google.com/docs/test-lab/android/analyzing-results)

## Note-specific acceptance tests

- A saved note survives closing and relaunching the app.
- Draft behavior is specified: when a save becomes durable, what a pending save
  looks like, and what can be lost if the process stops before completion.
- A completed older save cannot overwrite newer text during rapid typing.
- Rotation and background/foreground transitions preserve the editing experience.
- Test system-initiated process death separately from force-stop/relaunch; recreating
  an activity alone is not a process-death test.
- Empty notes, multiline text, emoji, non-Latin text, and large notes behave correctly.
- Search and sort are deterministic, including timestamp ties.
- Database upgrades preserve existing notes and contents.
- Write failures are visible and do not falsely report that a note was saved.
- Delete/undo behavior and export/backup expectations are explicit.

Store note content durably in Room. A ViewModel or `SavedStateHandle` is not a
substitute for note storage. Saved state is appropriate for small transient UI state,
such as the open note ID. Export and commit Room schemas and test migrations;
do not use destructive migration as a shortcut for user notes.
[State persistence](https://developer.android.com/topic/libraries/architecture/saving-states),
[Room migrations](https://developer.android.com/training/data-storage/room/migrating-db-versions)

## Working agreement for AI agents

Create a concise root `AGENTS.md` when implementation begins. Include:

- Product scope and architecture boundaries, with links to short design decisions.
- Exact build, test, emulator, and log-collection commands that have actually worked.
- A requirement to inspect existing code and validate library APIs before introducing dependencies.
- Small tasks with acceptance criteria and focused diffs; dependency upgrades as separate work.
- Regression tests for bugs, behavior-based assertions, deterministic clocks/dispatchers
  where needed, and no arbitrary sleeps in tests.
- A prohibition on bypassing failing checks, deleting meaningful tests, or using
  destructive schema fallback to make a build green.
- An honest completion report: checks run, checks skipped, and remaining failures.

Keep the instruction file short enough to remain useful. Android Studio also
supports repository `AGENTS.md` instructions.
[Android agent files](https://developer.android.com/studio/gemini/agent-files)

Give agents runtime evidence through Gradle reports, `adb`, Logcat, screenshots,
and screen recordings. Specialized agent integrations can be evaluated later;
they are not a prerequisite for the initial feedback loop.
[ADB](https://developer.android.com/tools/adb),
[Logcat](https://developer.android.com/tools/logcat)

## First implementation milestone

1. Initialize version control and the minimal Compose project with pinned tooling.
2. Document and verify a clean command-line build and unit-test run.
3. Boot the local emulator, install the app, and inspect its first screen.
4. Implement one vertical slice: create a note, persist it in Room, relaunch, reopen it.
5. Add meaningful unit and instrumentation tests for that slice.
6. Add CI for build/lint/unit tests plus a small emulator smoke suite; retain failure
   reports, screenshots, and relevant logs as artifacts.
7. Record the working commands in `AGENTS.md` before asking agents to add more features.

Expected baseline commands once the project exists:

```sh
./gradlew :app:assembleDebug :app:lintDebug :app:testDebugUnitTest
./gradlew :app:connectedDebugAndroidTest
```

The second command requires a running emulator. A managed-device task replaces
it once that device is configured; its name depends on the chosen device definition.
These commands are proposed, not verified in the currently empty repository.
