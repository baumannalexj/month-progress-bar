import AppKit
import FunctionalApi
import Models
import ServiceManagement

// Left click: month details. Right click (or control-click): pick a theme.
final class StatusController: NSObject, NSApplicationDelegate {
    private let themes: [ProgressTheme]
    private let settings: Settings
    private let item: NSStatusItem
    private let infoMenu = NSMenu()
    private let themeMenu = NSMenu()
    private let styleMenu = NSMenu()
    private let summary = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let remaining = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    init(themes: [ProgressTheme], settings: Settings, statusBar: NSStatusBar) {
        self.themes = themes
        self.settings = settings
        item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
    }

    private var theme: ProgressTheme {
        themes.first { $0.id == settings.themeID } ?? themes[0]
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        populateThemeEntries(in: styleMenu)
        populateThemeEntries(in: themeMenu)

        [summary, remaining].forEach { $0.isEnabled = false; infoMenu.addItem($0) }
        infoMenu.addItem(.separator())
        let style = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
        style.submenu = styleMenu
        infoMenu.addItem(style)
        loginItem.target = self
        infoMenu.addItem(loginItem)
        infoMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        item.button?.target = self
        item.button?.action = #selector(clicked)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .NSCalendarDayChanged, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in self?.refresh() }
        refresh()
    }

    private func populateThemeEntries(in menu: NSMenu) {
        for theme in themes {
            let entry = NSMenuItem(title: theme.name, action: #selector(chooseTheme(_:)), keyEquivalent: "")
            entry.target = self
            entry.representedObject = theme.id
            menu.addItem(entry)
        }
    }

    @objc private func clicked() {
        let event = NSApp.currentEvent
        let wantsThemes = event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true
        item.menu = wantsThemes ? themeMenu : infoMenu
        item.button?.performClick(nil)
        item.menu = nil
    }

    @objc private func chooseTheme(_ sender: NSMenuItem) {
        settings.themeID = sender.representedObject as? String
        refresh()
    }

    @objc func refresh() {
        let progress = MonthProgress(Date())
        let theme = self.theme
        let model = menuModel(for: progress)

        apply(theme.render(progress), tooltip: model.tooltip, to: item)

        summary.title = model.summary
        remaining.title = model.remaining
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        for menu in [themeMenu, styleMenu] {
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
