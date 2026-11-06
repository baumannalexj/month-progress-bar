import AppKit
import Api
import Models

// The only AppKit code: draws the state into the status item, and turns menu clicks into events.
// Left click opens month details; right click (or control-click) opens the theme list.
public final class StatusItemRenderer: NSObject, IRender, NSMenuDelegate {
    private let item: NSStatusItem
    private let themes: [ITheme]
    private let launchAtLogin: ILaunchAtLogin
    private var handler: (Event) -> Void = { _ in }

    private let infoMenu = NSMenu()
    private let themeMenu = NSMenu()
    private let styleMenu = NSMenu()
    private let summary = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let remaining = NSMenuItem(title: "", action: nil, keyEquivalent: "")
    private let loginItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLogin), keyEquivalent: "")

    public init(statusBar: NSStatusBar, themes: [ITheme], launchAtLogin: ILaunchAtLogin) {
        item = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        self.themes = themes
        self.launchAtLogin = launchAtLogin
        super.init()
        buildMenus()
    }

    public func onEvent(_ handler: @escaping (Event) -> Void) {
        self.handler = handler
    }

    public func render(_ state: IState) {
        for menu in [themeMenu, styleMenu] {
            menu.items.forEach { $0.state = ($0.representedObject as? String) == state.themeID.rawValue ? .on : .off }
        }
        switch state.display {
        case .blank:
            clear()
        case .showing(let rendering, let menu):
            draw(rendering)
            item.button?.toolTip = menu.tooltip
            summary.title = menu.summary
            remaining.title = menu.remaining
        }
    }

    public func menuNeedsUpdate(_ menu: NSMenu) {
        switch launchAtLogin.state {
        case .on: (loginItem.title, loginItem.state) = ("Launch at Login", .on)
        case .off: (loginItem.title, loginItem.state) = ("Launch at Login", .off)
        case .needsApproval: (loginItem.title, loginItem.state) = ("Launch at Login — approve in System Settings…", .mixed)
        }
    }

    private func buildMenus() {
        for menu in [styleMenu, themeMenu] {
            for theme in themes {
                let entry = NSMenuItem(title: theme.name, action: #selector(chooseTheme(_:)), keyEquivalent: "")
                entry.target = self
                entry.representedObject = theme.id.rawValue
                menu.addItem(entry)
            }
        }
        [summary, remaining].forEach { $0.isEnabled = false; infoMenu.addItem($0) }
        infoMenu.addItem(.separator())
        let style = NSMenuItem(title: "Style", action: nil, keyEquivalent: "")
        style.submenu = styleMenu
        infoMenu.addItem(style)
        loginItem.target = self
        infoMenu.addItem(loginItem)
        infoMenu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        infoMenu.delegate = self

        item.button?.target = self
        item.button?.action = #selector(clicked)
        item.button?.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func clicked() {
        let event = NSApp.currentEvent
        let wantsThemes = event?.type == .rightMouseUp || event?.modifierFlags.contains(.control) == true
        item.menu = wantsThemes ? themeMenu : infoMenu
        item.button?.performClick(nil)
        item.menu = nil
    }

    @objc private func chooseTheme(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        handler(.themeChanged(ThemeID(id)))
    }

    @objc private func toggleLogin() {
        do { try launchAtLogin.toggle() } catch { NSAlert(error: error).runModal() }
    }

    // MARK: drawing

    private static let contentID = NSUserInterfaceItemIdentifier("month-progress-content")
    private static let labelFont = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)
    private static let asciiFont = NSFont.monospacedSystemFont(ofSize: NSFont.systemFontSize - 1, weight: .regular)
    private static let padding: CGFloat = 6
    private static let gap: CGFloat = 6
    private static let systemBarWidth: CGFloat = 64

    private func clear() {
        guard let button = item.button else { return }
        button.subviews.filter { $0.identifier == Self.contentID }.forEach { $0.removeFromSuperview() }
        button.image = nil
        button.imagePosition = .noImage
        button.attributedTitle = NSAttributedString()
        item.length = NSStatusItem.variableLength
    }

    private func draw(_ rendering: Rendering) {
        clear()
        switch rendering {
        case .text(let string):
            item.button?.attributedTitle = NSAttributedString(string: string, attributes: [.font: Self.asciiFont])
        case .image(let image, let size, let label):
            let view = NSImageView(image: NSImage(cgImage: image, size: size))
            view.frame.size = size
            show(bar: view, label: label)
        case .systemBar(let fraction, let label):
            show(bar: Self.systemBar(fraction: fraction), label: label)
        }
    }

    // Drawn rather than an NSProgressIndicator, whose track is nearly invisible on the menu bar.
    private static func systemBar(fraction: Double) -> NSView {
        let height: CGFloat = 6
        let bar = NSView(frame: NSRect(x: 0, y: 0, width: systemBarWidth, height: height))
        let filled = systemBarWidth * CGFloat(min(max(fraction, 0), 1))
        for (frame, color) in [(bar.bounds, NSColor.labelColor.withAlphaComponent(0.25)),
                               (NSRect(x: 0, y: 0, width: filled, height: height), NSColor.controlAccentColor)] {
            let view = NSView(frame: frame)
            view.wantsLayer = true
            view.layer?.cornerRadius = height / 2
            view.layer?.backgroundColor = color.cgColor
            bar.addSubview(view)
        }
        return bar
    }

    private func show(bar: NSView, label: String) {
        guard let button = item.button else { return }
        let field = NSTextField(labelWithString: label)
        field.font = Self.labelFont
        field.sizeToFit()

        let width = Self.padding + bar.frame.width + Self.gap + ceil(field.frame.width) + Self.padding
        item.length = width
        // Fixed to the bar's thickness: the button can still be zero-sized here, so autoresizing would misplace content.
        let container = PassthroughView(frame: NSRect(x: 0, y: 0, width: width, height: NSStatusBar.system.thickness))
        container.identifier = Self.contentID
        for (view, x) in [(bar, Self.padding), (field, Self.padding + bar.frame.width + Self.gap)] {
            view.frame.origin = NSPoint(x: x, y: ((container.bounds.height - view.frame.height) / 2).rounded())
            container.addSubview(view)
        }
        button.addSubview(container)
    }
}

// Lets clicks fall through to the status item button underneath.
private final class PassthroughView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? { nil }
}
