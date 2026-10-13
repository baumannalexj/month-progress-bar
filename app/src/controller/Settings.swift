import Foundation

public struct Settings {
    let defaults: UserDefaults

    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }

    public var slots: Int {
        let stored = defaults.integer(forKey: "slots")
        return stored == 0 ? 10 : max(3, stored)
    }

    public var themeID: String? {
        get { defaults.string(forKey: "theme") }
        nonmutating set { defaults.set(newValue, forKey: "theme") }
    }
}
