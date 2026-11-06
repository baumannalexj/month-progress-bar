import Foundation

public struct MonthProgress: Equatable {
    public let currentDay: Int
    public let currentMonthMaxDay: Int
    public let monthName: String

    public init(currentDay: Int, currentMonthMaxDay: Int, monthName: String) {
        self.currentDay = currentDay
        self.currentMonthMaxDay = currentMonthMaxDay
        self.monthName = monthName
    }

    public init(_ date: Date, calendar: Calendar) {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = calendar.timeZone
        formatter.locale = calendar.locale
        formatter.dateFormat = "LLLL yyyy"
        self.init(currentDay: calendar.component(.day, from: date),
                  currentMonthMaxDay: calendar.range(of: .day, in: .month, for: date)!.count,
                  monthName: formatter.string(from: date))
    }

    public var fraction: Double { Double(currentDay) / Double(currentMonthMaxDay) }
    public var percent: Int { currentDay * 100 / currentMonthMaxDay }
    public var daysLeft: Int { currentMonthMaxDay - currentDay }
    public var label: String { "\(currentDay)/\(currentMonthMaxDay)" }
}
