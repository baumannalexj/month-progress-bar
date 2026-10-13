import AppKit

// The glossy, striped blue "candy" progress bar of Mac OS X Aqua.
struct AquaTheme: ProgressTheme {
    let id = "aqua"
    let name = "Mac OS X Aqua"

    func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        guard let button = item.button else { return }
        button.image = Self.image(fraction: progress.fraction, size: NSSize(width: 72, height: 13))
        button.imagePosition = .imageLeft
        button.attributedTitle = NSAttributedString(string: " " + progress.label, attributes: [.font: menuBarLabelFont])
    }

    static func image(fraction: Double, size: NSSize) -> NSImage {
        NSImage(size: size, flipped: false) { rect in
            let track = rect.insetBy(dx: 0.5, dy: 0.5)
            let radius = track.height / 2
            let trackPath = NSBezierPath(roundedRect: track, xRadius: radius, yRadius: radius)

            NSGradient(colors: [rgb(0.62, 0.62, 0.64), rgb(0.82, 0.82, 0.84), rgb(0.95, 0.95, 0.96)])!
                .draw(in: trackPath, angle: -90)

            let fillWidth = max(track.height, track.width * CGFloat(min(max(fraction, 0), 1)))
            let fill = NSRect(x: track.minX, y: track.minY, width: fillWidth, height: track.height)
            let fillPath = NSBezierPath(roundedRect: fill, xRadius: radius, yRadius: radius)

            NSGraphicsContext.saveGraphicsState()
            fillPath.addClip()
            NSGradient(colorsAndLocations:
                (rgb(0.47, 0.73, 0.98), 0.0),
                (rgb(0.18, 0.50, 0.92), 0.48),
                (rgb(0.07, 0.38, 0.85), 0.52),
                (rgb(0.36, 0.67, 0.98), 1.0))!
                .draw(in: fill, angle: -90)

            let stripe = NSBezierPath()
            let step: CGFloat = 7
            var x = fill.minX - fill.height
            while x < fill.maxX {
                stripe.move(to: NSPoint(x: x, y: fill.minY))
                stripe.line(to: NSPoint(x: x + step / 2, y: fill.minY))
                stripe.line(to: NSPoint(x: x + step / 2 + fill.height, y: fill.maxY))
                stripe.line(to: NSPoint(x: x + fill.height, y: fill.maxY))
                stripe.close()
                x += step
            }
            NSColor(white: 1, alpha: 0.16).setFill()
            stripe.fill()

            let gloss = NSRect(x: fill.minX, y: fill.midY, width: fill.width, height: fill.height / 2)
            NSGradient(colors: [NSColor(white: 1, alpha: 0.55), NSColor(white: 1, alpha: 0.12)])!.draw(in: gloss, angle: -90)
            NSGraphicsContext.restoreGraphicsState()

            rgb(0.18, 0.36, 0.66).setStroke()
            fillPath.lineWidth = 0.5
            fillPath.stroke()
            NSColor(white: 0.42, alpha: 1).setStroke()
            trackPath.lineWidth = 0.5
            trackPath.stroke()
            return true
        }
    }
}

private func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> NSColor {
    NSColor(srgbRed: r, green: g, blue: b, alpha: 1)
}
