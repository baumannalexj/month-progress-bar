import Api
import Models

public struct AsciiTheme: ITheme {
    public let id: ThemeID = "ascii"
    public let name = "ASCII  [||||    ]"
    private let slots: Int

    public init(slots: Int) { self.slots = slots }

    public func render(currentDay: Int, currentMonthMaxDay: Int) -> Rendering {
        let progress = Progress(currentDay: currentDay, currentMonthMaxDay: currentMonthMaxDay)
        let filled = min(slots, Int((progress.fraction * Double(slots)).rounded()))
        return .text("[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]"
                     + progress.label)
    }
}
