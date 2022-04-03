import Foundation.NSProgress

private func _when<T>(promises: [Promise<T>]) -> Promise<Void> {
    let (rootPromise, fulfill, reject) = Promise<Void>.pendingPromise()
#if !PMKDisableProgress
    let progress = NSProgress(totalUnitCount: Int64(promises.count))
    progress.cancellable = false
    progress.pausable = false
#else
    var progress: (completedUnitCount: Int, totalUnitCount: Int) = (0, 0)
#endif
    var countdown = promises.count
    if countdown == 0 {
        fulfill()
        return rootPromise
    }
    let barrier = dispatch_queue_create("org.promisekit.barrier.when", DISPATCH_QUEUE_CONCURRENT)

    for (index, promise) in promises.enumerate() {
        promise.pipe { resolution in
            dispatch_barrier_sync(barrier) {
                switch resolution {
                case .Rejected(let error, let token):
                    token.consumed = true  
                    if rootPromise.pending {
                        progress.completedUnitCount = progress.totalUnitCount
                        reject(Error.When(index, error))
                    }
                case .Fulfilled:
                    guard rootPromise.pending else { return }
                    progress.completedUnitCount++
                    if --countdown == 0 {
                        fulfill()
                    }
                }
            }
        }
    }

    return rootPromise
}

public func when<T>(promises: [Promise<T>]) -> Promise<[T]> {
    return _when(promises).then(on: zalgo) { promises.map{ $0.value! } }
}

public func when<T>(promises: Promise<T>...) -> Promise<[T]> {
    return when(promises)
}

public func when(promises: Promise<Void>...) -> Promise<Void> {
    return _when(promises)
}

public func when(promises: [Promise<Void>]) -> Promise<Void> {
    return _when(promises)
}

public func when<U, V>(pu: Promise<U>, _ pv: Promise<V>) -> Promise<(U, V)> {
    return _when([pu.asVoid(), pv.asVoid()]).then(on: zalgo) { (pu.value!, pv.value!) }
}

public func when<U, V, X>(pu: Promise<U>, _ pv: Promise<V>, _ px: Promise<X>) -> Promise<(U, V, X)> {
    return _when([pu.asVoid(), pv.asVoid(), px.asVoid()]).then(on: zalgo) { (pu.value!, pv.value!, px.value!) }
}
