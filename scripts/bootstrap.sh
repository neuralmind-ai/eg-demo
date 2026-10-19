#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$PROJECT_ROOT"
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
  echo 'Automatic local bootstrap currently supports Apple Silicon macOS. See README for other hosts.' >&2
  exit 1
fi
mkdir -p .tooling/downloads .tooling/android-sdk/cmdline-tools "$ANDROID_USER_HOME" "$ANDROID_AVD_HOME"
fetch() { if [ ! -f "$2" ]; then curl --fail --location --retry 3 --silent --show-error "$1" -o "$2.partial"; mv "$2.partial" "$2"; fi; }
if [ ! -d .tooling/jdk ]; then
  JDK_URL='https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.10%2B7/OpenJDK21U-jdk_aarch64_mac_hotspot_21.0.10_7.tar.gz'
  fetch "$JDK_URL" .tooling/downloads/jdk.tar.gz
  fetch "$JDK_URL.sha256.txt" .tooling/downloads/jdk.sha256
  EXPECTED="$(awk '{print $1}' .tooling/downloads/jdk.sha256)"
  ACTUAL="$(shasum -a 256 .tooling/downloads/jdk.tar.gz | awk '{print $1}')"
  [ "$EXPECTED" = "$ACTUAL" ] || { echo 'JDK checksum mismatch' >&2; exit 1; }
  mkdir -p .tooling/jdk
  tar -xzf .tooling/downloads/jdk.tar.gz -C .tooling/jdk --strip-components=1
fi
source scripts/env.sh
if [ ! -x "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
  fetch 'https://dl.google.com/android/repository/commandlinetools-mac-13114758_latest.zip' .tooling/downloads/android-cli.zip
  EXPECTED=5673201e6f3869f418eeed3b5cb6c4be7401502bd0aae1b12a29d164d647a54e
  ACTUAL="$(shasum -a 256 .tooling/downloads/android-cli.zip | awk '{print $1}')"
  [ "$EXPECTED" = "$ACTUAL" ] || { echo 'Android CLI checksum mismatch' >&2; exit 1; }
  mkdir -p .tooling/cli-unpack
  unzip -q .tooling/downloads/android-cli.zip -d .tooling/cli-unpack
  mv .tooling/cli-unpack/cmdline-tools "$ANDROID_HOME/cmdline-tools/latest"
fi
if [ "${ACCEPT_ANDROID_LICENSES:-0}" != 1 ]; then
  echo 'Review SDK licenses using sdkmanager --licenses, or rerun ACCEPT_ANDROID_LICENSES=1 ./scripts/bootstrap.sh.' >&2
  exit 1
fi
# yes can receive SIGPIPE when sdkmanager finishes; preserve sdkmanager's status.
set +o pipefail
yes | sdkmanager --sdk_root="$ANDROID_HOME" --licenses
LICENSE_STATUS="${PIPESTATUS[1]}"
set -o pipefail
[ "$LICENSE_STATUS" = 0 ]
sdkmanager --sdk_root="$ANDROID_HOME" 'platform-tools' 'platforms;android-36' 'build-tools;35.0.0' 'emulator' 'system-images;android-36;google_apis;arm64-v8a'
printf 'sdk.dir=%s\n' "$ANDROID_HOME" > local.properties
if [ ! -x .tooling/gradle-8.13/bin/gradle ]; then
  fetch 'https://services.gradle.org/distributions/gradle-8.13-bin.zip' .tooling/downloads/gradle.zip
  fetch 'https://services.gradle.org/distributions/gradle-8.13-bin.zip.sha256' .tooling/downloads/gradle.sha256
  EXPECTED="$(cat .tooling/downloads/gradle.sha256)"
  ACTUAL="$(shasum -a 256 .tooling/downloads/gradle.zip | awk '{print $1}')"
  [ "$EXPECTED" = "$ACTUAL" ] || { echo 'Gradle checksum mismatch' >&2; exit 1; }
  unzip -q .tooling/downloads/gradle.zip -d .tooling
fi
./scripts/emulator.sh create
printf '%s\n' 'Local toolchain ready. Run ./init.sh.'
