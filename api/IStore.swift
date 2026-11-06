public protocol IStore {
    var state: IState { get }
    func send(_ event: Event)
    // Called with the current state right away, then after every change.
    func subscribe(_ observer: @escaping (IState) -> Void)
}
