import XCTest
import Themes
import Models

final class MonthProgressTests: XCTestCase {
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func progress(_ iso: String) -> MonthProgress {
        MonthProgress(ISO8601DateFormatter().date(from: iso + "T12:00:00Z")!, calendar: utc)
    }

    func testCountsDaysInMonth() {
        XCTAssertEqual(progress("2026-10-13").days, 31)
        XCTAssertEqual(progress("2026-02-10").days, 28)
        XCTAssertEqual(progress("2028-02-10").days, 29)
    }

    func testAsciiBarRoundsToNearestSlot() {
        XCTAssertEqual(AsciiTheme.render(progress("2026-10-03"), slots: 10), "[|         ]3/31")
        XCTAssertEqual(AsciiTheme.render(progress("2026-10-13"), slots: 10), "[||||      ]13/31")
        XCTAssertEqual(AsciiTheme.render(progress("2026-10-31"), slots: 10), "[||||||||||]31/31")
    }

    func testDaysLeftAndPercent() {
        let p = progress("2026-10-13")
        XCTAssertEqual(p.daysLeft, 18)
        XCTAssertEqual(p.percent, 41)
    }
}
