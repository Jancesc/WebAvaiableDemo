#import "ZKServerDataResponse.h"
#import "ZKServerHTTPStatusCodes.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerErrorResponse : ZKServerDataResponse


+ (instancetype)FDD_responseWithClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(2, 3);


+ (instancetype)FDD_responseWithServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(2, 3);


+ (instancetype)FDD_responseWithClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(nullable NSError*)underlyingError XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(3, 4);


+ (instancetype)FDD_responseWithServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(nullable NSError*)underlyingError XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(3, 4);


- (instancetype)initWithXSNTC_ClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(2, 3);


- (instancetype)initWithXSNTC_ServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(2, 3);


- (instancetype)initWithXSNTC_ClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(nullable NSError*)underlyingError XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(3, 4);


- (instancetype)initWithXSNTC_ServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(nullable NSError*)underlyingError XSNTC_message:(NSString*)format, ... NS_FORMAT_FUNCTION(3, 4);

@end

NS_ASSUME_NONNULL_END
