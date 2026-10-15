import Foundation
import ServiceManagement

public enum LoginState {
    case on, off, needsApproval
}

// Re-registers on every launch so the login item follows the app when it is rebuilt or moved;
// a registration made from an older copy otherwise keeps pointing at that copy.
public struct LoginItem {
    let service: SMAppService
    let settings: Settings

    public init(service: SMAppService, settings: Settings) {
        self.service = service
        self.settings = settings
    }

    var state: LoginState {
        switch service.status {
        case .enabled: return .on
        case .requiresApproval: return .needsApproval
        default: return .off
        }
    }

    func reconcile() {
        let wanted = settings.launchAtLogin ?? (service.status == .enabled)
        if wanted { try? enable() }
    }

    func enable() throws {
        settings.launchAtLogin = true
        try service.register()
    }

    func disable() throws {
        settings.launchAtLogin = false
        try service.unregister()
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
