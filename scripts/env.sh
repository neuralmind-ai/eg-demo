#!/usr/bin/env bash
# Source from other scripts; keep all local caches inside the checkout.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -d "$PROJECT_ROOT/.tooling/jdk/Contents/Home" ]; then
  export JAVA_HOME="$PROJECT_ROOT/.tooling/jdk/Contents/Home"
fi
if [ -n "${NOTE_TAKER_ANDROID_HOME:-}" ]; then
  export ANDROID_HOME="$NOTE_TAKER_ANDROID_HOME"
elif [ -d "$PROJECT_ROOT/.tooling/android-sdk" ]; then
  export ANDROID_HOME="$PROJECT_ROOT/.tooling/android-sdk"
else
  export ANDROID_HOME="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$PROJECT_ROOT/.tooling/android-sdk}}"
fi
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export ANDROID_USER_HOME="$PROJECT_ROOT/.tooling/android-user"
export ANDROID_AVD_HOME="$PROJECT_ROOT/.tooling/avd"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PROJECT_ROOT/.tooling/gradle-home}"
export PATH="${JAVA_HOME:+$JAVA_HOME/bin:}$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
