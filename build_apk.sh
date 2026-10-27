#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"
if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is not installed or not on PATH."
  exit 1
fi
flutter pub get
flutter analyze
flutter build apk --release
echo
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
