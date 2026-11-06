import Api
import CoreGraphics
import Models

// The glossy, striped blue "candy" progress bar of Mac OS X Aqua, drawn with CoreGraphics.
public struct MacAquaTheme: ITheme {
    public let id: ThemeID = "aqua"
    public let name = "Mac OS X Aqua"
    private let size: CGSize
    private let scale: CGFloat

    // Defaults fit the menu bar at 2x; the icon renderer asks for a big one.
    public init(size: CGSize = CGSize(width: 72, height: 13), scale: CGFloat = 2) {
        self.size = size
        self.scale = scale
    }

    public func render(currentDay: Int, currentMonthMaxDay: Int) -> Rendering {
        let progress = Progress(currentDay: currentDay, currentMonthMaxDay: currentMonthMaxDay)
        return .image(pill(fraction: progress.fraction), size: size, label: progress.label)
    }

    private func pill(fraction: Double) -> CGImage {
        let context = CGContext(data: nil, width: Int(size.width * scale), height: Int(size.height * scale),
                                bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.scaleBy(x: scale, y: scale)
        draw(fraction: fraction, in: CGRect(origin: .zero, size: size), context: context)
        return context.makeImage()!
    }

    private func draw(fraction: Double, in rect: CGRect, context: CGContext) {
        let track = rect.insetBy(dx: 0.5, dy: 0.5)
        let radius = track.height / 2
        let trackPath = CGPath(roundedRect: track, cornerWidth: radius, cornerHeight: radius, transform: nil)
        clipped(to: trackPath, context) {
            topToBottom(context, track, [(rgb(0.62, 0.62, 0.64), 0), (rgb(0.82, 0.82, 0.84), 0.5), (rgb(0.95, 0.95, 0.96), 1)])
        }

        let fill = CGRect(x: track.minX, y: track.minY,
                          width: max(track.height, track.width * CGFloat(min(max(fraction, 0), 1))), height: track.height)
        let fillPath = CGPath(roundedRect: fill, cornerWidth: radius, cornerHeight: radius, transform: nil)
        clipped(to: fillPath, context) {
            topToBottom(context, fill, [(rgb(0.47, 0.73, 0.98), 0), (rgb(0.18, 0.50, 0.92), 0.48),
                                        (rgb(0.07, 0.38, 0.85), 0.52), (rgb(0.36, 0.67, 0.98), 1)])
            context.setFillColor(CGColor(gray: 1, alpha: 0.16))
            let step = fill.height / 13 * 7
            for x in stride(from: fill.minX - fill.height, to: fill.maxX, by: step) {
                context.move(to: CGPoint(x: x, y: fill.minY))
                context.addLine(to: CGPoint(x: x + step / 2, y: fill.minY))
                context.addLine(to: CGPoint(x: x + step / 2 + fill.height, y: fill.maxY))
                context.addLine(to: CGPoint(x: x + fill.height, y: fill.maxY))
                context.closePath()
            }
            context.fillPath()
            let gloss = CGRect(x: fill.minX, y: fill.midY, width: fill.width, height: fill.height / 2)
            topToBottom(context, gloss, [(CGColor(gray: 1, alpha: 0.55), 0), (CGColor(gray: 1, alpha: 0.12), 1)])
        }

        context.setLineWidth(0.5)
        context.setStrokeColor(rgb(0.18, 0.36, 0.66))
        context.addPath(fillPath)
        context.strokePath()
        context.setStrokeColor(CGColor(gray: 0.42, alpha: 1))
        context.addPath(trackPath)
        context.strokePath()
    }
}

private func clipped(to path: CGPath, _ context: CGContext, _ body: () -> Void) {
    context.saveGState()
    context.addPath(path)
    context.clip()
    body()
    context.restoreGState()
}

private func topToBottom(_ context: CGContext, _ rect: CGRect, _ stops: [(CGColor, CGFloat)]) {
    let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: stops.map(\.0) as CFArray,
                              locations: stops.map(\.1))!
    context.saveGState()
    context.clip(to: rect)
    context.drawLinearGradient(gradient, start: CGPoint(x: rect.midX, y: rect.maxY), end: CGPoint(x: rect.midX, y: rect.minY),
                               options: [])
    context.restoreGState()
}

private func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> CGColor {
    CGColor(srgbRed: r, green: g, blue: b, alpha: 1)
}
