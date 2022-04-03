#import <dispatch/object.h>
#import <dispatch/queue.h>
#import <Foundation/NSObject.h>
#import "Umbrella.h"

typedef void (^PMKResolver)(id __nullable);

typedef NS_ENUM(NSInteger, PMKCatchPolicy) {
    PMKCatchPolicyAllErrors,
    PMKCatchPolicyAllErrorsExceptCancellation
};

@interface AnyPromise (objc)

- (AnyPromise * __nonnull (^ __nonnull)(id __nonnull))then;

- (AnyPromise * __nonnull(^ __nonnull)(id __nonnull))thenInBackground;

- (AnyPromise * __nonnull(^ __nonnull)(dispatch_queue_t __nonnull, id __nonnull))thenOn;

#ifndef __cplusplus

- (AnyPromise * __nonnull(^ __nonnull)(id __nonnull))catch;
#endif

- (AnyPromise * __nonnull(^ __nonnull)(PMKCatchPolicy, id __nonnull))catchWithPolicy;

- (AnyPromise * __nonnull(^ __nonnull)(dispatch_block_t __nonnull))finally;

- (AnyPromise * __nonnull(^ __nonnull)(dispatch_queue_t __nonnull, dispatch_block_t __nonnull))finallyOn;


- (id __nullable)value;

+ (instancetype __nonnull)promiseWithValue:(id __nullable)value;


+ (instancetype __nonnull)promiseWithResolverBlock:(void (^ __nonnull)(PMKResolver __nonnull resolve))resolverBlock;

- (instancetype __nonnull)initWithResolver:(PMKResolver __strong __nonnull * __nonnull)resolver;

@end



@interface AnyPromise (Unavailable)

- (instancetype __nonnull)init __attribute__((unavailable("It is illegal to create an unresolvable promise.")));
+ (instancetype __nonnull)new __attribute__((unavailable("It is illegal to create an unresolvable promise.")));

@end



typedef void (^PMKAdapter)(id __nullable, NSError * __nullable);
typedef void (^PMKIntegerAdapter)(NSInteger, NSError * __nullable);
typedef void (^PMKBooleanAdapter)(BOOL, NSError * __nullable);

@interface AnyPromise (Adapters)

+ (instancetype __nonnull)promiseWithAdapterBlock:(void (^ __nonnull)(PMKAdapter __nonnull adapter))block;

+ (instancetype __nonnull)promiseWithIntegerAdapterBlock:(void (^ __nonnull)(PMKIntegerAdapter __nonnull adapter))block;


+ (instancetype __nonnull)promiseWithBooleanAdapterBlock:(void (^ __nonnull)(PMKBooleanAdapter __nonnull adapter))block;

@end

#define PMKManifold(...) __PMKManifold(__VA_ARGS__, 3, 2, 1)
#define __PMKManifold(_1, _2, _3, N, ...) __PMKArrayWithCount(N, _1, _2, _3)
extern id __nonnull __PMKArrayWithCount(NSUInteger, ...);
