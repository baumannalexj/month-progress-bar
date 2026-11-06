import Api
import Models

public enum State: IState, Equatable {
    case awaitingDate(themeID: ThemeID)
    case running(progress: MonthProgress, themeID: ThemeID, rendering: Rendering)

    public var themeID: ThemeID {
        switch self {
        case .awaitingDate(let id), .running(_, let id, _): return id
        }
    }

    public var display: Display {
        switch self {
        case .awaitingDate: return .blank
        case .running(let progress, _, let rendering): return .showing(rendering, MenuModel(progress))
        }
    }

    // The rendering is derived from progress and theme, so it never decides equality.
    public static func == (lhs: State, rhs: State) -> Bool {
        switch (lhs, rhs) {
        case let (.awaitingDate(a), .awaitingDate(b)): return a == b
        case let (.running(p1, t1, _), .running(p2, t2, _)): return p1 == p2 && t1 == t2
        default: return false
        }
    }
}
