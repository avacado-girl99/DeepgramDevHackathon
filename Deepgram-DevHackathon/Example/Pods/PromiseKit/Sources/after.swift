import Dispatch
import Foundation.NSDate

public func after(delay: NSTimeInterval) -> Promise<Void> {
    return Promise { fulfill, _ in
        let delta = delay * NSTimeInterval(NSEC_PER_SEC)
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(delta))
        dispatch_after(when, dispatch_get_global_queue(0, 0), fulfill)
    }
}
