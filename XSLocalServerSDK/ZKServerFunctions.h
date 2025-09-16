#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef __cplusplus
extern "C" {
#endif


NSString* XSNTC_jkServerGetMimeTypeForExtension(NSString* extension, NSDictionary<NSString*, NSString*>* _Nullable overrides);


NSString* _Nullable XSNTC_jkServerEscapeURLString(NSString* string);


NSString* _Nullable XSNTC_jkServerUnescapeURLString(NSString* string);


NSDictionary<NSString*, NSString*>* XSNTC_jkServerParseURLEncodedForm(NSString* form);


NSString* _Nullable XSNTC_jkServerGetPrimaryIPAddress(BOOL useIPv6);


NSString* XSNTC_jkServerFormatRFC822(NSDate* date);


NSDate* _Nullable XSNTC_jkServerParseRFC822(NSString* string);


NSString* XSNTC_jkServerFormatISO8601(NSDate* date);


NSDate* _Nullable XSNTC_jkServerParseISO8601(NSString* string);


NSString* XSNTC_jkServerNormalizePath(NSString* path);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END
