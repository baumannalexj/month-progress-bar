public protocol IRender {
    func render(_ state: IState)
    func onEvent(_ handler: @escaping (Event) -> Void)
}
