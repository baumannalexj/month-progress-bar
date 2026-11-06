import CoreGraphics

// What a theme wants on screen; the renderer decides how to put it there.
public enum Rendering {
    case text(String)
    case image(CGImage, size: CGSize, label: String)
    case systemBar(fraction: Double, label: String)
}
