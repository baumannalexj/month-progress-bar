import AppKit
import Api
import Clock
import Models
import ProgressBarThemes
import Render
import Store
import XCTest

private struct NeverLaunches: ILaunchAtLogin {
    var state: LoginState { .off }
    func toggle() throws {}
}

final class WiringTests: XCTestCase {
    // Clock -> store -> real status item renderer, with the midnight notification posted off main as macOS does.
    func testMidnightOffMainRedrawsTheStatusItemOnMain() {
        let notifications = NotificationCenter()
        let now = FakeNow(date(2026, 10, 13, hour: 23))
        let themes: [ITheme] = [MacAquaTheme(), NativeTheme()]
        let store = InMemoryStore(initial: .awaitingDate(themeID: "native"), reduce: Reducer(themes: themes).reduce)
        let renderer = StatusItemRenderer(statusBar: .system, themes: themes, launchAtLogin: NeverLaunches())
        let clock = SystemClock(notifications: notifications, workspace: NotificationCenter(), calendar: utc,
                                now: { now.value })

        var tooltips: [String] = []
        store.subscribe(renderer.render)
        store.subscribe { state in
            XCTAssertTrue(Thread.isMainThread)
            if case .showing(_, let menu) = state.display { tooltips.append(menu.tooltip) }
        }
        renderer.onEvent(store.send)
        clock.publishDate { store.send(.dateChanged($0)) }

        now.value = date(2026, 10, 14, hour: 0)
        let posted = expectation(description: "posted off main")
        DispatchQueue.global(qos: .userInteractive).async {
            notifications.post(name: .NSCalendarDayChanged, object: nil)
            posted.fulfill()
        }
        wait(for: [posted], timeout: 5)
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        XCTAssertEqual(tooltips, ["October 2026: day 13 of 31", "October 2026: day 14 of 31"])
    }
}
