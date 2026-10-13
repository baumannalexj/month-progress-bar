import AppKit
import Api
import Artwork
import Models

public struct AquaTheme: ProgressTheme {
    public let id = "aqua"
    public let name = "Mac OS X Aqua"

    public init() {}

    public func apply(_ progress: MonthProgress, to item: NSStatusItem) {
        guard let button = item.button else { return }
        button.image = AquaArtwork.image(fraction: progress.fraction, size: NSSize(width: 72, height: 13))
        button.imagePosition = .imageLeft
        button.attributedTitle = NSAttributedString(string: " " + progress.label, attributes: [.font: menuBarLabelFont])
    }
}
