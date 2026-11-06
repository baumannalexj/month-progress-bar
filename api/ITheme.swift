import Models

public protocol ITheme {
    var id: ThemeID { get }
    var name: String { get }
    func render(currentDay: Int, currentMonthMaxDay: Int) -> Rendering
}
