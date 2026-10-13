#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

app=build/MonthProgressBar.app
rm -rf "$app"
mkdir -p "$app/Contents/MacOS"
swiftc -O -o "$app/Contents/MacOS/MonthProgressBar" app/*.swift app/Themes/*.swift
cat > "$app/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key><string>com.baumannalexj.monthprogressbar</string>
  <key>CFBundleName</key><string>MonthProgressBar</string>
  <key>CFBundleExecutable</key><string>MonthProgressBar</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.1</string>
  <key>LSMinimumSystemVersion</key><string>13.0</string>
  <key>LSUIElement</key><true/>
</dict>
</plist>
PLIST
codesign --force --sign - "$app"
echo "$app"
