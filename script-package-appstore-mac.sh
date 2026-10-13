#!/usr/bin/env bash
# Signs build/MonthProgressBar.app for the Mac App Store and wraps it in a signed installer package.
# Needs: DISTRIBUTION_IDENTITY ("Apple Distribution: ..."), INSTALLER_IDENTITY ("3rd Party Mac Developer Installer: ..."),
#        PROVISIONING_PROFILE (Mac App Store profile for com.baumannalexj.monthprogressbar).
set -euo pipefail
cd "$(dirname "$0")"
: "${DISTRIBUTION_IDENTITY:?}" "${INSTALLER_IDENTITY:?}" "${PROVISIONING_PROFILE:?}"

ARCHS="${ARCHS:-arm64 x86_64}" SIGN_IDENTITY="$DISTRIBUTION_IDENTITY" ./script-build-mac.sh
app=build/MonthProgressBar.app
cp "$PROVISIONING_PROFILE" "$app/Contents/embedded.provisionprofile"

profile="$(mktemp)"
security cms -D -i "$PROVISIONING_PROFILE" > "$profile"
team=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.developer.team-identifier" "$profile")
app_id=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.application-identifier" "$profile")
entitlements="$(mktemp).entitlements"
cp Resources/MonthProgressBar.entitlements "$entitlements"
/usr/libexec/PlistBuddy -c "Add :com.apple.application-identifier string $app_id" "$entitlements"
/usr/libexec/PlistBuddy -c "Add :com.apple.developer.team-identifier string $team" "$entitlements"

codesign --force --options runtime --timestamp --entitlements "$entitlements" --sign "$DISTRIBUTION_IDENTITY" "$app"
codesign --verify --strict --verbose=2 "$app"
productbuild --component "$app" /Applications --sign "$INSTALLER_IDENTITY" build/MonthProgressBar.pkg
echo "build/MonthProgressBar.pkg — upload with Transporter, or: xcrun altool --upload-package build/MonthProgressBar.pkg ..."
