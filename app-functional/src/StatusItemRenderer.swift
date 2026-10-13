import AppKit
import Artwork
import FunctionalApi

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
        let bar = NSProgressIndicator()
        bar.style = .bar
        bar.controlSize = .small
        bar.isIndeterminate = false
        bar.minValue = 0
        bar.maxValue = max
        bar.doubleValue = value
        bar.frame.size = NSSize(width: systemBarWidth, height: bar.fittingSize.height > 0 ? bar.fittingSize.height : 12)
        show(bar: bar, label: label, in: item)
    }
}

private func show(bar: NSView, label: String, in item: NSStatusItem) {
    guard let button = item.button else { return }
    button.attributedTitle = NSAttributedString()

    let field = NSTextField(labelWithString: label)
    field.font = labelFont
    field.sizeToFit()

    let width = padding + bar.frame.width + gap + ceil(field.frame.width) + padding
    item.length = width

    let container = PassthroughView(frame: NSRect(x: 0, y: 0, width: width, height: button.bounds.height))
    container.identifier = contentID
    container.autoresizingMask = [.width, .height]

    let centred: (NSView, CGFloat) -> Void = { view, x in
        view.frame.origin = NSPoint(x: x, y: ((container.bounds.height - view.frame.height) / 2).rounded())
        view.autoresizingMask = [.minYMargin, .maxYMargin]
        container.addSubview(view)
    }
    centred(bar, padding)
    centred(field, padding + bar.frame.width + gap)
    button.addSubview(container)
}
