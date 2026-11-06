import Models

public protocol IState {
    var themeID: ThemeID { get }
    var display: Display { get }
}

public enum Display {
    case blank
    case showing(Rendering, MenuModel)
}
