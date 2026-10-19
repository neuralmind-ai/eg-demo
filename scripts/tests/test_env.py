"""Regression checks for SDK discovery in fresh shells, without Android downloads."""
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ENV_SCRIPT = Path(__file__).resolve().parents[1] / 'env.sh'


class SdkDiscoveryTest(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='note taker sdk ')
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()
        (self.root / 'scripts').mkdir()
        shutil.copyfile(ENV_SCRIPT, self.root / 'scripts/env.sh')

    def sdk(self, path):
        for tool in ('platform-tools/adb', 'emulator/emulator'):
            binary = path / tool
            binary.parent.mkdir(parents=True, exist_ok=True)
            binary.write_text('#!/bin/sh\nexit 0\n')
            binary.chmod(0o755)
        return path

    def discover(self, **overrides):
        env = {key: value for key, value in os.environ.items()
               if key not in ('ANDROID_HOME', 'ANDROID_SDK_ROOT', 'NOTE_TAKER_ANDROID_HOME')}
        env.update(overrides)
        result = subprocess.run(
            ['bash', '-c', 'source scripts/env.sh; command -v adb; command -v emulator'],
            cwd=self.root, env=env, text=True, capture_output=True, check=True,
        )
        return result.stdout.splitlines()

    def test_local_sdk_survives_stale_shell_sdk_variables(self):
        sdk = self.sdk(self.root / '.tooling/android-sdk')
        self.assertEqual(self.discover(ANDROID_HOME='/missing/sdk', ANDROID_SDK_ROOT='/also/missing'),
                         [str(sdk / 'platform-tools/adb'), str(sdk / 'emulator/emulator')])

    def test_external_sdk_works_without_local_installation(self):
        sdk = self.sdk(self.root / 'external sdk')
        self.assertEqual(self.discover(ANDROID_HOME=str(sdk))[0], str(sdk / 'platform-tools/adb'))

    def test_sdk_root_fallback_works_without_android_home(self):
        sdk = self.sdk(self.root / 'external sdk')
        self.assertEqual(self.discover(ANDROID_SDK_ROOT=str(sdk))[0], str(sdk / 'platform-tools/adb'))

    def test_explicit_project_override_wins_over_local_sdk(self):
        self.sdk(self.root / '.tooling/android-sdk')
        sdk = self.sdk(self.root / 'selected sdk')
        self.assertEqual(self.discover(NOTE_TAKER_ANDROID_HOME=str(sdk))[0], str(sdk / 'platform-tools/adb'))
