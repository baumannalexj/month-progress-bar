import AppKit
import Models

let arguments = CommandLine.arguments
let slots = Slots.resolve(UserDefaults.standard.integer(forKey: "slots"))

if let i = arguments.firstIndex(of: "--print") {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let dates = arguments.dropFirst(i + 1).compactMap(formatter.date(from:))
    for date in dates.isEmpty ? [Date()] : dates {
        print(MonthProgress(date).asciiBar(slots: slots))
    }
    exit(0)
}

NSApplication.shared.setActivationPolicy(.accessory)
MonthProgressApp.main()
