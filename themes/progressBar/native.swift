import Api
import Models

public struct NativeTheme: ITheme {
    public let id: ThemeID = "native"
    public let name = "macOS progress bar"

    public init() {}

    public func render(currentDay: Int, currentMonthMaxDay: Int) -> Rendering {
        let progress = Progress(currentDay: currentDay, currentMonthMaxDay: currentMonthMaxDay)
        return .systemBar(fraction: progress.fraction, label: progress.label)
    }
}
