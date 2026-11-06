import AppKit
import Api
import Clock
import Login
import Persistence
import ProgressBarThemes
import Render
import Store

// The only place that calls initializers; everything is built once, on first use, and injected.
final class Providers {
    private let defaults: UserDefaults
    private let statusBar: NSStatusBar
    private let notifications: NotificationCenter
    private let workspace: NotificationCenter
    let calendar: Calendar
    private let now: () -> Date

    init(defaults: UserDefaults, statusBar: NSStatusBar, notifications: NotificationCenter,
         workspace: NotificationCenter, calendar: Calendar, now: @escaping () -> Date) {
        self.defaults = defaults
        self.statusBar = statusBar
        self.notifications = notifications
        self.workspace = workspace
        self.calendar = calendar
        self.now = now
    }

    lazy var persistence = DefaultsPersistence(defaults: defaults)
    lazy var themes: [ITheme] = [MacAquaTheme(), NativeTheme(), AsciiTheme(slots: persistence.slots)]
    lazy var clock: IClock = SystemClock(notifications: notifications, workspace: workspace, calendar: calendar, now: now)
    lazy var store: IStore = InMemoryStore(initial: .awaitingDate(themeID: persistence.themeID),
                                           reduce: Reducer(themes: themes).reduce)
    lazy var launchAtLogin = SystemLaunchAtLogin(service: .mainApp, persistence: persistence)
    lazy var renderer: IRender = StatusItemRenderer(statusBar: statusBar, themes: themes, launchAtLogin: launchAtLogin)
}
