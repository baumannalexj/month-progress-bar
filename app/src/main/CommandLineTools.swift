import Foundation
import Models
import ProgressBarThemes

// `--print [yyyy-MM-dd ...]` previews the ASCII bar; `--iconset <dir>` renders the app icon. Returns false otherwise.
struct CommandLineTools {
    let calendar: Calendar
    let slots: Int

    func handled(_ arguments: [String]) throws -> Bool {
        if let i = arguments.firstIndex(of: "--print") {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dates = arguments.dropFirst(i + 1).compactMap(formatter.date(from:))
            let ascii = AsciiTheme(slots: slots)
            for date in dates.isEmpty ? [Date()] : dates {
                let progress = MonthProgress(date, calendar: calendar)
                if case .text(let bar) = ascii.render(currentDay: progress.currentDay,
                                                      currentMonthMaxDay: progress.currentMonthMaxDay) {
                    print(bar)
                }
            }
            return true
        }
        if let i = arguments.firstIndex(of: "--iconset"), i + 1 < arguments.count {
            try IconRenderer.writeIconset(to: URL(fileURLWithPath: arguments[i + 1]))
            return true
        }
        return false
    }
}
