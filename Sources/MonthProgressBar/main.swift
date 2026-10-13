import AppKit
import Api
import Themes

let arguments = CommandLine.arguments

if let i = arguments.firstIndex(of: "--print") {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dates = arguments.dropFirst(i + 1).compactMap(formatter.date(from:))
    for date in dates.isEmpty ? [Date()] : dates {
        print(AsciiTheme.render(MonthProgress(date), slots: Settings.slots))
    }
    exit(0)
}

if let i = arguments.firstIndex(of: "--iconset"), i + 1 < arguments.count {
    try IconRenderer.writeIconset(to: URL(fileURLWithPath: arguments[i + 1]))
    exit(0)
}

let app = NSApplication.shared
let controller = StatusController()
app.delegate = controller
app.setActivationPolicy(.accessory)
app.run()
