#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

app=MonthProgressBar.app
target="$HOME/Applications/$app"
[ -d "build/$app" ] || ./script-build-mac.sh

pkill -x MonthProgressBar 2>/dev/null || true
mkdir -p "$HOME/Applications"
if [ -d "$target" ]; then
  mv "$target" "$(mktemp -d)/$app"
fi
mv "build/$app" "$target"
open "$target"
echo "installed $target"
