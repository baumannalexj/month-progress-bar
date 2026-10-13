#!/usr/bin/env bash
# Builds build/MonthProgressBar.app. SIGN_IDENTITY defaults to ad-hoc ("-"); ARCHS defaults to arm64.
set -euo pipefail
cd "$(dirname "$0")"

archs=()
for arch in ${ARCHS:-arm64}; do archs+=(--arch "$arch"); done
swift build -c release "${archs[@]}"
bin="$(swift build -c release "${archs[@]}" --show-bin-path)/MonthProgressBar"

app=build/MonthProgressBar.app
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin" "$app/Contents/MacOS/MonthProgressBar"
cp Resources/Info.plist "$app/Contents/Info.plist"
cp Resources/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
codesign --force --options runtime --timestamp=none \
  --entitlements Resources/MonthProgressBar.entitlements --sign "${SIGN_IDENTITY:--}" "$app"
echo "$app"
