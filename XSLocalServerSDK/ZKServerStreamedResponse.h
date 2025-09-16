#import "ZKServerResponse.h"
#import "ZKHeader.h"
NS_ASSUME_NONNULL_BEGIN


typedef NSData* _Nullable (^XSNTC_jkServerStreamBlock)(NSError** error);
typedef void (^XSNTC_jkServerAsyncStreamBlock)(XSNTC_jkServerBodyReaderCompletionBlock completionBlock);


@interface ZKServerStreamedResponse : ZKServerResponse
@property(nonatomic, copy) NSString* XSNTC_contentType;  


+ (instancetype)FDD_responseWithXSNTC_contentType:(NSString*)type XSNTC_stream_gBlock:(XSNTC_jkServerStreamBlock)block;


+ (instancetype)FDD_responseWithXSNTC_contentType:(NSString*)type XSNTC_asyncStreamBlock:(XSNTC_jkServerAsyncStreamBlock)block;


- (instancetype)initWithXSNTC_contentType:(NSString*)type XSNTC_stream_gBlock:(XSNTC_jkServerStreamBlock)block;


- (instancetype)initWithXSNTC_contentType:(NSString*)type XSNTC_asyncStreamBlock:(XSNTC_jkServerAsyncStreamBlock)block;

@end

NS_ASSUME_NONNULL_END
