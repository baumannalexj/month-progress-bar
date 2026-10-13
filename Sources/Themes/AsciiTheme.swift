import AppKit
import Api

public struct AsciiTheme: ProgressTheme {
    public let id = "ascii"
    public let name = "ASCII  [||||    ]"
    private let slots: Int

    public init(slots: Int) { self.slots = slots }

    public func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        item.button?.attributedTitle = NSAttributedString(
            string: Self.render(progress, slots: slots),
            attributes: [.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)])
    }

    public static func render(_ progress: MonthProgress, slots: Int) -> String {
        let filled = min(slots, Int((progress.fraction * Double(slots)).rounded()))
        return "[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]" + progress.label
    }
}
