import AppKit
import Clock
import Models
import XCTest

final class ClockTests: XCTestCase {
    private let notifications = NotificationCenter()
    private let workspace = NotificationCenter()

    private func clock(_ now: FakeNow) -> SystemClock {
        SystemClock(notifications: notifications, workspace: workspace, calendar: utc, now: { now.value })
    }

    private func settle() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.2))
    }

    func testPublishesTodayOnStartup() {
        var days: [Int] = []
        clock(FakeNow(date(2026, 10, 13))).publishDate { days.append($0.currentDay) }
        XCTAssertEqual(days, [13])
    }

    func testPublishesTheNextDayAtMidnight() {
        let now = FakeNow(date(2026, 10, 13, hour: 23))
        var days: [Int] = []
        let clock = clock(now)
        clock.publishDate { days.append($0.currentDay) }

        now.value = date(2026, 10, 14, hour: 0)
        notifications.post(name: .NSCalendarDayChanged, object: nil)
        settle()
        XCTAssertEqual(days, [13, 14])
    }

    func testRollsIntoTheNextMonth() {
        let now = FakeNow(date(2026, 10, 31, hour: 23))
        var seen: [String] = []
        let clock = clock(now)
        clock.publishDate { seen.append("\($0.currentDay)/\($0.currentMonthMaxDay)") }

        now.value = date(2026, 11, 1, hour: 0)
        notifications.post(name: .NSCalendarDayChanged, object: nil)
        settle()
        XCTAssertEqual(seen, ["31/31", "1/30"])
    }

    func testWakeOnTheSameDayPublishesNothing() {
        var days: [Int] = []
        let clock = clock(FakeNow(date(2026, 10, 13)))
        clock.publishDate { days.append($0.currentDay) }
        workspace.post(name: NSWorkspace.didWakeNotification, object: nil)
        settle()
        XCTAssertEqual(days, [13])
    }

    func testWakeAfterSleepingThroughMidnightPublishesTheNewDay() {
        let now = FakeNow(date(2026, 10, 13, hour: 22))
        var days: [Int] = []
        let clock = clock(now)
        clock.publishDate { days.append($0.currentDay) }
        now.value = date(2026, 10, 14, hour: 7)
        workspace.post(name: NSWorkspace.didWakeNotification, object: nil)
        settle()
        XCTAssertEqual(days, [13, 14])
    }

    // The original crash: macOS posts the day change on a background queue at midnight.
    func testDayChangePostedOffMainArrivesOnMain() {
        let now = FakeNow(date(2026, 10, 13, hour: 23))
        var onMain: [Bool] = []
        let clock = clock(now)
        clock.publishDate { _ in onMain.append(Thread.isMainThread) }

        now.value = date(2026, 10, 14, hour: 0)
        let posted = expectation(description: "posted off main")
        DispatchQueue.global(qos: .userInteractive).async {
            self.notifications.post(name: .NSCalendarDayChanged, object: nil)
            posted.fulfill()
        }
        wait(for: [posted], timeout: 5)
        settle()
        XCTAssertEqual(onMain, [true, true])
    }
}
