import AppKit

struct AsciiTheme: ProgressTheme {
    let id = "ascii"
    let name = "ASCII  [||||    ]"

    func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        item.button?.attributedTitle = NSAttributedString(
            string: Self.bar(progress, slots: Settings.slots),
            attributes: [.font: NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)])
    }

    static func bar(_ progress: MonthProgress, slots: Int) -> String {
        let filled = min(slots, Int((progress.fraction * Double(slots)).rounded()))
        return "[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]" + progress.label
    }
}
