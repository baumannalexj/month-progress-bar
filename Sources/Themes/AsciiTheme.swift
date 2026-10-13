import AppKit
import MonthProgress
import Api

public struct AsciiTheme: ProgressTheme {
    public let id = "ascii"
    public let name = "ASCII  [||||    ]"
    private let slots: Int

    public init(slots: Int) { self.slots = slots }

    public func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        item.button?.attributedTitle = NSAttributedString(
            string: AsciiBar.render(progress, slots: slots),
            attributes: [.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)])
    }
}
