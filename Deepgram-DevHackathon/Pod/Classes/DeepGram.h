@import Foundation;
@class AFHTTPSessionManager;
@class DGMatch;

NS_ASSUME_NONNULL_BEGIN

extern NSString *const DGBaseURLString;
extern NSString *const DGErrorDomain;
extern NSString *const DGErrorInfoKey;

typedef NS_ENUM(NSUInteger, DGIndexStatus)
{
    DGIndexStatusInProgress,
    DGIndexStatusDone,
};

@interface DGClient : NSObject

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithHTTPSession:(AFHTTPSessionManager *)session userID:(NSString *)userID NS_DESIGNATED_INITIALIZER;

- (NSURLSessionDataTask *)getBalanceWithProgress:(nullable void (^)(NSProgress *progress))progress
                                         success:(nullable void (^)(NSURLSessionDataTask *task, NSNumber *hours))success
                                         failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)indexURL:(NSURL *)audioURL
                          progress:(nullable void (^)(NSProgress *progress))progress
                           success:(nullable void (^)(NSURLSessionDataTask *task, NSString *contentID))success
                           failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;


- (NSURLSessionDataTask *)statusOfContent:(NSString *)contentID
                                 progress:(nullable void (^)(NSProgress *progress))progress
                                  success:(nullable void (^)(NSURLSessionDataTask *task, NSNumber *indexStatus))success
                                  failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;


- (NSURLSessionDataTask *)matchesInContent:(NSString *)contentID
                                 withQuery:(NSString *)query
                                   snippet:(BOOL)snippet
                                      Nmax:(nullable NSNumber *)Nmax
                             confidenceMin:(nullable NSNumber *)confidenceMin
                                  progress:(nullable void (^)(NSProgress *progress))progress
                                   success:(nullable void (^)(NSURLSessionDataTask *task, NSArray<DGMatch *> *matches))success
                                   failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;


- (NSURLSessionDataTask *)transcriptForContent:(NSString *)contentID
                                      progress:(nullable void (^)(NSProgress *progress))progress
                                       success:(nullable void (^)(NSURLSessionDataTask *task, NSDictionary<NSNumber *, NSString *> *paragraphsByStartTime))success
                                       failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;


- (NSURLSessionDataTask *)searchAllContentWithQuery:(NSString *)query
                                                tag:(nullable NSString *)tag
                                               Nmax:(nullable NSNumber *)Nmax
                                      confidenceMin:(nullable NSNumber *)confidenceMin
                                           progress:(nullable void (^)(NSProgress *progress))progress
                                            success:(nullable void (^)(NSURLSessionDataTask *task, NSArray<DGMatch *> *matches))success
                                            failure:(nullable void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@property (nonatomic, readonly) AFHTTPSessionManager *session;


@property (nonatomic, readonly) NSString *userID;

@end


@interface DGClient (Convenience)

- (instancetype)initWithUserID:(NSString *)userID;

@end

@interface DGMatch : NSObject

@property (nonatomic, readonly) NSString *contentID;
@property (nonatomic, readonly, nullable) NSNumber *startTime;
@property (nonatomic, readonly, nullable) NSNumber *endTime;
@property (nonatomic, readonly) NSNumber *confidence;
@property (nonatomic, readonly, nullable) NSString *snippet;

@end

NS_ASSUME_NONNULL_END
