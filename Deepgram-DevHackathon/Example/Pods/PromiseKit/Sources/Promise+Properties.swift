extension Promise {

    public var error: ErrorType? {
        switch state.get() {
        case .None:
            return nil
        case .Some(.Fulfilled):
            return nil
        case .Some(.Rejected(let error, _)):
            return error
        }
    }


    public var pending: Bool {
        return state.get() == nil
    }


    public var resolved: Bool {
        return !pending
    }
    public var fulfilled: Bool {
        return value != nil
    }

    public var rejected: Bool {
        return error != nil
    }

    public var value: T? {
        switch state.get() {
        case .None:
            return nil
        case .Some(.Fulfilled(let value)):
            return value
        case .Some(.Rejected):
            return nil
        }
    }
}
