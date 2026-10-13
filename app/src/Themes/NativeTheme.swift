import AppKit
import Api
import Models

// The system NSProgressIndicator, live in the menu bar, tinted with the user's accent colour.
public struct NativeTheme: ProgressTheme {
    public let id = "native"
    public let name = "macOS progress bar"

    public init() {}

    private let barWidth: CGFloat = 64
    private let edgePadding: CGFloat = 6
    private let gap: CGFloat = 6

    public func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        guard let button = item.button else { return }

        let label = NSTextField(labelWithString: progress.label)
        label.identifier = NSStatusItem.themeViewID
        label.font = menuBarLabelFont
        label.textColor = .labelColor
        label.sizeToFit()
        let labelSize = label.frame.size

        item.length = edgePadding + barWidth + gap + ceil(labelSize.width) + edgePadding

        let height = max(button.bounds.height, labelSize.height)
        let barHeight: CGFloat = 6
        let barY = ((height - barHeight) / 2).rounded()

        let track = NSView(frame: NSRect(x: edgePadding, y: barY, width: barWidth, height: barHeight))
        track.identifier = NSStatusItem.themeViewID
        track.wantsLayer = true
        track.layer?.cornerRadius = barHeight / 2
        track.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.25).cgColor
        button.addSubview(track)

        let fraction = progress.days > 0 ? CGFloat(progress.day) / CGFloat(progress.days) : 0
        let fill = NSView(frame: NSRect(x: edgePadding, y: barY, width: barWidth * min(max(fraction, 0), 1), height: barHeight))
        fill.identifier = NSStatusItem.themeViewID
        fill.wantsLayer = true
        fill.layer?.cornerRadius = barHeight / 2
        fill.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
        button.addSubview(fill)

        label.frame.origin = NSPoint(
            x: edgePadding + barWidth + gap,
            y: ((height - labelSize.height) / 2).rounded()
        )
        button.addSubview(label)
    }
}
