#import "DeepGram.h"
@class AnyPromise;

NS_ASSUME_NONNULL_BEGIN

@interface DGClient (PromiseKit)

- (AnyPromise *)getBalanceWithProgress:(nullable void (^)(NSProgress *progress))progress;

- (AnyPromise *)indexURL:(NSURL *)audioURL
                progress:(nullable void (^)(NSProgress *progress))progress;

- (AnyPromise *)statusOfContent:(NSString *)contentID
                       progress:(nullable void (^)(NSProgress *progress))progress;


- (AnyPromise *)matchesInContent:(NSString *)contentID
                       withQuery:(NSString *)query
                         snippet:(BOOL)snippet
                            Nmax:(nullable NSNumber *)Nmax
                   confidenceMin:(nullable NSNumber *)confidenceMin
                        progress:(nullable void (^)(NSProgress *progress))progress;


- (AnyPromise *)transcriptForContent:(NSString *)contentID
                            progress:(nullable void (^)(NSProgress *progress))progress;


- (AnyPromise *)searchAllContentWithQuery:(NSString *)query
                                      tag:(nullable NSString *)tag
                                     Nmax:(nullable NSNumber *)Nmax
                            confidenceMin:(nullable NSNumber *)confidenceMin
                                 progress:(nullable void (^)(NSProgress *progress))progress;

@end

NS_ASSUME_NONNULL_END
