import AppKit

let arguments = CommandLine.arguments

if let i = arguments.firstIndex(of: "--print") {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dates = arguments.dropFirst(i + 1).compactMap(formatter.date(from:))
    for date in dates.isEmpty ? [Date()] : dates {
        print(AsciiTheme.bar(MonthProgress(date), slots: Settings.slots))
    }
    exit(0)
}

if let i = arguments.firstIndex(of: "--aqua-png"), i + 2 < arguments.count, let fraction = Double(arguments[i + 1]) {
    let image = AquaTheme.image(fraction: fraction, size: NSSize(width: 72, height: 13))
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: 288, pixelsHigh: 52, bitsPerSample: 8, samplesPerPixel: 4,
                               hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = image.size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    image.draw(in: NSRect(origin: .zero, size: image.size))
    NSGraphicsContext.restoreGraphicsState()
    try rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: arguments[i + 2]))
    exit(0)
}

let app = NSApplication.shared
let controller = StatusController()
app.delegate = controller
app.setActivationPolicy(.accessory)
app.run()
