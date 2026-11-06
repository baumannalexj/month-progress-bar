import Foundation
import Models

let utc: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.locale = Locale(identifier: "en_US_POSIX")
    return calendar
}()

func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
    utc.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
}

func progress(_ year: Int, _ month: Int, _ day: Int) -> MonthProgress {
    MonthProgress(date(year, month, day), calendar: utc)
}

// Lets a test move time forward, the way midnight does.
final class FakeNow {
    var value: Date
    init(_ value: Date) { self.value = value }
}
