import XCTest
import Api
import Themes
import Models

final class MonthProgressTests: XCTestCase {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()

    private func progress(_ year: Int, _ month: Int, _ day: Int) -> MonthProgress {
        let date = calendar.date(from: DateComponents(year: year, month: month, day: day, hour: 12))!
        return MonthProgress(date, calendar: calendar)
    }

    func testAquaRendersFractionAndLabel() {
        XCTAssertEqual(aquaTheme().render(progress(2026, 10, 13)), .aquaBar(fraction: 13.0 / 31.0, label: "13/31"))
    }

    func testNativeRendersValueMaxAndLabel() {
        XCTAssertEqual(nativeTheme().render(progress(2026, 10, 13)), .systemBar(value: 13, max: 31, label: "13/31"))
    }

    func testAsciiRoundsToNearestSlot() {
        XCTAssertEqual(asciiBar(progress(2026, 10, 3), slots: 10), "[|         ]3/31")
        XCTAssertEqual(asciiBar(progress(2026, 10, 13), slots: 10), "[||||      ]13/31")
    }

    func testAsciiFullOnLastDay() {
        XCTAssertEqual(asciiBar(progress(2026, 10, 31), slots: 10), "[||||||||||]31/31")
    }

    func testAsciiHonoursSlotCount() {
        XCTAssertEqual(asciiBar(progress(2026, 10, 31), slots: 4), "[||||]31/31")
    }

    func testAsciiThemeWrapsBar() {
        XCTAssertEqual(asciiTheme(slots: 10).render(progress(2026, 10, 13)), .text("[||||      ]13/31"))
    }

    func testThemeIdentities() {
        XCTAssertEqual([aquaTheme(), nativeTheme(), asciiTheme(slots: 10)].map(\.id), ["aqua", "native", "ascii"])
        XCTAssertEqual([aquaTheme(), nativeTheme(), asciiTheme(slots: 10)].map(\.name),
                       ["Mac OS X Aqua", "macOS progress bar", "ASCII  [||||    ]"])
    }

    func testLeapYearFebruary() {
        let leapDay = progress(2028, 2, 29)
        XCTAssertEqual(leapDay.days, 29)
        XCTAssertEqual(asciiBar(leapDay, slots: 10), "[||||||||||]29/29")
        XCTAssertEqual(progress(2026, 2, 28).days, 28)
    }

    func testMenuModelSummaryAndTooltip() {
        let model = menuModel(for: progress(2026, 10, 13))
        XCTAssertEqual(model.summary, "October 2026 — day 13 of 31 (41%)")
        XCTAssertEqual(model.tooltip, "October 2026: day 13 of 31")
        XCTAssertEqual(model.remaining, "18 days left")
    }

    func testRemainingWording() {
        XCTAssertEqual(menuModel(for: progress(2026, 10, 30)).remaining, "1 day left")
        XCTAssertEqual(menuModel(for: progress(2026, 10, 31)).remaining, "Last day of the month")
    }
}
