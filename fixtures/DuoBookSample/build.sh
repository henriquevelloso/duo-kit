#!/bin/bash
# Builds DuoBookSample.app for the iOS simulator without an Xcode project.
set -euo pipefail
cd "$(dirname "$0")"
OUT="${1:-build}"
SDK="$(xcrun --sdk iphonesimulator --show-sdk-path)"
rm -rf "$OUT/DuoBookSample.app"
mkdir -p "$OUT/DuoBookSample.app"
xcrun swiftc -parse-as-library -sdk "$SDK" -target arm64-apple-ios27.1-simulator \
  -O BookSpread.swift SampleApp.swift DemoScreens.swift -o "$OUT/DuoBookSample.app/DuoBookSample"
cp Info.plist "$OUT/DuoBookSample.app/Info.plist"
codesign --force --sign - "$OUT/DuoBookSample.app" >/dev/null
case "$OUT" in /*) echo "$OUT/DuoBookSample.app" ;; *) echo "$PWD/$OUT/DuoBookSample.app" ;; esac
