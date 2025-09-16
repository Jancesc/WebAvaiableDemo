#import "ZKServerModule.h"

NS_ASSUME_NONNULL_BEGIN

@class ZKServerHandler;


@interface ZKServerConnection : NSObject


@property(nonatomic) ZKServerModule* DDP_server;


@property(nonatomic) BOOL DDP_usingIPv6;


@property(nonatomic) NSData* DDP_localAddressData;


@property(nonatomic) NSString* DDP_localAddressString;


@property(nonatomic) NSData* DDP_remoteAddressData;


@property(nonatomic) NSString* DDP_remoteAddressString;


@property(nonatomic) NSUInteger DDP_totalBytesRead;


@property(nonatomic) NSUInteger DDP_totalBytesWritten;



- (BOOL)FDD_open;


- (void)FDD_didReadBytes:(const void*)bytes XSNTC_length:(NSUInteger)length;


- (void)FDD_didWriteBytes:(const void*)bytes XSNTC_length:(NSUInteger)length;


- (NSURL*)FDD_rewriteRequestURL:(NSURL*)url XSNTC_withMethod:(NSString*)method XSNTC_headers:(NSDictionary<NSString*, NSString*>*)headers;


- (nullable ZKServerResponse*)FDD_preflightRequest:(ZKServerRequest*)request;


- (void)FDD_processRequest:(ZKServerRequest*)request XSNTC_completion:(XSNTC_jkServerCompletionBlock)completion;


- (ZKServerResponse*)FDD_overrideResponse:(ZKServerResponse*)response XSNTC_forRequest:(ZKServerRequest*)request;


- (void)FDD_abortRequest:(nullable ZKServerRequest*)request XSNTC_withStatusCode:(NSInteger)statusCode;


- (void)FDD_close;

@end

NS_ASSUME_NONNULL_END
