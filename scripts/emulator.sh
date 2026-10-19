#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$PROJECT_ROOT"
AVD_NAME=note_taker_api36
case "${1:-run}" in
  create)
    mkdir -p "$ANDROID_AVD_HOME" "$ANDROID_USER_HOME"
    if ! avdmanager list avd -c | tr -d '\r' | grep -qx "$AVD_NAME"; then
      echo no | avdmanager create avd --name "$AVD_NAME" --package 'system-images;android-36;google_apis;arm64-v8a' --device pixel_6
    fi
    ;;
  start)
    if adb -s emulator-5556 get-state >/dev/null 2>&1; then
      echo 'Reusing project emulator emulator-5556'
    else
      ./scripts/emulator.sh create
      mkdir -p .artifacts
      nohup emulator -avd "$AVD_NAME" -port 5556 -no-window -no-audio -no-boot-anim -no-snapshot -gpu swiftshader_indirect > .artifacts/emulator.log 2>&1 < /dev/null &
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
  stop) adb -s emulator-5556 emu kill ;;
  *) echo 'Usage: scripts/emulator.sh {create|start|run|stop}' >&2; exit 2 ;;
esac
