import Dispatch

public func join<T>(promises: Promise<T>...) -> Promise<[T]> {
    var countdown = promises.count
    let barrier = dispatch_queue_create("org.promisekit.barrier.join", DISPATCH_QUEUE_CONCURRENT)
    var rejected = false

    return Promise { fulfill, reject in
        for promise in promises {
            promise.pipe { resolution in
                dispatch_barrier_sync(barrier) {
                    if case .Rejected(_, let token) = resolution {
                        token.consumed = true 
                    }

                    if --countdown == 0 {
                        if rejected {
                            reject(Error.Join(promises))
                        } else {
                            fulfill(promises.map{ $0.value! })
                        }
                    }
                }
            }
        }
    }
}
