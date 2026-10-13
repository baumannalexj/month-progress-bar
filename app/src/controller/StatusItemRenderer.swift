import AppKit
import Api

private let labelFont = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)
private let asciiFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)

private let padding: CGFloat = 6
private let gap: CGFloat = 6
private let systemBarWidth: CGFloat = 64
private let aquaBarSize = NSSize(width: 72, height: 13)

// Lets clicks fall through to the status item button underneath.
private final class PassthroughView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}

private let contentID = NSUserInterfaceItemIdentifier("month-progress-content")

// The only code that decides what the status item looks like.
func apply(_ rendering: Rendering, tooltip: String, to item: NSStatusItem) {
    guard let button = item.button else { return }
    button.subviews.filter { $0.identifier == contentID }.forEach { $0.removeFromSuperview() }
    button.image = nil
    button.imagePosition = .noImage
    button.toolTip = tooltip

    switch rendering {
    case .text(let string):
        item.length = NSStatusItem.variableLength
        button.attributedTitle = NSAttributedString(string: string, attributes: [.font: asciiFont])
    case .aquaBar(let fraction, let label):
        let bar = NSImageView(image: AquaArtwork.image(fraction: fraction, size: aquaBarSize))
        bar.frame.size = aquaBarSize
        show(bar: bar, label: label, in: item)
    case .systemBar(let value, let max, let label):
        show(bar: systemBar(fraction: max > 0 ? value / max : 0), label: label, in: item)
    }
}

// Drawn rather than an NSProgressIndicator, whose track is nearly invisible on the menu bar.
private func systemBar(fraction: Double) -> NSView {
    let height: CGFloat = 6
    let bar = NSView(frame: NSRect(x: 0, y: 0, width: systemBarWidth, height: height))
    let track = NSView(frame: bar.bounds)
    let fill = NSView(frame: NSRect(x: 0, y: 0, width: systemBarWidth * CGFloat(min(Swift.max(fraction, 0), 1)), height: height))
    for (view, color) in [(track, NSColor.labelColor.withAlphaComponent(0.25)), (fill, NSColor.controlAccentColor)] {
        view.wantsLayer = true
        view.layer?.cornerRadius = height / 2
        view.layer?.backgroundColor = color.cgColor
        bar.addSubview(view)
    }
    return bar
}

private func show(bar: NSView, label: String, in item: NSStatusItem) {
    guard let button = item.button else { return }
    button.attributedTitle = NSAttributedString()

    let field = NSTextField(labelWithString: label)
    field.font = labelFont
    field.sizeToFit()

    let width = padding + bar.frame.width + gap + ceil(field.frame.width) + padding
    item.length = width

    // Fixed to the bar's thickness: the button is still zero-sized here, so autoresizing would double-count growth.
    let container = PassthroughView(frame: NSRect(x: 0, y: 0, width: width, height: NSStatusBar.system.thickness))
    container.identifier = contentID

    let centred: (NSView, CGFloat) -> Void = { view, x in
        view.frame.origin = NSPoint(x: x, y: ((container.bounds.height - view.frame.height) / 2).rounded())
        container.addSubview(view)
    }
    centred(bar, padding)
    centred(field, padding + bar.frame.width + gap)
    button.addSubview(container)
}
