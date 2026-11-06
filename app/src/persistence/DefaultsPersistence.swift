import Api
import Foundation
import Models

public struct DefaultsPersistence {
    private let defaults: UserDefaults

    public init(defaults: UserDefaults) { self.defaults = defaults }

    public var themeID: ThemeID { ThemeID(defaults.string(forKey: "theme") ?? "aqua") }

    public var slots: Int {
        let stored = defaults.integer(forKey: "slots")
        return stored == 0 ? 10 : max(3, stored)
    }

    public var launchAtLogin: Bool? { defaults.object(forKey: "launchAtLogin") as? Bool }

    public func save(_ state: IState) {
        defaults.set(state.themeID.rawValue, forKey: "theme")
    }

    public func saveLaunchAtLogin(_ wanted: Bool) {
        defaults.set(wanted, forKey: "launchAtLogin")
    }
}
