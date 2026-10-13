#!/usr/bin/env bash
# ./script-build-mac.sh [app|app-functional|app-declarative]  ->  build/<Executable>.app
# SIGN_IDENTITY defaults to ad-hoc ("-"); ARCHS defaults to arm64.
set -euo pipefail
cd "$(dirname "$0")"

variant="${1:-app}"
case "$variant" in
  app)             exe=MonthProgressBar;            id=com.baumannalexj.monthprogressbar;             display="Month Progress Bar" ;;
  app-functional)  exe=MonthProgressBarFunctional;  id=com.baumannalexj.monthprogressbar.functional;  display="Month Progress Bar (functional)" ;;
  app-declarative) exe=MonthProgressBarDeclarative; id=com.baumannalexj.monthprogressbar.declarative; display="Month Progress Bar (declarative)" ;;
  *) echo "unknown variant: $variant" >&2; exit 2 ;;
esac

archs=()
for arch in ${ARCHS:-arm64}; do archs+=(--arch "$arch"); done
swift build -c release --product "$exe" "${archs[@]}"
bin="$(swift build -c release --product "$exe" "${archs[@]}" --show-bin-path)/$exe"

app="build/$exe.app"
rm -rf "$app"
mkdir -p "$app/Contents/MacOS" "$app/Contents/Resources"
cp "$bin" "$app/Contents/MacOS/$exe"
sed -e "s/__EXECUTABLE__/$exe/g" -e "s/__BUNDLE_ID__/$id/g" -e "s/__DISPLAY_NAME__/$display/g" \
  Resources/Info.plist > "$app/Contents/Info.plist"
cp Resources/AppIcon.icns "$app/Contents/Resources/AppIcon.icns"
codesign --force --options runtime --timestamp=none \
  --entitlements Resources/MonthProgressBar.entitlements --sign "${SIGN_IDENTITY:--}" "$app"
echo "$app"
