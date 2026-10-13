#!/usr/bin/env bash
# ./script-install-mac.sh [app|app-functional|app-declarative]  ->  ~/Applications/<Executable>.app, then starts it
set -euo pipefail
cd "$(dirname "$0")"

variant="${1:-app}"
app="$(./script-build-mac.sh "$variant" | tail -n 1)"
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
