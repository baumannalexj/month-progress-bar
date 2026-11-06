import Api
import Models
import ProgressBarThemes
import Store
import XCTest

final class ReducerTests: XCTestCase {
    private let reducer = Reducer(themes: [MacAquaTheme(), AsciiTheme(slots: 10)])

    private func asciiText(_ state: State) -> String? {
        guard case .showing(.text(let string), _) = state.display else { return nil }
        return string
    }

    func testFirstDateStartsRunningWithTheChosenTheme() {
        let state = reducer.reduce(.awaitingDate(themeID: "ascii"), .dateChanged(progress(2026, 10, 13)))
        XCTAssertEqual(state, .running(progress: progress(2026, 10, 13), themeID: "ascii", rendering: .text("")))
        XCTAssertEqual(asciiText(state), "[||||      ]13/31")
    }

    func testNextDayRendersTheNewDay() {
        let today = reducer.reduce(.awaitingDate(themeID: "ascii"), .dateChanged(progress(2026, 10, 13)))
        let tomorrow = reducer.reduce(today, .dateChanged(progress(2026, 10, 14)))
        XCTAssertEqual(asciiText(tomorrow), "[|||||     ]14/31")
    }

    func testThemeChangeRerendersTheSameDay() {
        let aqua = reducer.reduce(.awaitingDate(themeID: "aqua"), .dateChanged(progress(2026, 10, 13)))
        let ascii = reducer.reduce(aqua, .themeChanged("ascii"))
        XCTAssertEqual(ascii.themeID, "ascii")
        XCTAssertEqual(asciiText(ascii), "[||||      ]13/31")
    }

    func testUnknownThemeFallsBackToTheFirst() {
        XCTAssertEqual(reducer.reduce(.awaitingDate(themeID: "gone"), .themeChanged("gone")).themeID, "aqua")
    }
}
