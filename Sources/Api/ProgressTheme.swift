import AppKit

// Draws month progress into the status item. Themes own everything they put on the button;
// the controller resets the button between themes.
public protocol ProgressTheme {
    var id: String { get }
    var name: String { get }
    func apply(_ progress: MonthProgress, to item: NSStatusItem)
}

public extension NSStatusItem {
    static let themeViewID = NSUserInterfaceItemIdentifier("month-progress-theme-view")

    func resetForTheme() {
        length = NSStatusItem.variableLength
        guard let button else { return }
        button.subviews.filter { $0.identifier == NSStatusItem.themeViewID }.forEach { $0.removeFromSuperview() }
        button.image = nil
        button.title = ""
        button.attributedTitle = NSAttributedString()
        button.alignment = .center
        button.imagePosition = .noImage
    }
}

public let menuBarLabelFont = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)
