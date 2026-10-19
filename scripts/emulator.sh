#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$PROJECT_ROOT"
AVD_NAME=note_taker_api36
for tool in adb emulator avdmanager; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing %s in Android SDK: %s\nRun ./scripts/bootstrap.sh first, or set NOTE_TAKER_ANDROID_HOME to a complete SDK.\n' "$tool" "$ANDROID_HOME" >&2
    exit 1
  fi
done
check_project_device() {
  local actual
  actual="$(adb -s emulator-5556 emu avd name | head -n 1 | tr -d '\r')"
  if [ "$actual" != "$AVD_NAME" ]; then
    echo "Port 5556 belongs to another emulator ($actual); leaving it unchanged." >&2
    exit 1
  fi
}
case "${1:-run}" in
  create)
    mkdir -p "$ANDROID_AVD_HOME" "$ANDROID_USER_HOME"
    if ! avdmanager list avd -c | tr -d '\r' | grep -qx "$AVD_NAME"; then
      echo no | avdmanager create avd --name "$AVD_NAME" --package 'system-images;android-36;google_apis;arm64-v8a' --device pixel_6
    fi
    ;;
  start)
    if adb -s emulator-5556 get-state >/dev/null 2>&1; then
      check_project_device
      echo 'Reusing project emulator emulator-5556'
    else
      ./scripts/emulator.sh create
      mkdir -p .artifacts
      emulator_options=(-avd "$AVD_NAME" -port 5556 -no-audio -no-boot-anim -no-snapshot -gpu swiftshader_indirect)
      if [ "${NOTE_TAKER_EMULATOR_WINDOW:-0}" != 1 ]; then emulator_options+=(-no-window); fi
      nohup emulator "${emulator_options[@]}" > .artifacts/emulator.log 2>&1 < /dev/null &
      echo "$!" > .artifacts/emulator.pid
    fi
    export ANDROID_SERIAL=emulator-5556
    for ((attempt=0; attempt<180; attempt++)); do
      if [ "$(adb shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = 1 ]; then
        adb shell input keyevent 82
        echo 'Emulator booted: emulator-5556'
        exit 0
      fi
      sleep 2
    done
    echo 'Emulator boot timed out; inspect .artifacts/emulator.log' >&2
    exit 1
    ;;
  run)
    ./scripts/emulator.sh start
    export ANDROID_SERIAL=emulator-5556
    ./gradlew :app:installDebug
    adb shell am start -n dev.local.notetaker/.MainActivity
    ;;
  window)
    ./scripts/emulator.sh stop
    NOTE_TAKER_EMULATOR_WINDOW=1 ./scripts/emulator.sh run
    ;;
  stop)
    if adb -s emulator-5556 get-state >/dev/null 2>&1; then
      check_project_device
      adb -s emulator-5556 emu kill
      for ((attempt=0; attempt<30; attempt++)); do
        if ! adb -s emulator-5556 get-state >/dev/null 2>&1; then exit 0; fi
        sleep 1
      done
      echo 'Emulator did not stop within 30 seconds.' >&2
      exit 1
    fi
    echo 'Project emulator is already stopped.'
    ;;
  *) echo 'Usage: scripts/emulator.sh {create|start|run|window|stop}' >&2; exit 2 ;;
esac
