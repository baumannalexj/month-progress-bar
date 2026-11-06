import Api
import Models

public struct Reducer {
    private let themes: [ITheme]

    public init(themes: [ITheme]) {
        precondition(!themes.isEmpty, "at least one theme")
        self.themes = themes
    }

    public func reduce(_ state: State, _ event: Event) -> State {
        switch (state, event) {
        case (_, .dateChanged(let progress)):
            return running(progress, theme(state.themeID))
        case (.awaitingDate, .themeChanged(let id)):
            return .awaitingDate(themeID: theme(id).id)
        case (.running(let progress, _, _), .themeChanged(let id)):
            return running(progress, theme(id))
        }
    }

    private func theme(_ id: ThemeID) -> ITheme {
        themes.first { $0.id == id } ?? themes[0]
    }

    private func running(_ progress: MonthProgress, _ theme: ITheme) -> State {
        .running(progress: progress, themeID: theme.id,
                 rendering: theme.render(currentDay: progress.currentDay, currentMonthMaxDay: progress.currentMonthMaxDay))
    }
}
