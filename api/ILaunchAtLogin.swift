import Models

// A side feature, not month state: the menu reads it when it opens.
public protocol ILaunchAtLogin {
    var state: LoginState { get }
    func toggle() throws
}
