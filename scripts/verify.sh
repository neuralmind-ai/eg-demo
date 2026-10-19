#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$PROJECT_ROOT"
mkdir -p .artifacts
python3 scripts/check_harness.py
if [ ! -x ./gradlew ] || ! command -v adb >/dev/null; then
  echo 'Missing toolchain. See README and run ./scripts/bootstrap.sh first.' >&2
  exit 1
fi
case "${1:-host}" in
  host) ./gradlew --console=plain :app:assembleDebug :app:lintDebug :app:testDebugUnitTest ;;
  device)
    ./scripts/emulator.sh start
    export ANDROID_SERIAL=emulator-5556
    ./gradlew --console=plain :app:connectedDebugAndroidTest
    ;;
  connected) ./gradlew --console=plain :app:connectedDebugAndroidTest ;;
  all) ./scripts/verify.sh host; ./scripts/verify.sh device; ./scripts/process-smoke.sh ;;
  *) echo 'Usage: scripts/verify.sh {host|device|connected|all}' >&2; exit 2 ;;
esac
