import AppKit
import ServiceManagement

struct MonthProgress {
    let day: Int
    let days: Int
    let monthName: String

    init(_ date: Date, calendar: Calendar = .current) {
        day = calendar.component(.day, from: date)
        days = calendar.range(of: .day, in: .month, for: date)!.count
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        monthName = formatter.string(from: date)
    }

    func bar(slots: Int) -> String {
        let filled = min(slots, Int((Double(day) / Double(days) * Double(slots)).rounded()))
        return "[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]\(day)/\(days)"
    }

    var percent: Int { day * 100 / days }
}

final class MonthBar: NSObject, NSApplicationDelegate {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let slots = max(3, UserDefaults.standard.integer(forKey: "slots").nonZero ?? 10)
    private let summary = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let remaining = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    func applicationDidFinishLaunching(_ notification: Notification) {
        let menu = NSMenu()
        [summary, remaining].forEach { $0.isEnabled = false; menu.addItem($0) }
        menu.addItem(.separator())
        loginItem.target = self
        menu.addItem(loginItem)
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu

        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .NSCalendarDayChanged, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(refresh),
                                                          name: NSWorkspace.didWakeNotification, object: nil)
        Timer.scheduledTimer(withTimeInterval: 15 * 60, repeats: true) { [weak self] _ in self?.refresh() }
        refresh()
    }

    @objc private func refresh() {
        let progress = MonthProgress(Date())
        item.button?.attributedTitle = NSAttributedString(
            string: progress.bar(slots: slots),
            attributes: [.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)])
        summary.title = "\(progress.monthName) — day \(progress.day) of \(progress.days) (\(progress.percent)%)"
        let left = progress.days - progress.day
        remaining.title = left == 0 ? "Last day of the month" : "\(left) day\(left == 1 ? "" : "s") left"
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
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

if let i = CommandLine.arguments.firstIndex(of: "--print") {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dates = CommandLine.arguments.dropFirst(i + 1).compactMap(formatter.date(from:))
    for date in dates.isEmpty ? [Date()] : dates {
        print(MonthProgress(date).bar(slots: 10))
    }
    exit(0)
}

let app = NSApplication.shared
let delegate = MonthBar()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
