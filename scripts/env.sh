#!/usr/bin/env bash
# Source from other scripts; keep all local caches inside the checkout.
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [ -d "$PROJECT_ROOT/.tooling/jdk/Contents/Home" ]; then
  export JAVA_HOME="$PROJECT_ROOT/.tooling/jdk/Contents/Home"
fi
export ANDROID_HOME="${ANDROID_HOME:-$PROJECT_ROOT/.tooling/android-sdk}"
export ANDROID_USER_HOME="$PROJECT_ROOT/.tooling/android-user"
export ANDROID_AVD_HOME="$PROJECT_ROOT/.tooling/avd"
export GRADLE_USER_HOME="${GRADLE_USER_HOME:-$PROJECT_ROOT/.tooling/gradle-home}"
export PATH="${JAVA_HOME:+$JAVA_HOME/bin:}$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
