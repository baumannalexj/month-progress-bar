import AppKit
import MonthProgress
import ThemeApi

// The system NSProgressIndicator, live in the menu bar, tinted with the user's accent colour.
public struct NativeTheme: ProgressTheme {
    public let id = "native"
    public let name = "macOS progress bar"

    public init() {}

    private let barWidth: CGFloat = 64

    public func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        guard let button = item.button else { return }
        let label = " " + progress.label + " "
        let labelWidth = (label as NSString).size(withAttributes: [.font: menuBarLabelFont]).width
        item.length = 6 + barWidth + 4 + labelWidth

        let indicator = NSProgressIndicator()
        indicator.identifier = NSStatusItem.themeViewID
        indicator.style = .bar
        indicator.controlSize = .small
        indicator.isIndeterminate = false
        indicator.minValue = 0
        indicator.maxValue = Double(progress.days)
        indicator.doubleValue = Double(progress.day)
        let height = indicator.fittingSize.height > 0 ? indicator.fittingSize.height : 12
        indicator.frame = NSRect(x: 6, y: (button.bounds.height - height) / 2, width: barWidth, height: height)
        button.addSubview(indicator)

        button.alignment = .right
        button.attributedTitle = NSAttributedString(string: label, attributes: [.font: menuBarLabelFont])
    }
}
