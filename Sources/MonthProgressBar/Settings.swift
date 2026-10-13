import Foundation

struct Settings {
    let defaults: UserDefaults

    var slots: Int {
        let stored = defaults.integer(forKey: "slots")
        return stored == 0 ? 10 : max(3, stored)
    }

    var themeID: String? {
        get { defaults.string(forKey: "theme") }
        nonmutating set { defaults.set(newValue, forKey: "theme") }
    }
}
