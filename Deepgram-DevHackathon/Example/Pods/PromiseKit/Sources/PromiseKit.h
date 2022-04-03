#import <dispatch/queue.h>
#import <Foundation/NSDate.h>
#import <Foundation/NSObject.h>
#import <PromiseKit/AnyPromise.h>
#import <PromiseKit/NSError+Cancellation.h>
#import <PromiseKit/Umbrella.h>

extern AnyPromise * __nonnull PMKAfter(NSTimeInterval duration);

extern AnyPromise * __nonnull PMKWhen(id __nonnull input);

AnyPromise *__nonnull PMKJoin(NSArray * __nonnull promises);

extern id __nullable PMKHang(AnyPromise * __nonnull promise);

extern void PMKSetUnhandledExceptionHandler(NSError * __nullable (^__nonnull handler)(id __nullable));

extern AnyPromise * __nonnull dispatch_promise(id __nonnull block);

extern AnyPromise * __nonnull dispatch_promise_on(dispatch_queue_t __nonnull queue, id __nonnull block);



#define PMKJSONDeserializationOptions ((NSJSONReadingOptions)(NSJSONReadingAllowFragments | NSJSONReadingMutableContainers))

#define PMKHTTPURLResponseIsJSON(rsp) [@[@"application/json", @"text/json", @"text/javascript", @"application/x-javascript", @"application/javascript"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsImage(rsp) [@[@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap"] containsObject:[rsp MIMEType]]
#define PMKHTTPURLResponseIsText(rsp) [[rsp MIMEType] hasPrefix:@"text/"]



#if defined(__has_include)
  #if __has_include(<PromiseKit/ACAccountStore+AnyPromise.h>)
    #import <PromiseKit/ACAccountStore+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/AVAudioSession+AnyPromise.h>)
    #import <PromiseKit/AVAudioSession+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CKContainer+AnyPromise.h>)
    #import <PromiseKit/CKContainer+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CKDatabase+AnyPromise.h>)
    #import <PromiseKit/CKDatabase+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CLGeocoder+AnyPromise.h>)
    #import <PromiseKit/CLGeocoder+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CLLocationManager+AnyPromise.h>)
    #import <PromiseKit/CLLocationManager+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/NSNotificationCenter+AnyPromise.h>)
    #import <PromiseKit/NSNotificationCenter+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/NSTask+AnyPromise.h>)
    #import <PromiseKit/NSTask+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/NSURLConnection+AnyPromise.h>)
    #import <PromiseKit/NSURLConnection+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/MKDirections+AnyPromise.h>)
    #import <PromiseKit/MKDirections+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/MKMapSnapshotter+AnyPromise.h>)
    #import <PromiseKit/MKMapSnapshotter+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/CALayer+AnyPromise.h>)
    #import <PromiseKit/CALayer+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/SLRequest+AnyPromise.h>)
    #import <PromiseKit/SLRequest+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/SKRequest+AnyPromise.h>)
    #import <PromiseKit/SKRequest+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/SCNetworkReachability+AnyPromise.h>)
    #import <PromiseKit/SCNetworkReachability+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIActionSheet+AnyPromise.h>)
    #import <PromiseKit/UIActionSheet+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIAlertView+AnyPromise.h>)
    #import <PromiseKit/UIAlertView+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIView+AnyPromise.h>)
    #import <PromiseKit/UIView+AnyPromise.h>
  #endif
  #if __has_include(<PromiseKit/UIViewController+AnyPromise.h>)
    #import <PromiseKit/UIViewController+AnyPromise.h>
  #endif
#endif
