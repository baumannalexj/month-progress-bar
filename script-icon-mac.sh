#!/usr/bin/env bash
# Regenerates Resources/AppIcon.icns from IconRenderer.swift.
set -euo pipefail
cd "$(dirname "$0")"

swift build -c release --product MonthProgressBar
work="$(mktemp -d)/AppIcon.iconset"
"$(swift build -c release --product MonthProgressBar --show-bin-path)/MonthProgressBar" --iconset "$work"
iconutil -c icns "$work" -o Resources/AppIcon.icns
echo Resources/AppIcon.icns
