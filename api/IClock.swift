import Models

public protocol IClock {
    // Emits now, then again each time the day changes. Always on the main thread.
    func publishDate(_ subscriber: @escaping (MonthProgress) -> Void)
}
