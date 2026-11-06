import Models

// Every input into the app, as values.
public enum Event {
    case dateChanged(MonthProgress)    // from IClock: startup and each new day
    case themeChanged(ThemeID)         // from the menu
}
