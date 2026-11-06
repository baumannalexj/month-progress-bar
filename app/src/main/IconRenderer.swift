import AppKit
import Api
import ProgressBarThemes

enum IconRenderer {
    static let sizes = [16, 32, 128, 256, 512]

    // macOS icon grid: an 824pt rounded square centred on a 1024pt canvas.
    static func draw(in canvas: NSRect) {
        let scale = canvas.width / 1024
        let tile = NSRect(x: 100 * scale, y: 100 * scale, width: 824 * scale, height: 824 * scale)
        let tilePath = NSBezierPath(roundedRect: tile, xRadius: 185 * scale, yRadius: 185 * scale)

        NSGraphicsContext.saveGraphicsState()
        let shadow = NSShadow()
        shadow.shadowColor = NSColor(white: 0, alpha: 0.28)
        shadow.shadowOffset = NSSize(width: 0, height: -10 * scale)
        shadow.shadowBlurRadius = 24 * scale
        shadow.set()
        NSColor.white.setFill()
        tilePath.fill()
        NSGraphicsContext.restoreGraphicsState()

        NSGradient(colors: [NSColor(srgbRed: 0.97, green: 0.98, blue: 1.0, alpha: 1),
                            NSColor(srgbRed: 0.84, green: 0.88, blue: 0.94, alpha: 1)])!
            .draw(in: tilePath, angle: -90)

        let bar = NSRect(x: tile.minX + 110 * scale, y: tile.midY - 70 * scale, width: tile.width - 220 * scale, height: 140 * scale)
        if case .image(let pill, _, _) = MacAquaTheme(size: bar.size, scale: 1)
            .render(currentDay: 19, currentMonthMaxDay: 31) {
            NSGraphicsContext.current!.cgContext.draw(pill, in: bar)
        }

        let tickY = bar.minY - 90 * scale
        for i in 0..<7 {
            let x = bar.minX + CGFloat(i) * (bar.width - 36 * scale) / 6
            let dot = NSRect(x: x, y: tickY, width: 36 * scale, height: 36 * scale)
            (i < 4 ? NSColor(srgbRed: 0.18, green: 0.50, blue: 0.92, alpha: 1) : NSColor(white: 0.70, alpha: 1)).setFill()
            NSBezierPath(roundedRect: dot, xRadius: 9 * scale, yRadius: 9 * scale).fill()
        }
    }

    static func writeIconset(to directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        for size in sizes {
            for factor in [1, 2] {
                let pixels = size * factor
                let suffix = factor == 1 ? "" : "@2x"
                try png(pixels: pixels).write(to: directory.appendingPathComponent("icon_\(size)x\(size)\(suffix).png"))
            }
        }
    }

    static func png(pixels: Int, draw: (NSRect) -> Void = draw(in:)) -> Data {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                                   samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                                   bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = NSSize(width: pixels, height: pixels)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
        draw(NSRect(x: 0, y: 0, width: pixels, height: pixels))
        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .png, properties: [:])!
    }
}
