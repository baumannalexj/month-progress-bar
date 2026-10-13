import Foundation
import Models

public enum Rendering: Equatable {
    case text(String)
    case aquaBar(fraction: Double, label: String)
    case systemBar(value: Double, max: Double, label: String)
}

public struct ProgressTheme {
    public let id: String
    public let name: String
    public let render: (MonthProgress) -> Rendering

    public init(id: String, name: String, render: @escaping (MonthProgress) -> Rendering) {
        self.id = id
        self.name = name
        self.render = render
    }
}

public struct MenuModel: Equatable {
    public let summary: String
    public let remaining: String
    public let tooltip: String

    public init(summary: String, remaining: String, tooltip: String) {
        self.summary = summary
        self.remaining = remaining
        self.tooltip = tooltip
    }
}

public func menuModel(for progress: MonthProgress) -> MenuModel {
    MenuModel(
        summary: "\(progress.monthName) — day \(progress.day) of \(progress.days) (\(progress.percent)%)",
        remaining: remainingText(daysLeft: progress.daysLeft),
        tooltip: "\(progress.monthName): day \(progress.day) of \(progress.days)")
}

func remainingText(daysLeft: Int) -> String {
    switch daysLeft {
    case 0: return "Last day of the month"
    case 1: return "1 day left"
    default: return "\(daysLeft) days left"
    }
}
