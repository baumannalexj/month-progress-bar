import Api
import Models
import XCTest

final class MonthProgressTests: XCTestCase {
    func testDaysInMonthIncludingLeapFebruary() {
        XCTAssertEqual(progress(2026, 10, 13).currentMonthMaxDay, 31)
        XCTAssertEqual(progress(2026, 2, 10).currentMonthMaxDay, 28)
        XCTAssertEqual(progress(2028, 2, 10).currentMonthMaxDay, 29)
    }

    func testMenuWording() {
        let menu = MenuModel(progress(2026, 10, 13))
        XCTAssertEqual(menu.summary, "October 2026 — day 13 of 31 (41%)")
        XCTAssertEqual(menu.remaining, "18 days left")
        XCTAssertEqual(menu.tooltip, "October 2026: day 13 of 31")
        XCTAssertEqual(MenuModel(progress(2026, 10, 30)).remaining, "1 day left")
        XCTAssertEqual(MenuModel(progress(2026, 10, 31)).remaining, "Last day of the month")
    }
}
