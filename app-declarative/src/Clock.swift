import AppKit
import Combine

final class Clock: ObservableObject {
    @Published private(set) var now = Date()
    private var subscriptions = Set<AnyCancellable>()

    init() {
        let triggers: [AnyPublisher<Void, Never>] = [
            NotificationCenter.default.publisher(for: .NSCalendarDayChanged).map { _ in }.eraseToAnyPublisher(),
            NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification).map { _ in }.eraseToAnyPublisher(),
            Timer.publish(every: 15 * 60, on: .main, in: .common).autoconnect().map { _ in }.eraseToAnyPublisher(),
        ]
        Publishers.MergeMany(triggers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.now = Date() }
            .store(in: &subscriptions)
    }
}
