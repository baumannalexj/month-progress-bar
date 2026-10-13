# mac month progress bar

How far through the month you are, in the macOS menu bar:

```
[||||      ]13/31
```

Native AppKit status item, monospaced so the bar keeps its width. Updates at midnight, on wake, and every 15 minutes.
The menu shows the month, day N of M with a percentage, days left, and a Launch at Login toggle.

## Build and run

Needs the Xcode command line tools (`swiftc`), macOS 13+.

```sh
./build.sh
open build/MonthBar.app
```

Move `build/MonthBar.app` to `~/Applications` before turning on Launch at Login, so the login item points somewhere stable.

## Options

```sh
defaults write com.baumannalexj.monthbar slots -int 20   # bar width, default 10
build/MonthBar.app/Contents/MacOS/MonthBar --print 2026-10-03 2026-10-29   # preview without launching
```
