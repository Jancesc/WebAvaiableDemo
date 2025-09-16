#import "ZKServerResponse.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerDataResponse : ZKServerResponse
@property(nonatomic, copy) NSString* XSNTC_contentType;  


+ (instancetype)FDD_responseWithXSNTC_Data:(NSData*)data XSNTC_contentType:(NSString*)type;


- (instancetype)initWithData:(NSData*)data XSNTC_contentType:(NSString*)type;



+ (nullable instancetype)FDD_responseWithText:(NSString*)text;


+ (nullable instancetype)FDD_responseWithHTML:(NSString*)html;


+ (nullable instancetype)FDD_responseWithHTMLTemplate:(NSString*)path XSNTC_variables:(NSDictionary<NSString*, NSString*>*)variables;


+ (nullable instancetype)FDD_responseWithJSONObject:(id)object;


+ (nullable instancetype)FDD_responseWithJSONObject:(id)object XSNTC_contentType:(NSString*)type;


- (nullable instancetype)initWithXSNTC_Text:(NSString*)text;


- (nullable instancetype)initWithXSNTC_HTML:(NSString*)html;


- (nullable instancetype)initWithXSNTC_HTMLTemplate:(NSString*)path XSNTC_variables:(NSDictionary<NSString*, NSString*>*)variables;


- (nullable instancetype)initWithXSNTC_JSONObject:(id)object;


- (nullable instancetype)initWithXSNTC_JSONObject:(id)object XSNTC_contentType:(NSString*)type;

@end

NS_ASSUME_NONNULL_END
