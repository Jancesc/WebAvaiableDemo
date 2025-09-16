#import <TargetConditionals.h>
#import "ZKServerRequest.h"
#import "ZKServerResponse.h"

NS_ASSUME_NONNULL_BEGIN

typedef ZKServerRequest* _Nullable (^XSNTC_jkServerMatchBlock)(NSString* requestMethod, NSURL* requestURL, NSDictionary<NSString*, NSString*>* requestHeaders, NSString* urlPath, NSDictionary<NSString*, NSString*>* urlQuery);

typedef ZKServerResponse* _Nullable (^XSNTC_jkServerProcessBlock)(__kindof ZKServerRequest* request);
typedef void (^XSNTC_jkServerCompletionBlock)(ZKServerResponse* _Nullable response);
typedef void (^XSNTC_jkServerAsyncProcessBlock)(__kindof ZKServerRequest* request, XSNTC_jkServerCompletionBlock completionBlock);

#define ZKBase64Decode(str) [[NSString alloc]initWithData:[[NSData alloc]initWithBase64EncodedString:str options:0] encoding: NSUTF8StringEncoding]



extern NSString* const XSNTC_jkServerOption_Port;


extern NSString* const XSNTC_jkServerOption_BonjourName;


extern NSString* const XSNTC_jkServerOption_BonjourTXTData;


extern NSString* const XSNTC_jkServerOption_BonjourType;


extern NSString* const XSNTC_jkServerOption_RequestNATPortMapping;


extern NSString* const XSNTC_jkServerOption_BindToLocalhost;


extern NSString* const XSNTC_jkServerOption_MaxPendingConnections;


extern NSString* const XSNTC_jkServerOption_ServerName;


extern NSString* const XSNTC_jkServerOption_AuthenticationMethod;


extern NSString* const XSNTC_jkServerOption_AuthenticationRealm;


extern NSString* const XSNTC_jkServerOption_AuthenticationAccounts;


extern NSString* const XSNTC_jkServerOption_ConnectionClass;


extern NSString* const XSNTC_jkServerOption_AutomaticallyMapHEADToGET;


extern NSString* const XSNTC_jkServerOption_ConnectedStateCoalescingInterval;


extern NSString* const XSNTC_jkServerOption_DispatchQueuePriority;

extern NSString* const XSNTC_jkServerOption_AutomaticallySuspendInBackground;



extern NSString* const XSNTC_jkServerAuthenticationMethod_Basic;


extern NSString* const XSNTC_jkServerAuthenticationMethod_DigestAccess;

@class ZKServerModule;


@protocol XSNTC_jkServerDelegate <NSObject>
@optional


- (void)FDD_webServerDidStart:(ZKServerModule*)server;


- (void)FDD_webServerDidCompleteBonjourRegistration:(ZKServerModule*)server;


- (void)FDD_webServerDidUpdateNATPortMapping:(ZKServerModule*)server;


- (void)FDD_webServerDidConnect:(ZKServerModule*)server;


- (void)FDD_webServerDidDisconnect:(ZKServerModule*)server;


- (void)FDD_webServerDidStop:(ZKServerModule*)server;

@end


@interface ZKServerModule : NSObject

@property(nonatomic, weak, nullable) id<XSNTC_jkServerDelegate> delegate;

@property(nonatomic) NSUInteger DDP_port;


@property(nonatomic, nullable) NSString* DDP_bonjourName;


@property(nonatomic, nullable) NSString* DDP_bonjourType;


@property(nonatomic, nullable) NSURL* DDP_serverURL;


@property(nonatomic, nullable) NSURL* DDP_bonjourServerURL;


@property(nonatomic, nullable) NSURL* DDP_publicServerURL;


- (instancetype)init;


- (void)FDD_addHandlerWithMatchBlock:(XSNTC_jkServerMatchBlock)matchBlock XSNTC_processBlock:(XSNTC_jkServerProcessBlock)processBlock;


- (void)FDD_addHandlerWithMatchBlock:(XSNTC_jkServerMatchBlock)matchBlock XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)processBlock;


- (void)FDD_removeAllHandlers;


- (BOOL)FDD_startWithOptions:(nullable NSDictionary<NSString*, id>*)options error:(NSError** _Nullable)error;


- (void)FDD_stop;


- (BOOL)FDD_start;


- (BOOL)FDD_startWithPort:(NSUInteger)port XSNTC_bonjourName:(nullable NSString*)name;



- (void)FDD_addDefaultHandlerForMethod:(NSString*)method XSNTC_requestClass:(Class)aClass XSNTC_processBlock:(XSNTC_jkServerProcessBlock)block;


- (void)FDD_addDefaultHandlerForMethod:(NSString*)method XSNTC_requestClass:(Class)aClass XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)block;


- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_path:(NSString*)path XSNTC_requestClass:(Class)aClass XSNTC_processBlock:(XSNTC_jkServerProcessBlock)block;


- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_path:(NSString*)path requestClass:(Class)aClass asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)block;


- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_pathRegex:(NSString*)regex XSNTC_requestClass:(Class)aClass XSNTC_processBlock:(XSNTC_jkServerProcessBlock)block;


- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_pathRegex:(NSString*)regex XSNTC_requestClass:(Class)aClass XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)block;

- (void)FDD_addGETHandlerForPath:(NSString*)path XSNTC_staticData:(NSData*)staticData XSNTC_contentType:(nullable NSString*)XSNTC_contentType XSNTC_cacheAge:(NSUInteger)cacheAge;


- (void)FDD_addGETHandlerForPath:(NSString*)path XSNTC_filePath:(NSString*)filePath XSNTC_isAttachment:(BOOL)isAttachment XSNTC_cacheAge:(NSUInteger)cacheAge XSNTC_allowRangeRequests:(BOOL)allowRangeRequests;


- (void)FDD_addGETHandlerForBasePath:(NSString*)basePath XSNTC_directoryPath:(NSString*)directoryPath XSNTC_indexFilename:(nullable NSString*)indexFilename XSNTC_cacheAge:(NSUInteger)cacheAge XSNTC_allowRangeRequests:(BOOL)allowRangeRequests;

@end


NS_ASSUME_NONNULL_END
