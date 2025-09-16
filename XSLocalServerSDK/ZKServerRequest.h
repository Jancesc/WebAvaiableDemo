#import <Foundation/Foundation.h>
#import "ZKHeader.h"
@interface ZKServerRequest : NSObject <XSNTC_jkServerBodyWriter>


@property(nonatomic) NSString* DDP_method;


@property(nonatomic) NSURL* DDP_URL;


@property(nonatomic) NSDictionary<NSString*, NSString*>* DDP_headers;


@property(nonatomic) NSString* DDP_path;


@property(nonatomic, nullable) NSDictionary<NSString*, NSString*>* DDP_query;


@property(nonatomic, nullable) NSString* XSNTC_contentType;


@property(nonatomic) NSUInteger DDP_contentLength;


@property(nonatomic, nullable) NSDate* DDP_ifModifiedSince;


@property(nonatomic, nullable) NSString* DDP_ifNoneMatch;


@property(nonatomic) NSRange DDP_byteRange;


@property(nonatomic) BOOL DDP_acceptsGzipContentEncoding;


@property(nonatomic) NSData* DDP_localAddressData;


@property(nonatomic) NSString* DDP_localAddressString;


@property(nonatomic) NSData* DDP_remoteAddressData;


@property(nonatomic) NSString* DDP_remoteAddressString;

@property(nonatomic) BOOL DDP_usesChunkedTransferEncoding;
- (void)FDD_prepareForWriting;
- (BOOL)FDD_performOpen:(NSError**)error;
- (BOOL)FDD_performWriteData:(NSData*)data error:(NSError**)error;
- (BOOL)FDD_performClose:(NSError**)error;
- (void)FDD_setAttribute:(nullable id)attribute XSNTC_forKey:(NSString*)key;
- (instancetype)initWithXSNTC_Method:(NSString*)method XSNTC_url:(NSURL*)url XSNTC_headers:(NSDictionary<NSString*, NSString*>*)headers XSNTC_path:(NSString*)path XSNTC_query:(nullable NSDictionary<NSString*, NSString*>*)query;


- (BOOL)FDD_hasBody;


- (BOOL)FDD_hasByteRange;


- (nullable id)FDD_attributeForKey:(NSString*)key;

@end
