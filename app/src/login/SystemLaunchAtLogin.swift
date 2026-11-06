import Api
import Models
import Persistence
import ServiceManagement

public struct SystemLaunchAtLogin: ILaunchAtLogin {
    private let service: SMAppService
    private let persistence: DefaultsPersistence

    public init(service: SMAppService, persistence: DefaultsPersistence) {
        self.service = service
        self.persistence = persistence
    }

    public var state: LoginState {
        switch service.status {
        case .enabled: return .on
        case .requiresApproval: return .needsApproval
        default: return .off
        }
    }

    public func toggle() throws {
        switch state {
        case .on:
            persistence.saveLaunchAtLogin(false)
            try service.unregister()
        case .off:
            persistence.saveLaunchAtLogin(true)
            try service.register()
        case .needsApproval:
            SMAppService.openSystemSettingsLoginItems()
        }
    }

    // Re-register on launch so the login item follows the app after a rebuild or move.
    public func refreshRegistration() {
        if persistence.launchAtLogin ?? (service.status == .enabled) {
            try? service.register()
        }
    }
}
