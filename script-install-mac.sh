#!/usr/bin/env bash
# Builds, moves the app to ~/Applications and starts it.
set -euo pipefail
cd "$(dirname "$0")"

app="$(./script-build-mac.sh | tail -n 1)"
name="$(basename "$app" .app)"
target="$HOME/Applications/$name.app"

pkill -x "$name" 2>/dev/null || true
mkdir -p "$HOME/Applications"
if [ -d "$target" ]; then
  mv "$target" "$(mktemp -d)/$name.app"
fi
mv "$app" "$target"
open "$target"
echo "installed $target"
