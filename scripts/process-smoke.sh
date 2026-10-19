#!/usr/bin/env bash
# Build and install both APKs; connected tests may uninstall them during cleanup.
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$PROJECT_ROOT"
export ANDROID_SERIAL="${ANDROID_SERIAL:-emulator-5556}"
mkdir -p .artifacts
./gradlew --console=plain :app:assembleDebug :app:assembleDebugAndroidTest
adb install -r -t app/build/outputs/apk/debug/app-debug.apk
adb install -r -t app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk
TITLE="Restart smoke $(date +%s)"
run_phase() {
  adb shell am instrument -w -r -e class dev.local.notetaker.NoteJourneyTest \
    -e phase "$1" -e smokeTitle "\"$TITLE\"" \
    dev.local.notetaker.test/androidx.test.runner.AndroidJUnitRunner > ".artifacts/process-$1.txt"
  cat ".artifacts/process-$1.txt"
  grep -q 'OK (1 test)' ".artifacts/process-$1.txt"
}
run_phase seed
adb shell am force-stop dev.local.notetaker
run_phase verify
adb shell am start -W -n dev.local.notetaker/.MainActivity
adb shell uiautomator dump /sdcard/note-smoke.xml
adb pull /sdcard/note-smoke.xml .artifacts/note-smoke.xml
grep -Fq "$TITLE" .artifacts/note-smoke.xml
adb exec-out screencap -p > .artifacts/note-reopened.png
printf '%s\n' 'Saved note survived force-stop and fresh instrumentation/app process.'
