#import <os/object.h>
#import <sys/socket.h>

#import "ZKHeader.h"

#import "ZKServerHTTPStatusCodes.h"
#import "ZKServerFunctions.h"

#import "ZKServerModule.h"
#import "ZKServerConnection.h"

#import "ZKServerDataRequest.h"
#import "ZKServerFileRequest.h"
#import "ZKServerMultiPartFormRequest.h"
#import "ZKServerURLEncodedFormRequest.h"

#import "ZKServerDataResponse.h"
#import "ZKServerErrorResponse.h"
#import "ZKServerFileResponse.h"
#import "ZKServerStreamedResponse.h"




#define GWS_DCHECK(__CONDITION__)
#define GWS_DNOT_REACHED()
#define kZKServerDefaultMimeType @"application/octet-stream"
#define kZKServerErrorDomain @"ZKServerErrorDomain"

static inline BOOL XSNTC_KServerIsValidByteRange(NSRange range) {
  return ((range.location != NSUIntegerMax) || (range.length > 0));
}

static inline NSError* XSNTC_KServerMakePosixError(int code) {
  return [NSError errorWithDomain:NSPOSIXErrorDomain code:code userInfo:@{NSLocalizedDescriptionKey : (NSString*)[NSString stringWithUTF8String:strerror(code)]}];
}

extern void XSNTC_jkServerInitializeFunctions(void);
extern NSString* _Nullable XSNTC_jkServerNormalizeHeaderValue(NSString* _Nullable value);
extern NSString* _Nullable XSNTC_jkServerTruncateHeaderValue(NSString* _Nullable value);
extern NSString* _Nullable XSNTC_jkServerExtractHeaderValueParameter(NSString* _Nullable value, NSString* attribute);
extern NSStringEncoding XSNTC_jkServerStringEncodingFromCharset(NSString* charset);
extern BOOL XSNTC_jkServerIsTextContentType(NSString* type);
extern NSString* XSNTC_jkServerDescribeData(NSData* data, NSString* XSNTC_contentType);
extern NSString* XSNTC_jkServerComputeMD5Digest(NSString* format, ...) NS_FORMAT_FUNCTION(1, 2);
extern NSString* XSNTC_jkServerStringFromSockAddr(const struct sockaddr* addr, BOOL includeService);

@interface ZKServerConnection ()
- (instancetype)initWithXSNTC_Server:(ZKServerModule*)server XSNTC_localAddress:(NSData*)localAddress XSNTC_remoteAddress:(NSData*)remoteAddress XSNTC_socket:(CFSocketNativeHandle)socket;
@end

@interface ZKServerModule ()
@property(nonatomic) NSMutableArray<ZKServerHandler*>* DDP_handlers;
@property(nonatomic, nullable) NSString* DDP_serverName;
@property(nonatomic, nullable) NSString* DDP_authenticationRealm;
@property(nonatomic, nullable) NSMutableDictionary<NSString*, NSString*>* DDP_authenticationBasicAccounts;
@property(nonatomic, nullable) NSMutableDictionary<NSString*, NSString*>* DDP_authenticationDigestAccounts;
@property(nonatomic) BOOL DDP_shouldAutomaticallyMapHEADToGET;
@property(nonatomic) dispatch_queue_priority_t DDP_dispatchQueuePriority;
- (void)FDD_willStartConnection:(ZKServerConnection*)connection;
- (void)FDD_didEndConnection:(ZKServerConnection*)connection;
@end

@interface ZKServerHandler : NSObject
@property(nonatomic) XSNTC_jkServerMatchBlock DDP_matchBlock;
@property(nonatomic) XSNTC_jkServerAsyncProcessBlock DDP_asyncProcessBlock;
@end

@interface ZKServerResponse ()
@property(nonatomic) NSDictionary<NSString*, NSString*>* DDP_additionalHeaders;
@property(nonatomic) BOOL DDP_usesChunkedTransferEncoding;
- (void)FDD_prepareForReading;
- (BOOL)FDD_performOpen:(NSError**)error;
- (void)FDD_performReadDataWithCompletion:(XSNTC_jkServerBodyReaderCompletionBlock)block;
- (void)FDD_performClose;
@end

