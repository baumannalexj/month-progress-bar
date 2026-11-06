import Api
import ProgressBarThemes
import XCTest

final class ThemeTests: XCTestCase {
    private func text(_ rendering: Rendering) -> String? {
        if case .text(let string) = rendering { return string }
        return nil
    }

    func testAsciiRoundsToNearestSlot() {
        let ascii = AsciiTheme(slots: 10)
        XCTAssertEqual(text(ascii.render(currentDay: 3, currentMonthMaxDay: 31)), "[|         ]3/31")
        XCTAssertEqual(text(ascii.render(currentDay: 13, currentMonthMaxDay: 31)), "[||||      ]13/31")
        XCTAssertEqual(text(ascii.render(currentDay: 31, currentMonthMaxDay: 31)), "[||||||||||]31/31")
    }

    func testAsciiHonoursSlotCount() {
        XCTAssertEqual(text(AsciiTheme(slots: 4).render(currentDay: 31, currentMonthMaxDay: 31)), "[||||]31/31")
    }

    func testNativeIsFractionAndLabel() {
        guard case .systemBar(let fraction, let label) = NativeTheme().render(currentDay: 13, currentMonthMaxDay: 31) else {
            return XCTFail("expected a system bar")
        }
        XCTAssertEqual(fraction, 13.0 / 31.0, accuracy: 1e-9)
        XCTAssertEqual(label, "13/31")
    }

    func testMacAquaIsARetinaImageWithLabel() {
        guard case .image(let image, let size, let label) = MacAquaTheme().render(currentDay: 13, currentMonthMaxDay: 31) else {
            return XCTFail("expected an image")
        }
        XCTAssertEqual(size, CGSize(width: 72, height: 13))
        XCTAssertEqual(image.width, 144)
        XCTAssertEqual(image.height, 26)
        XCTAssertEqual(label, "13/31")
    }
}
