import SwiftUI
import ServiceManagement
import Models

// MenuBarExtra has no right-click menu, so Style lives in the one menu.
struct MonthProgressApp: App {
    @StateObject private var clock = Clock()
    @AppStorage("theme") private var theme: Theme = .aqua
    @AppStorage("slots") private var storedSlots = 0

    private var progress: MonthProgress { MonthProgress(clock.now) }
    private var slots: Int { Slots.resolve(storedSlots) }

    var body: some Scene {
        MenuBarExtra {
            MenuContent(progress: progress, theme: $theme)
        } label: {
            theme.label(progress, slots: slots)
        }
    }
}

struct MenuContent: View {
    let progress: MonthProgress
    @Binding var theme: Theme

    var body: some View {
        Text("\(progress.monthName) — day \(progress.day) of \(progress.days) (\(progress.percent)%)")
        Text(remaining)
        Divider()
        Picker("Style", selection: $theme) {
            ForEach(Theme.allCases) { Text($0.name).tag($0) }
        }
        Toggle("Launch at Login", isOn: launchAtLogin)
        Button("Quit") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }

    private var remaining: String {
        progress.daysLeft == 0 ? "Last day of the month"
            : "\(progress.daysLeft) day\(progress.daysLeft == 1 ? "" : "s") left"
    }

    private var launchAtLogin: Binding<Bool> {
        Binding(
            get: { SMAppService.mainApp.status == .enabled },
            set: { enable in
                do {
                    if enable { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
                } catch {
                    NSAlert(error: error).runModal()
                }
            })
    }
}
