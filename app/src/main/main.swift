import AppKit
import Api
import Themes
import Controller
import Models

let arguments = CommandLine.arguments
let settings = Settings(defaults: .standard)
let themes = [aquaTheme(), nativeTheme(), asciiTheme(slots: settings.slots)]

if let i = arguments.firstIndex(of: "--print") {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dates = arguments.dropFirst(i + 1).compactMap(formatter.date(from:))
    for date in dates.isEmpty ? [Date()] : dates {
        print(asciiBar(MonthProgress(date), slots: settings.slots))
    }
    exit(0)
}

if let i = arguments.firstIndex(of: "--iconset"), i + 1 < arguments.count {
    try IconRenderer.writeIconset(to: URL(fileURLWithPath: arguments[i + 1]))
    exit(0)
}

let app = NSApplication.shared
let login = LoginItem(service: .mainApp, settings: settings)
let controller = StatusController(themes: themes, settings: settings, login: login, statusBar: .system)
app.delegate = controller
app.setActivationPolicy(.accessory)
app.run()
