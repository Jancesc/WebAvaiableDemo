#import "ZKServerResponse.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerFileResponse : ZKServerResponse
@property(nonatomic, copy) NSString* XSNTC_contentType;  
@property(nonatomic) NSDate* DDP_lastModifiedDate;  
@property(nonatomic, copy) NSString* DDP_eTag;  

@property(nonatomic, strong) NSString* DDP_path;
@property(nonatomic, assign) NSUInteger DDP_offset;
@property(nonatomic, assign) NSUInteger DDP_size;
@property(nonatomic, assign) int DDP_file;

+ (nullable instancetype)FDD_responseWithFile:(NSString*)path;


+ (nullable instancetype)FDD_responseWithFile:(NSString*)path XSNTC_isAttachment:(BOOL)attachment;


+ (nullable instancetype)FDD_responseWithFile:(NSString*)path XSNTC_byteRange:(NSRange)range;


+ (nullable instancetype)FDD_responseWithFile:(NSString*)path XSNTC_byteRange:(NSRange)range XSNTC_isAttachment:(BOOL)attachment;


- (nullable instancetype)initWithXSNTC_File:(NSString*)path;


- (nullable instancetype)initWithXSNTC_File:(NSString*)path XSNTC_isAttachment:(BOOL)attachment;


- (nullable instancetype)initWithXSNTC_File:(NSString*)path XSNTC_byteRange:(NSRange)range;


- (nullable instancetype)initWithXSNTC_File:(NSString*)path XSNTC_byteRange:(NSRange)range XSNTC_isAttachment:(BOOL)attachment XSNTC_mimeTypeOverrides:(nullable NSDictionary<NSString*, NSString*>*)overrides;

@end

NS_ASSUME_NONNULL_END
