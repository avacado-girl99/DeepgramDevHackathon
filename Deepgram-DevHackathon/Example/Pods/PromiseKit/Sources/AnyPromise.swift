import Foundation.NSError

@objc(AnyPromise) public class AnyPromise: NSObject {

    private var state: State

    public init<T: AnyObject>(bound: Promise<T?>) {
        var resolve: ((AnyObject?) -> Void)!
        state = State(resolver: &resolve)
        bound.pipe { resolution in
            switch resolution {
            case .Fulfilled(let value):
                resolve(value)
            case .Rejected(let error, let token):
                let nserror = error as NSError
                unconsume(error: nserror, reusingToken: token)
                resolve(nserror)
            }
        }
    }


    convenience public init<T: AnyObject>(bound: Promise<T>) {
    self.init(bound: bound.then(on: zalgo){ Optional.Some($0) })
    }

    convenience public init<T: AnyObject>(bound: Promise<[T]>) {
        self.init(bound: bound.then(on: zalgo) { NSArray(array: $0) })
    }

    convenience public init<T: AnyObject, U: AnyObject>(bound: Promise<[T:U]>) {
        self.init(bound: bound.then(on: zalgo) { NSDictionary(dictionary: $0) })
    }

    convenience public init(bound: Promise<String>) {
        self.init(bound: bound.then(on: zalgo) { NSString(string: $0) })
    }

    convenience public init(bound: Promise<Int>) {
        self.init(bound: bound.then(on: zalgo) { NSNumber(integer: $0) })
    }


    convenience public init(bound: Promise<Bool>) {
        self.init(bound: bound.then(on: zalgo) { NSNumber(bool: $0) })
    }

    convenience public init(bound: Promise<Void>) {
        self.init(bound: bound.then(on: zalgo) { Optional<AnyObject>.None })
    }

    @objc init(@noescape bridge: ((AnyObject?) -> Void) -> Void) {
        var resolve: ((AnyObject?) -> Void)!
        state = State(resolver: &resolve)
        bridge { result in
            if let next = result as? AnyPromise {
                next.pipe(resolve)
            } else {
                resolve(result)
            }
        }
    }

    @objc func pipe(body: (AnyObject?) -> Void) {
        state.get { seal in
            switch seal {
            case .Pending(let handlers):
                handlers.append(body)
            case .Resolved(let value):
                body(value)
            }
        }
    }

    @objc var __value: AnyObject? {
        return state.get() ?? nil
    }


    @objc public var pending: Bool {
        return state.get() == nil
    }


    @objc public var resolved: Bool {
        return !pending
    }

    @objc public var fulfilled: Bool {
        switch state.get() {
        case .Some(let obj) where obj is NSError:
            return false
        case .Some:
            return true
        case .None:
            return false
        }
    }

    @objc public var rejected: Bool {
        switch state.get() {
        case .Some(let obj) where obj is NSError:
            return true
        default:
            return false
        }
    }

    public func then<T>(on q: dispatch_queue_t = dispatch_get_main_queue(), body: (AnyObject?) throws -> T) -> Promise<T> {
        return Promise(sealant: { resolve in
            pipe { object in
                if let error = object as? NSError {
                    resolve(.Rejected(error, error.token))
                } else {
                    contain_zalgo(q, rejecter: resolve) {
                        resolve(.Fulfilled(try body(self.valueForKey("value"))))
                    }
                }
            }
        })
    }


    public func then(on q: dispatch_queue_t = dispatch_get_main_queue(), body: (AnyObject?) -> AnyPromise) -> Promise<AnyObject?> {
        return Promise { fulfill, reject in
            pipe { object in
                if let error = object as? NSError {
                    reject(error)
                } else {
                    contain_zalgo(q) {
                        body(object).pipe { object in
                            if let error = object as? NSError {
                                reject(error)
                            } else {
                                fulfill(object)
                            }
                        }
                    }
                }
            }
        }
    }

    public func then<T>(on q: dispatch_queue_t = dispatch_get_main_queue(), body: (AnyObject?) -> Promise<T>) -> Promise<T> {
        return Promise(sealant: { resolve in
            pipe { object in
                if let error = object as? NSError {
                    resolve(.Rejected(error, error.token))
                } else {
                    contain_zalgo(q) {
                        body(object).pipe(resolve)
                    }
                }
            }
        })
    }

    private class State: UnsealedState<AnyObject?> {
        required init(inout resolver: ((AnyObject?) -> Void)!) {
            var preresolve: ((AnyObject?) -> Void)!
            super.init(resolver: &preresolve)
            resolver = { obj in
                if let error = obj as? NSError { unconsume(error: error) }
                preresolve(obj)
            }
        }
    }
}


extension AnyPromise {
    override public var description: String {
        return "AnyPromise: \(state)"
    }
}
