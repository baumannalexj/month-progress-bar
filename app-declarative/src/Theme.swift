import SwiftUI
import Artwork
import Models

enum Slots {
    static func resolve(_ stored: Int) -> Int { stored == 0 ? 10 : max(3, stored) }
}

extension MonthProgress {
    func asciiBar(slots: Int) -> String {
        let filled = min(slots, Int((fraction * Double(slots)).rounded()))
        return "[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]" + label
    }
}

enum Theme: String, CaseIterable, Identifiable {
    case aqua, native, ascii

    var id: String { rawValue }

    var name: String {
        switch self {
        case .aqua: return "Mac OS X Aqua"
        case .native: return "macOS progress bar"
        case .ascii: return "ASCII  [||||    ]"
        }
    }

    @MainActor @ViewBuilder
    func label(_ progress: MonthProgress, slots: Int) -> some View {
        switch self {
        case .aqua:
            Image(nsImage: AquaArtwork.image(fraction: progress.fraction, size: NSSize(width: 72, height: 13)))
            Text(" " + progress.label)
        case .native:
            NativeBar(fraction: progress.fraction).rasterised()
            Text(" " + progress.label)
        case .ascii:
            Text(progress.asciiBar(slots: slots)).font(.system(size: 12, design: .monospaced))
        }
    }
}

// Drawn with shapes: AppKit-backed ProgressView does not rasterise through ImageRenderer.
private struct NativeBar: View {
    let fraction: Double

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().fill(Color.gray.opacity(0.45))
            Capsule().fill(Color.accentColor).frame(width: 64 * fraction)
        }
        .frame(width: 64, height: 6)
        .padding(.vertical, 3)
    }

    @MainActor
    func rasterised() -> Image {
        let renderer = ImageRenderer(content: self)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2
        return renderer.nsImage.map { Image(nsImage: $0) } ?? Image(systemName: "chart.bar")
    }
}
