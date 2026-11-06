// What every progress bar derives from the two inputs.
struct Progress {
    let fraction: Double
    let label: String

    init(currentDay: Int, currentMonthMaxDay: Int) {
        fraction = Double(currentDay) / Double(currentMonthMaxDay)
        label = "\(currentDay)/\(currentMonthMaxDay)"
    }
}
