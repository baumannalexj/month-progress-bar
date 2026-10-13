import Foundation
import FunctionalApi
import Models

public func aquaTheme() -> ProgressTheme {
    ProgressTheme(id: "aqua", name: "Mac OS X Aqua") { .aquaBar(fraction: $0.fraction, label: $0.label) }
}

public func nativeTheme() -> ProgressTheme {
    ProgressTheme(id: "native", name: "macOS progress bar") {
        .systemBar(value: Double($0.day), max: Double($0.days), label: $0.label)
    }
}

public func asciiTheme(slots: Int) -> ProgressTheme {
    ProgressTheme(id: "ascii", name: "ASCII  [||||    ]") { .text(asciiBar($0, slots: slots)) }
}

public func asciiBar(_ progress: MonthProgress, slots: Int) -> String {
    let filled = min(slots, Int((progress.fraction * Double(slots)).rounded()))
    return "[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]" + progress.label
}
