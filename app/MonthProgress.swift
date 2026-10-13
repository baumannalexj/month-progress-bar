import Foundation

struct MonthProgress {
    let day: Int
    let days: Int
    let monthName: String

    init(_ date: Date, calendar: Calendar = .current) {
        day = calendar.component(.day, from: date)
        days = calendar.range(of: .day, in: .month, for: date)!.count
        let formatter = DateFormatter()
        formatter.dateFormat = "LLLL yyyy"
        monthName = formatter.string(from: date)
    }

    var fraction: Double { Double(day) / Double(days) }
    var percent: Int { day * 100 / days }
    var daysLeft: Int { days - day }
    var label: String { "\(day)/\(days)" }
}
