# month-progress-bar

How far through the month you are, in the macOS menu bar, in one of three themes:

| Theme | Looks like |
|---|---|
| Mac OS X Aqua (default) | glossy striped blue pill + `13/31` |
| macOS progress bar | the system `NSProgressIndicator`, in your accent colour |
| ASCII | `[||||      ]13/31` |

Right-click (or control-click) the item to switch theme. Left-click shows the month, day N of M, days left, and a
Launch at Login toggle. Updates at midnight, on wake, and every 15 minutes.

## Build and install (macOS 13+, Xcode command line tools)

```sh
./script-build-mac.sh      # -> build/MonthProgressBar.app
./script-install-mac.sh    # moves it to ~/Applications and starts it
```

Turn on Launch at Login after installing, so the login item points at `~/Applications`.

## Layout

```
app/
  main.swift              entry point, --print / --aqua-png previews
  MonthProgress.swift     day, days, fraction
  ProgressTheme.swift     the theme interface and registry
  StatusController.swift  status item, menus, refresh
  Themes/                 one adapter per theme
```

A new theme is a type conforming to `ProgressTheme`, added to `Themes.all`.

## Options

```sh
defaults write com.baumannalexj.monthprogressbar slots -int 20       # ASCII bar width, default 10
defaults write com.baumannalexj.monthprogressbar theme -string ascii # aqua | native | ascii
build/MonthProgressBar.app/Contents/MacOS/MonthProgressBar --print 2026-10-03   # ASCII preview
```
