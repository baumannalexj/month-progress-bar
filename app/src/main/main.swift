import AppKit

let app = NSApplication.shared
let providers = Providers(defaults: .standard, statusBar: .system, notifications: .default,
                          workspace: NSWorkspace.shared.notificationCenter, calendar: .autoupdatingCurrent, now: Date.init)

if try CommandLineTools(calendar: providers.calendar, slots: providers.persistence.slots).handled(CommandLine.arguments) {
    exit(0)
}

let store = providers.store
let renderer = providers.renderer
store.subscribe(renderer.render)
store.subscribe(providers.persistence.save)
renderer.onEvent(store.send)
providers.clock.publishDate { store.send(.dateChanged($0)) }
providers.launchAtLogin.refreshRegistration()

app.setActivationPolicy(.accessory)
app.run()
