#!/usr/bin/env bash
# Called inside android-emulator-runner while its device is still alive.
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$PROJECT_ROOT"
export ANDROID_SERIAL="${ANDROID_SERIAL:-emulator-5554}"
mkdir -p .artifacts
capture_evidence() {
  local result=$?
  adb logcat -d > .artifacts/ci-logcat.txt 2>&1 || true
  adb exec-out screencap -p > .artifacts/ci-device.png 2>/dev/null || true
  return "$result"
}
trap capture_evidence EXIT
./scripts/verify.sh connected
./scripts/process-smoke.sh
