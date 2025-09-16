#import <Foundation/Foundation.h>
#import "ZKHeader.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZKServerResponse : NSObject <XSNTC_jkServerBodyReader>


@property(nonatomic, copy, nullable) NSString* XSNTC_contentType;


@property(nonatomic) NSUInteger DDP_contentLength;


@property(nonatomic) NSInteger DDP_statusCode;


@property(nonatomic) NSUInteger DDP_cacheControlMaxAge;


@property(nonatomic, nullable) NSDate* DDP_lastModifiedDate;


@property(nonatomic, copy, nullable) NSString* DDP_eTag;


@property(nonatomic) BOOL DDP_gzipContentEncodingEnabled;


+ (instancetype)FDD_response;


- (instancetype)init;


- (void)FDD_setValue:(nullable NSString*)value XSNTC_forAdditionalHeader:(NSString*)header;


- (BOOL)FDD_hasBody;

+ (instancetype)FDD_responseWithStatusCode:(NSInteger)statusCode;


+ (instancetype)FDD_responseWithRedirect:(NSURL*)location XSNTC_permanent:(BOOL)permanent;


- (instancetype)initWithXSNTC_StatusCode:(NSInteger)statusCode;


- (instancetype)initWXSNTC_ithRedirect:(NSURL*)location XSNTC_permanent:(BOOL)permanent;

@end

NS_ASSUME_NONNULL_END
