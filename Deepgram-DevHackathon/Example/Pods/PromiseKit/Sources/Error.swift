import Dispatch
import Foundation.NSError
import Foundation.NSURLError

public enum Error: ErrorType {

    case When(Int, ErrorType)

    case Join([AnyObject])

    case DoubleOhSux0r

    case ReturnedSelf
}

public enum URLError: ErrorType {

    case InvalidImageData(NSURLRequest, NSData)

    case UnderlyingCocoaError(NSURLRequest, NSData?, NSURLResponse?, NSError)

    case BadResponse(NSURLRequest, NSData?, NSURLResponse?)

    case StringEncoding(NSURLRequest, NSData, NSURLResponse)

    public var NSHTTPURLResponse: Foundation.NSHTTPURLResponse! {
        switch self {
        case .InvalidImageData:
            return nil
        case .UnderlyingCocoaError(_, _, let rsp, _):
            return rsp as! Foundation.NSHTTPURLResponse
        case .BadResponse(_, _, let rsp):
            return rsp as! Foundation.NSHTTPURLResponse
        case .StringEncoding(_, _, let rsp):
            return rsp as! Foundation.NSHTTPURLResponse
        }
    }
}

public enum JSONError: ErrorType {
    case UnexpectedRootNode(AnyObject)
}

private struct ErrorPair: Hashable {
    let domain: String
    let code: Int
    init(_ d: String, _ c: Int) {
        domain = d; code = c
    }
    var hashValue: Int {
        return "\(domain):\(code)".hashValue
    }
}

private func ==(lhs: ErrorPair, rhs: ErrorPair) -> Bool {
    return lhs.domain == rhs.domain && lhs.code == rhs.code
}

extension NSError {
    @objc public class func cancelledError() -> NSError {
        let info: [NSObject: AnyObject] = [NSLocalizedDescriptionKey: "The operation was cancelled"]
        return NSError(domain: PMKErrorDomain, code: PMKOperationCancelled, userInfo: info)
    }

    @objc public class func registerCancelledErrorDomain(domain: String, code: Int) {
        cancelledErrorIdentifiers.insert(ErrorPair(domain, code))
    }
}

public protocol CancellableErrorType: ErrorType {
    var cancelled: Bool { get }
}

extension NSError: CancellableErrorType {

    @objc public var cancelled: Bool {
        if !NSThread.isMainThread() {
            NSLog("PromiseKit: Warning: `cancelled` called on background thread.")
        }

        return cancelledErrorIdentifiers.contains(ErrorPair(domain, code))
    }
}

private var cancelledErrorIdentifiers = Set([
    ErrorPair(PMKErrorDomain, PMKOperationCancelled),
    ErrorPair(NSURLErrorDomain, NSURLErrorCancelled)
])

extension NSURLError: CancellableErrorType {
    public var cancelled: Bool {
        return self == .Cancelled
    }
}

public var PMKUnhandledErrorHandler = { (error: ErrorType) -> Void in
    dispatch_async(dispatch_get_main_queue()) {
        let cancelled = (error as? CancellableErrorType)?.cancelled ?? false
                                                       
        if !cancelled {
            NSLog("PromiseKit: Unhandled Error: %@", "\(error)")
        }
    }
}

class ErrorConsumptionToken {
    var consumed = false
    let error: ErrorType!

    init(_ error: ErrorType) {
        self.error = error
    }

    init(_ error: NSError) {
        self.error = error.copy() as! NSError
    }

    deinit {
        if !consumed {
            PMKUnhandledErrorHandler(error)
        }
    }
}

private var handle: UInt8 = 0

extension NSError {
    @objc func pmk_consume() {
        if let token = objc_getAssociatedObject(self, &handle) as? ErrorConsumptionToken {
            token.consumed = true
        }
    }

    var token: ErrorConsumptionToken! {
        return objc_getAssociatedObject(self, &handle) as? ErrorConsumptionToken
    }
}

func unconsume(error error: NSError, var reusingToken token: ErrorConsumptionToken? = nil) {
    if token != nil {
        objc_setAssociatedObject(error, &handle, token, .OBJC_ASSOCIATION_RETAIN)
    } else {
        token = objc_getAssociatedObject(error, &handle) as? ErrorConsumptionToken
        if token == nil {
            token = ErrorConsumptionToken(error)
            objc_setAssociatedObject(error, &handle, token, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    token!.consumed = false
}
