#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"
./scripts/verify.sh host
if [ "${RUN_START_COMMAND:-0}" = 1 ]; then
  exec ./scripts/emulator.sh run
fi
printf '%s\n' 'Baseline passed. Start the app: ./scripts/emulator.sh run' 'Android runtime checks: ./scripts/verify.sh device'
