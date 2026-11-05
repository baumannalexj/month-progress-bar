import AppKit
import XCTest
import Api
import Controller
import Themes

final class StatusControllerTests: XCTestCase {
    // macOS posts NSCalendarDayChanged on a background queue at midnight; AppKit must still only be touched on main.
    func testDayChangePostedOffMainDoesNotTouchAppKitOffMain() {
        let defaults = UserDefaults(suiteName: "month-progress-tests")!
        defaults.removePersistentDomain(forName: "month-progress-tests")
        let settings = Settings(defaults: defaults)
        let controller = StatusController(themes: [aquaTheme(), nativeTheme()], settings: settings,
                                          login: LoginItem(service: .mainApp, settings: settings), statusBar: .system)
        controller.applicationDidFinishLaunching(Notification(name: NSApplication.didFinishLaunchingNotification))

        let posted = expectation(description: "posted from a background queue")
        DispatchQueue.global(qos: .userInteractive).async {
            NotificationCenter.default.post(name: .NSCalendarDayChanged, object: nil)
            posted.fulfill()
        }
        wait(for: [posted], timeout: 5)
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
    }
}
