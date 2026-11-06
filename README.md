# month-progress-bar

<img width="424" height="46" alt="image" src="https://github.com/user-attachments/assets/0ea3d176-94bf-495e-afc8-092460ccc0d4" />
<img width="384" height="183" alt="image" src="https://github.com/user-attachments/assets/976628c8-01d3-4f5b-8667-809a528400e6" />
<img width="519" height="105" alt="image" src="https://github.com/user-attachments/assets/6972a4ca-53b8-4145-acd6-aa709a07b9cc" />


How far through the month you are, in the macOS menu bar, in one of three themes:

| Theme | Looks like |
|---|---|
| Mac OS X Aqua (default) | glossy striped blue pill + `13/31` |
| macOS progress bar | the system `NSProgressIndicator`, in your accent colour |
| ASCII | `[||||      ]13/31` |

Right-click (or control-click) the item to switch theme. Left-click shows the month, day N of M, days left, and a
Launch at Login toggle. Updates at midnight, on wake, and every 15 minutes. Sandboxed, ready for the Mac App Store.

## Layout

Interfaces first, one-way data flow: every input becomes an `Event`, a pure reducer turns it into the next state,
and subscribers draw or save that state.

```
models/                 MonthProgress (currentDay, currentMonthMaxDay), ThemeID, LoginState
api/                    ITheme, IState, IClock, IStore, IRender, ILaunchAtLogin, Event, Rendering, MenuModel
themes/progressBar/     ascii.swift, native.swift, macaqua.swift: render(currentDay:currentMonthMaxDay:) -> Rendering
app/src/
  clock/                SystemClock: publishes the date at startup and on each new day, no timer
  store/                State, pure Reducer, InMemoryStore
  render/               StatusItemRenderer: the only AppKit view code; menu clicks become events
  persistence/          DefaultsPersistence: theme and preferences in UserDefaults
  login/                SystemLaunchAtLogin
  main/                 composition root: Providers build everything, main.swift only wires
app/tests/
```

```
clock ──dateChanged──▶ store ──state──▶ renderer (draws)
menu  ──themeChanged─▶   │    └──state──▶ persistence (saves)
                     reduce(state, event) -> state   (pure; calls theme.render)
```

A new theme is a type in `themes/progressBar/` conforming to `ITheme`, added to `themes` in
`app/src/main/Providers.swift`.

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
