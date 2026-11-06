import AppKit
import Api
import Models

// No timer: macOS posts the day change at midnight (on a background queue) and we catch wakes that slept past it.
public final class SystemClock: IClock {
    private let notifications: NotificationCenter
    private let workspace: NotificationCenter
    private let calendar: Calendar
    private let now: () -> Date
    private var tokens: [NSObjectProtocol] = []

    public init(notifications: NotificationCenter, workspace: NotificationCenter, calendar: Calendar,
                now: @escaping () -> Date) {
        self.notifications = notifications
        self.workspace = workspace
        self.calendar = calendar
        self.now = now
    }

    public func publishDate(_ subscriber: @escaping (MonthProgress) -> Void) {
        let read = { [now, calendar] in MonthProgress(now(), calendar: calendar) }
        var last = read()
        subscriber(last)
        let check = {
            let current = read()
            guard current != last else { return }
            last = current
            subscriber(current)
        }
        tokens += [
            notifications.addObserver(forName: .NSCalendarDayChanged, object: nil, queue: .main) { _ in check() },
            workspace.addObserver(forName: NSWorkspace.didWakeNotification, object: nil, queue: .main) { _ in check() },
        ]
    }
}
