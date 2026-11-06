import Api

public final class InMemoryStore: IStore {
    private var current: State
    private let reduce: (State, Event) -> State
    private var observers: [(IState) -> Void] = []
    private var pending: [Event] = []
    private var dispatching = false

    public init(initial: State, reduce: @escaping (State, Event) -> State) {
        current = initial
        self.reduce = reduce
    }

    public var state: IState { current }

    public func subscribe(_ observer: @escaping (IState) -> Void) {
        observers.append(observer)
        observer(current)
    }

    // Events sent by an observer while it is being notified are queued, so every observer sees states in order.
    public func send(_ event: Event) {
        pending.append(event)
        guard !dispatching else { return }
        dispatching = true
        defer { dispatching = false }
        while !pending.isEmpty {
            let next = reduce(current, pending.removeFirst())
            guard next != current else { continue }
            current = next
            observers.forEach { $0(next) }
        }
    }
}
