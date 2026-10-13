import AppKit
import Api
import Themes
import ServiceManagement
import Models

enum ThemeRegistry {
    static let all: [ProgressTheme] = [AquaTheme(), NativeTheme(), AsciiTheme(slots: Settings.slots)]

    static func named(_ id: String?) -> ProgressTheme {
        all.first { $0.id == id } ?? all[0]
    }
}

enum Settings {
    static var slots: Int { max(3, UserDefaults.standard.integer(forKey: "slots").nonZero ?? 10) }

    static var theme: ProgressTheme {
        get { ThemeRegistry.named(UserDefaults.standard.string(forKey: "theme")) }
        set { UserDefaults.standard.set(newValue.id, forKey: "theme") }
    }
}

// Left click: month details. Right click (or control-click): pick a theme.
final class StatusController: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let infoMenu = NSMenu()
    private let themeMenu = NSMenu()
    private let summary = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let remaining = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        [summary, remaining].forEach { $0.isEnabled = false; infoMenu.addItem($0) }
        infoMenu.addItem(.separator())
        let style = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
        style.submenu = buildThemeMenu()
        infoMenu.addItem(style)
        loginItem.target = self
        infoMenu.addItem(loginItem)
        infoMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        themeMenu.items = buildThemeMenu().items.map { $0.copy() as! NSMenuItem }

        item.button?.target = self
        item.button?.action = #selector(clicked)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .NSCalendarDayChanged, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in self?.refresh() }
        refresh()
    }

    private func buildThemeMenu() -> NSMenu {
        let menu = NSMenu()
        for theme in ThemeRegistry.all {
            let entry = NSMenuItem(title: theme.name, action: #selector(chooseTheme(_:)), keyEquivalent: "")
            entry.target = self
            entry.representedObject = theme.id
            menu.addItem(entry)
        }
        return menu
    }

    @objc private func clicked() {
        let event = NSApp.currentEvent
        let wantsThemes = event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true
        item.menu = wantsThemes ? themeMenu : infoMenu
        item.button?.performClick(nil)
        item.menu = nil
    }

    @objc private func chooseTheme(_ sender: NSMenuItem) {
        Settings.theme = ThemeRegistry.named(sender.representedObject as? String)
        refresh()
    }

    @objc func refresh() {
        let progress = MonthProgress(Date())
        let theme = Settings.theme
        item.resetForTheme()
        theme.apply(progress, to: item)
        item.button?.toolTip = "\(progress.monthName): day \(progress.day) of \(progress.days)"

        summary.title = "\(progress.monthName) — day \(progress.day) of \(progress.days) (\(progress.percent)%)"
        remaining.title = progress.daysLeft == 0 ? "Last day of the month"
            : "\(progress.daysLeft) day\(progress.daysLeft == 1 ? "" : "s") left"
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        for menu in [themeMenu, infoMenu.items.first { $0.submenu != nil }?.submenu].compactMap({ $0 }) {
            menu.items.forEach { $0.state = ($0.representedObject as? String) == theme.id ? .on : .off }
        }
    }

    @objc private func toggleLogin() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSAlert(error: error).runModal()
        }
        refresh()
    }
}

private extension Int {
    var nonZero: Int? { self == 0 ? nil : self }
}
