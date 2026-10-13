import Foundation

public struct MonthProgress: Equatable {
    public let day: Int
    public let days: Int
    public let monthName: String

    public init(_ date: Date, calendar: Calendar = .current) {
        day = calendar.component(.day, from: date)
        days = calendar.range(of: .day, in: .month, for: date)!.count
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "LLLL yyyy"
        monthName = formatter.string(from: date)
    }

    public var fraction: Double { Double(day) / Double(days) }
    public var percent: Int { day * 100 / days }
    public var daysLeft: Int { days - day }
    public var label: String { "\(day)/\(days)" }
}

public enum AsciiBar {
    public static func render(_ progress: MonthProgress, slots: Int) -> String {
        let filled = min(slots, Int((progress.fraction * Double(slots)).rounded()))
        return "[" + String(repeating: "|", count: filled) + String(repeating: " ", count: slots - filled) + "]" + progress.label
    }
}
