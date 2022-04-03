import Dispatch
import Foundation.NSError
public class Promise<T> {
    let state: State<Resolution<T>>

     - Parameter resolvers: The provided closure is called immediately.
     Inside, execute your asynchronous system, calling fulfill if it suceeds
     and reject for any errors.

     - Returns: return A new promise.

     - Note: If you are wrapping a delegate-based system, we recommend
     to use instead: Promise.pendingPromise()

     - SeeAlso: http://promisekit.org/sealing-your-own-promises/
     - SeeAlso: http://promisekit.org/wrapping-delegation/
     - SeeAlso: init(resolver:)
    */
    public init(@noescape resolvers: (fulfill: (T) -> Void, reject: (ErrorType) -> Void) throws -> Void) {
        var resolve: ((Resolution<T>) -> Void)!
        state = UnsealedState(resolver: &resolve)
        do {
            try resolvers(fulfill: { resolve(.Fulfilled($0)) }, reject: { error in
                if self.pending {
                    resolve(.Rejected(error, ErrorConsumptionToken(error)))
                } else {
                    NSLog("PromiseKit: Warning: reject called on already rejected Promise: %@", "\(error)")
                }
            })
        } catch {
            resolve(.Rejected(error, ErrorConsumptionToken(error)))
        }
    }

    public convenience init(@noescape resolver: ((T?, NSError?) -> Void) throws -> Void) {
        self.init(sealant: { resolve in
            try resolver { obj, err in
                if let obj = obj {
                    resolve(.Fulfilled(obj))
                } else if let err = err {
                    resolve(.Rejected(err, ErrorConsumptionToken(err as ErrorType)))
                } else {
                    resolve(.Rejected(Error.DoubleOhSux0r, ErrorConsumptionToken(Error.DoubleOhSux0r)))
                }
            }
        })
    }

    public convenience init(@noescape resolver: ((T, NSError?) -> Void) throws -> Void) {
        self.init(sealant: { resolve in
            try resolver { obj, err in
                if let err = err {
                    resolve(.Rejected(err, ErrorConsumptionToken(err)))
                } else {
                    resolve(.Fulfilled(obj))
                }
            }
        })
    }


    public init(_ value: T) {
        state = SealedState(resolution: .Fulfilled(value))
    }

    @available(*, unavailable, message="T cannot conform to ErrorType")
    public init<T: ErrorType>(_ value: T) { abort() }

    public init(error: ErrorType) {
        state = SealedState(resolution: .Rejected(error, ErrorConsumptionToken(error)))
    }


    init(@noescape sealant: ((Resolution<T>) -> Void) throws -> Void) {
        var resolve: ((Resolution<T>) -> Void)!
        state = UnsealedState(resolver: &resolve)
        do {
            try sealant(resolve)
        } catch {
            resolve(.Rejected(error, ErrorConsumptionToken(error)))
        }
    }


    public typealias PendingPromise = (promise: Promise, fulfill: (T) -> Void, reject: (ErrorType) -> Void)

    public class func pendingPromise() -> PendingPromise {
        var fulfill: ((T) -> Void)!
        var reject: ((ErrorType) -> Void)!
        let promise = Promise { fulfill = $0; reject = $1 }
        return (promise, fulfill, reject)
    }

    func pipe(body: (Resolution<T>) -> Void) {
        state.get { seal in
            switch seal {
            case .Pending(let handlers):
                handlers.append(body)
            case .Resolved(let resolution):
                body(resolution)
            }
        }
    }

    private convenience init<U>(when: Promise<U>, body: (Resolution<U>, (Resolution<T>) -> Void) -> Void) {
        self.init { resolve in
            when.pipe { resolution in
                body(resolution, resolve)
            }
        }
    }

    public func then<U>(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) throws -> U) -> Promise<U> {
        return Promise<U>(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected(let error):
                resolve(.Rejected(error))
            case .Fulfilled(let value):
                contain_zalgo(q, rejecter: resolve) {
                    resolve(.Fulfilled(try body(value)))
                }
            }
        }
    }


    public func then<U>(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) throws -> Promise<U>) -> Promise<U> {
        return Promise<U>(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected(let error):
                resolve(.Rejected(error))
            case .Fulfilled(let value):
                contain_zalgo(q, rejecter: resolve) {
                    let promise = try body(value)
                    guard promise !== self else { throw Error.ReturnedSelf }
                    promise.pipe(resolve)
                }
            }
        }
    }

    @available(*, unavailable)
    public func then<U>(on: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) throws -> Promise<U>?) -> Promise<U> { abort() }


    public func then(on q: dispatch_queue_t = dispatch_get_main_queue(), body: (T) throws -> AnyPromise) -> Promise<AnyObject?> {
        return Promise<AnyObject?>(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected(let error):
                resolve(.Rejected(error))
            case .Fulfilled(let value):
                contain_zalgo(q, rejecter: resolve) {
                    try body(value).pipe(resolve)
                }
            }
        }
    }

    @available(*, unavailable)
    public func then(on: dispatch_queue_t = dispatch_get_main_queue(), body: (T) throws -> AnyPromise?) -> Promise<AnyObject?> { abort() }
ic func thenInBackground<U>(body: (T) throws -> U) -> Promise<U> {
        return then(on: dispatch_get_global_queue(0, 0), body)
    }

    public func thenInBackground<U>(body: (T) throws -> Promise<U>) -> Promise<U> {
        return then(on: dispatch_get_global_queue(0, 0), body)
    }

    @available(*, unavailable)
    public func thenInBackground<U>(body: (T) throws -> Promise<U>?) -> Promise<U> { abort() }


    public func error(policy policy: ErrorPolicy = .AllErrorsExceptCancellation, _ body: (ErrorType) -> Void) {
        
        func consume(error: ErrorType, _ token: ErrorConsumptionToken) {
            token.consumed = true
            body(error)
        }

        pipe { resolution in
            switch (resolution, policy) {
            case (let .Rejected(error, token), .AllErrorsExceptCancellation):
                dispatch_async(dispatch_get_main_queue()) {
                    guard let cancellableError = error as? CancellableErrorType where cancellableError.cancelled else {
                        consume(error, token)
                        return
                    }
                }
            case (let .Rejected(error, token), _):
                dispatch_async(dispatch_get_main_queue()) {
                    consume(error, token)
                }
            case (.Fulfilled, _):
                break
            }
        }
    }

    public func recover(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (ErrorType) throws -> Promise) -> Promise {
        return Promise(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected(let error, let token):
                contain_zalgo(q, rejecter: resolve) {
                    token.consumed = true
                    let promise = try body(error)
                    guard promise !== self else { throw Error.ReturnedSelf }
                    promise.pipe(resolve)
                }
            case .Fulfilled:
                resolve(resolution)
            }
        }
    }

    @available(*, unavailable)
    public func recover(on: dispatch_queue_t = dispatch_get_main_queue(), _ body: (ErrorType) throws -> Promise?) -> Promise { abort() }

    public func recover(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: (ErrorType) throws -> T) -> Promise {
        return Promise(when: self) { resolution, resolve in
            switch resolution {
            case .Rejected(let error, let token):
                contain_zalgo(q, rejecter: resolve) {
                    token.consumed = true
                    resolve(.Fulfilled(try body(error)))
                }
            case .Fulfilled:
                resolve(resolution)
            }
        }
    }

    public func always(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: () -> Void) -> Promise {
        return Promise(when: self) { resolution, resolve in
            contain_zalgo(q) {
                body()
                resolve(resolution)
            }
        }
    }

    @available(*, unavailable, renamed="ensure")
    public func finally(on: dispatch_queue_t = dispatch_get_main_queue(), body: () -> Void) -> Promise { abort() }

    @available(*, unavailable, renamed="report")
    public func catch_(policy policy: ErrorPolicy = .AllErrorsExceptCancellation, body: () -> Void) -> Promise { abort() }

    @available(*, unavailable, renamed="pendingPromise")
    public class func defer_() -> (promise: Promise, fulfill: (T) -> Void, reject: (ErrorType) -> Void) { abort() }

    @available(*, deprecated, renamed="error")
    public func report(policy policy: ErrorPolicy = .AllErrorsExceptCancellation, _ body: (ErrorType) -> Void) { error(policy: policy, body) }

    @available(*, deprecated, renamed="always")
    public func ensure(on q: dispatch_queue_t = dispatch_get_main_queue(), _ body: () -> Void) -> Promise { return always(on: q, body) }
}


public let zalgo: dispatch_queue_t = dispatch_queue_create("Zalgo", nil)

public let waldo: dispatch_queue_t = dispatch_queue_create("Waldo", nil)

func contain_zalgo(q: dispatch_queue_t, block: () -> Void) {
    if q === zalgo {
        block()
    } else if q === waldo {
        if NSThread.isMainThread() {
            dispatch_async(dispatch_get_global_queue(0, 0), block)
        } else {
            block()
        }
    } else {
        dispatch_async(q, block)
    }
}

func contain_zalgo<T>(q: dispatch_queue_t, rejecter resolve: (Resolution<T>) -> Void, block: () throws -> Void) {
    contain_zalgo(q) {
        do {
            try block()
        } catch {
            resolve(.Rejected(error, ErrorConsumptionToken(error)))
        }
    }
}


extension Promise {

    public func asVoid() -> Promise<Void> {
        return then(on: zalgo) { _ in return }
    }
}


extension Promise: CustomStringConvertible {
    public var description: String {
        return "Promise: \(state)"
    }
}


public func firstly(@noescape promise: () throws -> AnyPromise) -> Promise<AnyObject?> {
    return Promise { resolve in
        try promise().pipe(resolve)
    }
}

@available(*, unavailable, message="Instead, throw")
public func firstly<T: ErrorType>(@noescape promise: () throws -> Promise<T>) -> Promise<T> {
    fatalError("Unavailable function")
}


public enum ErrorPolicy {
    case AllErrors
    case AllErrorsExceptCancellation
}


extension AnyPromise {
    private func pipe(resolve: (Resolution<AnyObject?>) -> Void) -> Void {
        pipe { (obj: AnyObject?) in
            if let error = obj as? NSError {
                resolve(.Rejected(error, ErrorConsumptionToken(error)))
            } else {

                resolve(.Fulfilled(self.valueForKey("value")))
            }
        }
    }
}


extension Promise {
    @available(*, unavailable, message="T cannot conform to ErrorType")
    public convenience init<T: ErrorType>(@noescape resolvers: (fulfill: (T) -> Void, reject: (ErrorType) -> Void) throws -> Void) { abort() }

    @available(*, unavailable, message="T cannot conform to ErrorType")
    public convenience init<T: ErrorType>(@noescape resolver: ((T?, NSError?) -> Void) throws -> Void) { abort() }

    @available(*, unavailable, message="T cannot conform to ErrorType")
    public convenience init<T: ErrorType>(@noescape resolver: ((T, NSError?) -> Void) throws -> Void) { abort() }

    @available(*, unavailable, message="T cannot conform to ErrorType")
    public class func pendingPromise<T: ErrorType>() -> (promise: Promise, fulfill: (T) -> Void, reject: (ErrorType) -> Void) { abort() }

    @available (*, unavailable, message="U cannot conform to ErrorType")
    public func then<U: ErrorType>(on: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) throws -> U) -> Promise<U> { abort() }

    @available (*, unavailable, message="U cannot conform to ErrorType")
    public func then<U: ErrorType>(on: dispatch_queue_t = dispatch_get_main_queue(), _ body: (T) throws -> Promise<U>) -> Promise<U> { abort() }

    @available(*, unavailable, message="U cannot conform to ErrorType")
    public func thenInBackground<U: ErrorType>(body: (T) throws -> U) -> Promise<U> { abort() }

    @available(*, unavailable, message="U cannot conform to ErrorType")
    public func thenInBackground<U: ErrorType>(body: (T) throws -> Promise<U>) -> Promise<U> { abort() }
}
