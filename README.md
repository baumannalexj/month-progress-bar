# month-progress-bar

How far through the month you are, in the macOS menu bar, in one of three themes:

| Theme | Looks like |
|---|---|
| Mac OS X Aqua (default) | glossy striped blue pill + `13/31` |
| macOS progress bar | the system `NSProgressIndicator`, in your accent colour |
| ASCII | `[||||      ]13/31` |

Right-click (or control-click) the item to switch theme. Left-click shows the month, day N of M, days left, and a
Launch at Login toggle. Updates at midnight, on wake, and every 15 minutes. Sandboxed, ready for the Mac App Store.

## Layout

```
Package.swift
Sources/
  Models/             domain models, no dependencies: MonthProgress (day/days/fraction)
  Api/                ports on Models: the ProgressTheme interface, shared status-item helpers
  Themes/             adapters on Api: AquaTheme, NativeTheme, AsciiTheme
  MonthProgressBar/   the app and composition root: main, StatusController, ThemeRegistry, IconRenderer
Tests/MonthProgressTests/
Resources/            Info.plist, sandbox entitlements, AppIcon.icns
script-*-mac.sh
```

A new theme is a type in `Themes/` conforming to `ProgressTheme`, added to `ThemeRegistry.all`.

## Build, test, install (macOS 13+, Xcode or its command line tools)

```sh
swift test
./script-build-mac.sh       # -> build/MonthProgressBar.app (ad-hoc signed, sandboxed)
./script-install-mac.sh     # moves it to ~/Applications and starts it
./script-icon-mac.sh        # regenerates Resources/AppIcon.icns from IconRenderer.swift
```

`swift build` output goes to `.build/`; the assembled app to `build/`. Both are gitignored.

## Mac App Store

```sh
DISTRIBUTION_IDENTITY="Apple Distribution: …" \
INSTALLER_IDENTITY="3rd Party Mac Developer Installer: …" \
PROVISIONING_PROFILE=~/Downloads/MonthProgressBar.provisionprofile \
./script-package-appstore-mac.sh    # -> build/MonthProgressBar.pkg, then upload with Transporter
```

Not yet run end to end: it needs an Apple Developer Program membership, the two certificates above in the
login keychain, the bundle ID `com.baumannalexj.monthprogressbar` registered, and an App Store Connect app
record. Builds universal (`arm64 x86_64`) by default.

## Options

The app is sandboxed, so its preferences live in its container:

```sh
defaults write ~/Library/Containers/com.baumannalexj.monthprogressbar/Data/Library/Preferences/com.baumannalexj.monthprogressbar slots -int 20
"$(swift build -c release --show-bin-path)/MonthProgressBar" --print 2026-10-03   # ASCII preview
```
