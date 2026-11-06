import Api
import Models
import ProgressBarThemes
import Store
import XCTest

final class StoreTests: XCTestCase {
    private func store() -> InMemoryStore {
        InMemoryStore(initial: .awaitingDate(themeID: "ascii"), reduce: Reducer(themes: [AsciiTheme(slots: 10)]).reduce)
    }

    func testSubscriberGetsCurrentStateRightAway() {
        var seen: [ThemeID] = []
        store().subscribe { seen.append($0.themeID) }
        XCTAssertEqual(seen, ["ascii"])
    }

    func testOnlyRealChangesNotify() {
        let store = store()
        var notified = 0
        store.subscribe { _ in notified += 1 }
        store.send(.dateChanged(progress(2026, 10, 13)))
        store.send(.dateChanged(progress(2026, 10, 13)))
        store.send(.themeChanged("ascii"))
        XCTAssertEqual(notified, 2)  // the initial call, then the first date
    }

    func testEventsSentWhileNotifyingAreQueuedInOrder() {
        let store = store()
        var days: [String] = []
        store.subscribe { state in
            guard case .showing(_, let menu) = state.display else { return }
            days.append(menu.tooltip)
            if menu.tooltip.hasSuffix("day 13 of 31") { store.send(.dateChanged(progress(2026, 10, 14))) }
        }
        var later: [String] = []
        store.subscribe { state in
            if case .showing(_, let menu) = state.display { later.append(menu.tooltip) }
        }
        store.send(.dateChanged(progress(2026, 10, 13)))
        XCTAssertEqual(days, ["October 2026: day 13 of 31", "October 2026: day 14 of 31"])
        XCTAssertEqual(later, days)
    }
}
