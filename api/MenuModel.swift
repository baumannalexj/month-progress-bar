import Models

public struct MenuModel: Equatable {
    public let summary: String
    public let remaining: String
    public let tooltip: String

    public init(_ progress: MonthProgress) {
        summary = "\(progress.monthName) — day \(progress.currentDay) of \(progress.currentMonthMaxDay) (\(progress.percent)%)"
        tooltip = "\(progress.monthName): day \(progress.currentDay) of \(progress.currentMonthMaxDay)"
        switch progress.daysLeft {
        case 0: remaining = "Last day of the month"
        case 1: remaining = "1 day left"
        default: remaining = "\(progress.daysLeft) days left"
        }
    }
}
