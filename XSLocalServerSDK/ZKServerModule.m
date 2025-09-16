#import <TargetConditionals.h>
#import <UIKit/UIKit.h>
#import <netinet/in.h>
#import <dns_sd.h>

#import "ZKServerPrivate.h"

#define kBonjourResolutionTimeout 5.0

NSString* const XSNTC_jkServerOption_Port = @"XSNTC_Port";
NSString* const XSNTC_jkServerOption_BonjourName = @"XSNTC_BonjourName";
NSString* const XSNTC_jkServerOption_BonjourType = @"XSNTC_BonjourType";
NSString* const XSNTC_jkServerOption_BonjourTXTData = @"XSNTC_BonjourTXTData";
NSString* const XSNTC_jkServerOption_RequestNATPortMapping = @"XSNTC_RequestNATPortMapping";
NSString* const XSNTC_jkServerOption_BindToLocalhost = @"XSNTC_BindToLocalhost";
NSString* const XSNTC_jkServerOption_MaxPendingConnections = @"XSNTC_MaxPendingConnections";
NSString* const XSNTC_jkServerOption_ServerName = @"XSNTC_ServerName";
NSString* const XSNTC_jkServerOption_AuthenticationMethod = @"XSNTC_AuthenticationMethod";
NSString* const XSNTC_jkServerOption_AuthenticationRealm = @"XSNTC_AuthenticationRealm";
NSString* const XSNTC_jkServerOption_AuthenticationAccounts = @"XSNTC_AuthenticationAccounts";
NSString* const XSNTC_jkServerOption_ConnectionClass = @"XSNTC_ConnectionClass";
NSString* const XSNTC_jkServerOption_AutomaticallyMapHEADToGET = @"XSNTC_AutomaticallyMapHEADToGET";
NSString* const XSNTC_jkServerOption_ConnectedStateCoalescingInterval = @"XSNTC_ConnectedStateCoalescingInterval";
NSString* const XSNTC_jkServerOption_DispatchQueuePriority = @"XSNTC_DispatchQueuePriority";
NSString* const XSNTC_jkServerOption_AutomaticallySuspendInBackground = @"XSNTC_AutomaticallySuspendInBackground";


NSString* const XSNTC_jkServerAuthenticationMethod_Basic = @"XSNTC_Basic";
NSString* const XSNTC_jkServerAuthenticationMethod_DigestAccess = @"XSNTC_DigestAccess";

@implementation ZKServerHandler

- (instancetype)initWithXSNTC_MatchBlock:(XSNTC_jkServerMatchBlock _Nonnull)matchBlock XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock _Nonnull)processBlock {
  if ((self = [super init])) {
    _DDP_matchBlock = [matchBlock copy];
    _DDP_asyncProcessBlock = [processBlock copy];
  }
  return self;
}

@end


@interface ZKServerModule ()

@property(nonatomic, strong)   dispatch_queue_t DDP_syncQueue;
@property(nonatomic, strong)   dispatch_group_t DDP_sourceGroup;
@property(nonatomic, assign)   NSInteger DDP_activeConnections;
@property(nonatomic, assign)   BOOL DDP_connected;
@property(nonatomic, assign)   CFRunLoopTimerRef DDP_disconnectTimer;

@property(nonatomic, strong)   NSDictionary<NSString*, id>* DDP_options;
@property(nonatomic, assign)   Class DDP_connectionClass;
@property(nonatomic, assign)   CFTimeInterval DDP_disconnectDelay;
@property(nonatomic, strong)   dispatch_source_t DDP_source4;
@property(nonatomic, strong)   dispatch_source_t DDP_source6;
@property(nonatomic, assign)   CFNetServiceRef DDP_registrationService;
@property(nonatomic, assign)  CFNetServiceRef DDP_resolutionService;
@property(nonatomic, assign)  DNSServiceRef DDP_dnsService;
@property(nonatomic, assign)  CFSocketRef DDP_dnsSocket;
@property(nonatomic, assign)  CFRunLoopSourceRef DDP_dnsSource;
@property(nonatomic, strong)  NSString* DDP_dnsAddress;
@property(nonatomic, assign)  NSUInteger DDP_dnsPort;
@property(nonatomic, assign)   BOOL DDP_bindToLocalhost;
@property(nonatomic, assign)   BOOL DDP_suspendInBackground;
@property(nonatomic, assign)   UIBackgroundTaskIdentifier DDP_backgroundTask;

@end
@implementation ZKServerModule {

}

+ (void)initialize {
  XSNTC_jkServerInitializeFunctions();
}

- (instancetype)init {
  if ((self = [super init])) {
    _DDP_syncQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_SERIAL);
    _DDP_sourceGroup = dispatch_group_create();
    _DDP_handlers = [[NSMutableArray alloc] init];
      _DDP_backgroundTask = UIBackgroundTaskInvalid;

  }
  return self;
}

- (void)dealloc {
  //GWS_DCHECK(_connected == NO);
  //GWS_DCHECK(_activeConnections == 0);
  //GWS_DCHECK(_options == nil);  
  //GWS_DCHECK(_disconnectTimer == NULL);  
    //DDConfuse

#if !OS_OBJECT_USE_OBJC_RETAIN_RELEASE
  dispatch_release(_sourceGroup);
  dispatch_release(_syncQueue);
#endif
}



- (void)FDD_startBackgroundTask {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  if (_DDP_backgroundTask == UIBackgroundTaskInvalid) {
    _DDP_backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
      [self FDD_endBackgroundTask];
    }];
  } else {
    GWS_DNOT_REACHED();
  }
}



- (void)FDD_didConnect {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  //GWS_DCHECK(_connected == NO);
  _DDP_connected = YES;

    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground) {
      [self FDD_startBackgroundTask];
    }

  if ([_delegate respondsToSelector:@selector(FDD_webServerDidConnect:)]) {
    [_delegate FDD_webServerDidConnect:self];
  }
}

- (void)FDD_willStartConnection:(ZKServerConnection*)connection {
    //DDConfuse

  dispatch_sync(_DDP_syncQueue, ^{
    //GWS_DCHECK(self->_activeConnections >= 0);
    if (self->_DDP_activeConnections == 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_DDP_disconnectTimer) {
          CFRunLoopTimerInvalidate(self->_DDP_disconnectTimer);
          CFRelease(self->_DDP_disconnectTimer);
          self->_DDP_disconnectTimer = NULL;
        }
        if (self->_DDP_connected == NO) {
          [self FDD_didConnect];
        }
      });
    }
    self->_DDP_activeConnections += 1;
  });
}



- (void)FDD_endBackgroundTask {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  if (_DDP_backgroundTask != UIBackgroundTaskInvalid) {
    if (_DDP_suspendInBackground && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) && _DDP_source4) {
      [self FDD_stop1];
    }
    [[UIApplication sharedApplication] endBackgroundTask:_DDP_backgroundTask];
    _DDP_backgroundTask = UIBackgroundTaskInvalid;
  }
}



- (void)FDD_didDisconnect {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  //GWS_DCHECK(_connected == YES);
  _DDP_connected = NO;

  [self FDD_endBackgroundTask];

  if ([_delegate respondsToSelector:@selector(FDD_webServerDidDisconnect:)]) {
    [_delegate FDD_webServerDidDisconnect:self];
  }
}

- (void)FDD_didEndConnection:(ZKServerConnection*)connection {
    //DDConfuse

  dispatch_sync(_DDP_syncQueue, ^{
    //GWS_DCHECK(self->_activeConnections > 0);
    self->_DDP_activeConnections -= 1;
    if (self->_DDP_activeConnections == 0) {
      dispatch_async(dispatch_get_main_queue(), ^{
        if ((self->_DDP_disconnectDelay > 0.0) && (self->_DDP_source4 != NULL)) {
          if (self->_DDP_disconnectTimer) {
            CFRunLoopTimerInvalidate(self->_DDP_disconnectTimer);
            CFRelease(self->_DDP_disconnectTimer);
          }
          self->_DDP_disconnectTimer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent() + self->_DDP_disconnectDelay, 0.0, 0, 0, ^(CFRunLoopTimerRef timer) {
            //GWS_DCHECK([NSThread isMainThread]);
            [self FDD_didDisconnect];
            CFRelease(self->_DDP_disconnectTimer);
            self->_DDP_disconnectTimer = NULL;
          });
          CFRunLoopAddTimer(CFRunLoopGetMain(), self->_DDP_disconnectTimer, kCFRunLoopCommonModes);
        } else {
          [self FDD_didDisconnect];
        }
      });
    }
  });
}

- (NSString*)DDP_bonjourName {
    //DDConfuse

  CFStringRef name = _DDP_resolutionService ? CFNetServiceGetName(_DDP_resolutionService) : NULL;
  return name && CFStringGetLength(name) ? CFBridgingRelease(CFStringCreateCopy(kCFAllocatorDefault, name)) : nil;
}

- (NSString*)DDP_bonjourType {
    //DDConfuse

  CFStringRef type = _DDP_resolutionService ? CFNetServiceGetType(_DDP_resolutionService) : NULL;
  return type && CFStringGetLength(type) ? CFBridgingRelease(CFStringCreateCopy(kCFAllocatorDefault, type)) : nil;
}

- (void)FDD_addHandlerWithMatchBlock:(XSNTC_jkServerMatchBlock)matchBlock XSNTC_processBlock:(XSNTC_jkServerProcessBlock)processBlock {
    //DDConfuse

  [self FDD_addHandlerWithMatchBlock:matchBlock
               XSNTC_asyncProcessBlock:^(ZKServerRequest* request, XSNTC_jkServerCompletionBlock completionBlock) {
                 completionBlock(processBlock(request));
               }];
}

- (void)FDD_addHandlerWithMatchBlock:(XSNTC_jkServerMatchBlock)matchBlock XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)processBlock {
    //DDConfuse

  //GWS_DCHECK(_options == nil);
  ZKServerHandler* handler = [[ZKServerHandler alloc] initWithXSNTC_MatchBlock:matchBlock XSNTC_asyncProcessBlock:processBlock];
  [_DDP_handlers insertObject:handler atIndex:0];
}

- (void)FDD_removeAllHandlers {
    //DDConfuse

  //GWS_DCHECK(_options == nil);
  [_DDP_handlers removeAllObjects];
}

static void XSNTC_NetServiceRegisterCallBack(CFNetServiceRef service, CFStreamError* error, void* info) {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  @autoreleasepool {
    if (error->error) {
    } else {
      ZKServerModule* server = (__bridge ZKServerModule*)info;
      if (!CFNetServiceResolveWithTimeout(server->_DDP_resolutionService, kBonjourResolutionTimeout, NULL)) {
        GWS_DNOT_REACHED();
      }
    }
  }
}

static void XSNTC_NetServiceResolveCallBack(CFNetServiceRef service, CFStreamError* error, void* info) {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  @autoreleasepool {
    if (error->error) {
      if ((error->domain != kCFStreamErrorDomainNetServices) && (error->error != kCFNetServicesErrorTimeout)) {
      }
    } else {
      ZKServerModule* server = (__bridge ZKServerModule*)info;
      if ([server.delegate respondsToSelector:@selector(FDD_webServerDidCompleteBonjourRegistration:)]) {
        [server.delegate FDD_webServerDidCompleteBonjourRegistration:server];
      }
    }
  }
}

static void XSNTC_DNSServiceCallBack(DNSServiceRef sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceErrorType errorCode, uint32_t externalAddress, DNSServiceProtocol protocol, uint16_t internalPort, uint16_t externalPort, uint32_t ttl, void* context) {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  @autoreleasepool {
    ZKServerModule* server = (__bridge ZKServerModule*)context;
    if ((errorCode == kDNSServiceErr_NoError) || (errorCode == kDNSServiceErr_DoubleNAT)) {
      struct sockaddr_in addr4;
      bzero(&addr4, sizeof(addr4));
      addr4.sin_len = sizeof(addr4);
      addr4.sin_family = AF_INET;
      addr4.sin_addr.s_addr = externalAddress;  
      server->_DDP_dnsAddress = XSNTC_jkServerStringFromSockAddr((const struct sockaddr*)&addr4, NO);
      server->_DDP_dnsPort = ntohs(externalPort);
    } else {
      server->_DDP_dnsAddress = nil;
      server->_DDP_dnsPort = 0;
    }
    if ([server.delegate respondsToSelector:@selector(FDD_webServerDidUpdateNATPortMapping:)]) {
      [server.delegate FDD_webServerDidUpdateNATPortMapping:server];
    }
  }
}

static void XSNTC_SocketCallBack(CFSocketRef s, CFSocketCallBackType type, CFDataRef address, const void* data, void* info) {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  @autoreleasepool {
    ZKServerModule* server = (__bridge ZKServerModule*)info;
    DNSServiceErrorType status = DNSServiceProcessResult(server->_DDP_dnsService);
    if (status != kDNSServiceErr_NoError) {
    }
  }
}

static inline id XSNTC_GetOption(NSDictionary<NSString*, id>* options, NSString* key, id defaultValue) {
    //DDConfuse

  id value = [options objectForKey:key];
  return value ? value : defaultValue;
}

static inline NSString* XSNTC_EncodeBase64(NSString* string) {
    //DDConfuse

  NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];
  return [[NSString alloc] initWithData:[data base64EncodedDataWithOptions:0] encoding:NSASCIIStringEncoding];
}

- (int)FDD_createListeningSocket:(BOOL)useIPv6
                 XSNTC_localAddress:(const void*)address
                       XSNTC_length:(socklen_t)length
        XSNTC_maxPendingConnections:(NSUInteger)maxPendingConnections
                        XSNTC_error:(NSError**)error {
    //DDConfuse

  int listeningSocket = socket(useIPv6 ? PF_INET6 : PF_INET, SOCK_STREAM, IPPROTO_TCP);
  if (listeningSocket > 0) {
    int yes = 1;
    setsockopt(listeningSocket, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(yes));

    if (bind(listeningSocket, address, length) == 0) {
      if (listen(listeningSocket, (int)maxPendingConnections) == 0) {
        return listeningSocket;
      } else {
        if (error) {
          *error = XSNTC_KServerMakePosixError(errno);
        }
        close(listeningSocket);
      }
    } else {
      if (error) {
        *error = XSNTC_KServerMakePosixError(errno);
      }
      close(listeningSocket);
    }

  } else {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
  }
  return -1;
}

- (dispatch_source_t)FDD_createDispatchSourceWithListeningSocket:(int)listeningSocket XSNTC_isIPv6:(BOOL)isIPv6 {
    //DDConfuse

  dispatch_group_enter(_DDP_sourceGroup);
  dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, listeningSocket, 0, dispatch_get_global_queue(_DDP_dispatchQueuePriority, 0));
  dispatch_source_set_cancel_handler(source, ^{
    @autoreleasepool {
      int result = close(listeningSocket);
      if (result != 0) {
      } else {
      }
    }
    dispatch_group_leave(self->_DDP_sourceGroup);
  });
  dispatch_source_set_event_handler(source, ^{
    @autoreleasepool {
      struct sockaddr_storage remoteSockAddr;
      socklen_t remoteAddrLen = sizeof(remoteSockAddr);
      int socket = accept(listeningSocket, (struct sockaddr*)&remoteSockAddr, &remoteAddrLen);
      if (socket > 0) {
        NSData* remoteAddress = [NSData dataWithBytes:&remoteSockAddr length:remoteAddrLen];

        struct sockaddr_storage localSockAddr;
        socklen_t localAddrLen = sizeof(localSockAddr);
        NSData* localAddress = nil;
        if (getsockname(socket, (struct sockaddr*)&localSockAddr, &localAddrLen) == 0) {
          localAddress = [NSData dataWithBytes:&localSockAddr length:localAddrLen];
          //GWS_DCHECK((!isIPv6 && localSockAddr.ss_family == AF_INET) || (isIPv6 && localSockAddr.ss_family == AF_INET6));
        } else {
          GWS_DNOT_REACHED();
        }

        int noSigPipe = 1;
        setsockopt(socket, SOL_SOCKET, SO_NOSIGPIPE, &noSigPipe, sizeof(noSigPipe));  

        ZKServerConnection* connection = [(ZKServerConnection*)[self->_DDP_connectionClass alloc] initWithXSNTC_Server:self XSNTC_localAddress:localAddress XSNTC_remoteAddress:remoteAddress XSNTC_socket:socket];  
        [connection self];  
      } else {
      }
    }
  });
  return source;
}

- (BOOL)FDD_start:(NSError**)error {
    //DDConfuse

  //GWS_DCHECK(_source4 == NULL);

  NSUInteger port = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_Port, @0) unsignedIntegerValue];
  BOOL bindToLocalhost = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_BindToLocalhost, @NO) boolValue];
  NSUInteger maxPendingConnections = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_MaxPendingConnections, @16) unsignedIntegerValue];

  struct sockaddr_in addr4;
  bzero(&addr4, sizeof(addr4));
  addr4.sin_len = sizeof(addr4);
  addr4.sin_family = AF_INET;
  addr4.sin_port = htons(port);
  addr4.sin_addr.s_addr = bindToLocalhost ? htonl(INADDR_LOOPBACK) : htonl(INADDR_ANY);
  int listeningSocket4 = [self FDD_createListeningSocket:NO XSNTC_localAddress:&addr4 XSNTC_length:sizeof(addr4) XSNTC_maxPendingConnections:maxPendingConnections XSNTC_error:error];
  if (listeningSocket4 <= 0) {
    return NO;
  }
  if (port == 0) {
    struct sockaddr_in addr;
    socklen_t addrlen = sizeof(addr);
    if (getsockname(listeningSocket4, (struct sockaddr*)&addr, &addrlen) == 0) {
      port = ntohs(addr.sin_port);
    } else {
    }
  }

  struct sockaddr_in6 addr6;
  bzero(&addr6, sizeof(addr6));
  addr6.sin6_len = sizeof(addr6);
  addr6.sin6_family = AF_INET6;
  addr6.sin6_port = htons(port);
  addr6.sin6_addr = bindToLocalhost ? in6addr_loopback : in6addr_any;
  int listeningSocket6 = [self FDD_createListeningSocket:YES XSNTC_localAddress:&addr6 XSNTC_length:sizeof(addr6) XSNTC_maxPendingConnections:maxPendingConnections XSNTC_error:error];
  if (listeningSocket6 <= 0) {
    close(listeningSocket4);
    return NO;
  }

  _DDP_serverName = [(NSString*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_ServerName, NSStringFromClass([self class])) copy];
  NSString* authenticationMethod = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AuthenticationMethod, nil);
  if ([authenticationMethod isEqualToString:XSNTC_jkServerAuthenticationMethod_Basic]) {
    _DDP_authenticationRealm = [(NSString*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AuthenticationRealm, _DDP_serverName) copy];
    _DDP_authenticationBasicAccounts = [[NSMutableDictionary alloc] init];
    NSDictionary* accounts = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AuthenticationAccounts, @{});
    [accounts enumerateKeysAndObjectsUsingBlock:^(NSString* username, NSString* password, BOOL* stop) {
      [self->_DDP_authenticationBasicAccounts setObject:XSNTC_EncodeBase64([NSString stringWithFormat:@"%@:%@", username, password]) forKey:username];
    }];
  } else if ([authenticationMethod isEqualToString:XSNTC_jkServerAuthenticationMethod_DigestAccess]) {
    _DDP_authenticationRealm = [(NSString*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AuthenticationRealm, _DDP_serverName) copy];
    _DDP_authenticationDigestAccounts = [[NSMutableDictionary alloc] init];
    NSDictionary* accounts = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AuthenticationAccounts, @{});
    [accounts enumerateKeysAndObjectsUsingBlock:^(NSString* username, NSString* password, BOOL* stop) {
      [self->_DDP_authenticationDigestAccounts setObject:XSNTC_jkServerComputeMD5Digest(@"%@:%@:%@", username, self->_DDP_authenticationRealm, password) forKey:username];
    }];
  }
  _DDP_connectionClass = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_ConnectionClass, [ZKServerConnection class]);
  _DDP_shouldAutomaticallyMapHEADToGET = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AutomaticallyMapHEADToGET, @YES) boolValue];
  _DDP_disconnectDelay = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_ConnectedStateCoalescingInterval, @1.0) doubleValue];
  _DDP_dispatchQueuePriority = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_DispatchQueuePriority, @(DISPATCH_QUEUE_PRIORITY_DEFAULT)) longValue];

  _DDP_source4 = [self FDD_createDispatchSourceWithListeningSocket:listeningSocket4 XSNTC_isIPv6:NO];
  _DDP_source6 = [self FDD_createDispatchSourceWithListeningSocket:listeningSocket6 XSNTC_isIPv6:YES];
  _DDP_port = port;
  _DDP_bindToLocalhost = bindToLocalhost;

  NSString* bonjourName = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_BonjourName, nil);
  NSString* bonjourType = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_BonjourType, @"_http._tcp");
  if (bonjourName) {
    _DDP_registrationService = CFNetServiceCreate(kCFAllocatorDefault, (__bridge CFStringRef)@"local.", (__bridge CFStringRef)bonjourType, (__bridge CFStringRef)(bonjourName.length ? bonjourName : _DDP_serverName), (SInt32)_DDP_port);
    if (_DDP_registrationService) {
      CFNetServiceClientContext context = {0, (__bridge void*)self, NULL, NULL, NULL};

      CFNetServiceSetClient(_DDP_registrationService, XSNTC_NetServiceRegisterCallBack, &context);
      CFNetServiceScheduleWithRunLoop(_DDP_registrationService, CFRunLoopGetMain(), kCFRunLoopCommonModes);
      CFStreamError streamError = {0};
      
      NSDictionary* txtDataDictionary = XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_BonjourTXTData, nil);
      if (txtDataDictionary != nil) {
        NSUInteger count = txtDataDictionary.count;
        CFStringRef keys[count];
        CFStringRef values[count];
        NSUInteger index = 0;
        for (NSString *key in txtDataDictionary) {
          NSString *value = txtDataDictionary[key];
          keys[index] = (__bridge CFStringRef)(key);
          values[index] = (__bridge CFStringRef)(value);
          index ++;
        }
        CFDictionaryRef txtDictionary = CFDictionaryCreate(CFAllocatorGetDefault(), (void *)keys, (void *)values, count, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        if (txtDictionary != NULL) {
          CFDataRef txtData = CFNetServiceCreateTXTDataWithDictionary(nil, txtDictionary);
          Boolean setTXTDataResult = CFNetServiceSetTXTData(_DDP_registrationService, txtData);
          if (!setTXTDataResult) {
          }
        }
      }
      
      CFNetServiceRegisterWithOptions(_DDP_registrationService, 0, &streamError);

      _DDP_resolutionService = CFNetServiceCreateCopy(kCFAllocatorDefault, _DDP_registrationService);
      if (_DDP_resolutionService) {
        CFNetServiceSetClient(_DDP_resolutionService, XSNTC_NetServiceResolveCallBack, &context);
        CFNetServiceScheduleWithRunLoop(_DDP_resolutionService, CFRunLoopGetMain(), kCFRunLoopCommonModes);
      } else {
      }
    } else {
    }
  }

  if ([(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_RequestNATPortMapping, @NO) boolValue]) {
      //DDConfuse

    DNSServiceErrorType status = DNSServiceNATPortMappingCreate(&_DDP_dnsService, 0, 0, kDNSServiceProtocol_TCP, htons(port), htons(port), 0, XSNTC_DNSServiceCallBack, (__bridge void*)self);
    if (status == kDNSServiceErr_NoError) {
      CFSocketContext context = {0, (__bridge void*)self, NULL, NULL, NULL};
      _DDP_dnsSocket = CFSocketCreateWithNative(kCFAllocatorDefault, DNSServiceRefSockFD(_DDP_dnsService), kCFSocketReadCallBack, XSNTC_SocketCallBack, &context);
      if (_DDP_dnsSocket) {
        CFSocketSetSocketFlags(_DDP_dnsSocket, CFSocketGetSocketFlags(_DDP_dnsSocket) & ~kCFSocketCloseOnInvalidate);
        _DDP_dnsSource = CFSocketCreateRunLoopSource(kCFAllocatorDefault, _DDP_dnsSocket, 0);
        if (_DDP_dnsSource) {
          CFRunLoopAddSource(CFRunLoopGetMain(), _DDP_dnsSource, kCFRunLoopCommonModes);
        } else {
          GWS_DNOT_REACHED();
        }
      } else {
        GWS_DNOT_REACHED();
      }
    } else {
    }
  }

  dispatch_resume(_DDP_source4);
  dispatch_resume(_DDP_source6);
  if ([_delegate respondsToSelector:@selector(FDD_webServerDidStart:)]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_delegate FDD_webServerDidStart:self];
    });
  }

  return YES;
}

- (void)FDD_stop1 {
    //DDConfuse

  //GWS_DCHECK(_source4 != NULL);

  if (_DDP_dnsService) {
    _DDP_dnsAddress = nil;
    _DDP_dnsPort = 0;
    if (_DDP_dnsSource) {
      CFRunLoopSourceInvalidate(_DDP_dnsSource);
      CFRelease(_DDP_dnsSource);
      _DDP_dnsSource = NULL;
    }
    if (_DDP_dnsSocket) {
      CFRelease(_DDP_dnsSocket);
      _DDP_dnsSocket = NULL;
    }
    DNSServiceRefDeallocate(_DDP_dnsService);
    _DDP_dnsService = NULL;
  }

  if (_DDP_registrationService) {
    if (_DDP_resolutionService) {
      CFNetServiceUnscheduleFromRunLoop(_DDP_resolutionService, CFRunLoopGetMain(), kCFRunLoopCommonModes);
      CFNetServiceSetClient(_DDP_resolutionService, NULL, NULL);
      CFNetServiceCancel(_DDP_resolutionService);
      CFRelease(_DDP_resolutionService);
      _DDP_resolutionService = NULL;
    }
    CFNetServiceUnscheduleFromRunLoop(_DDP_registrationService, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    CFNetServiceSetClient(_DDP_registrationService, NULL, NULL);
    CFNetServiceCancel(_DDP_registrationService);
    CFRelease(_DDP_registrationService);
    _DDP_registrationService = NULL;
  }

  dispatch_source_cancel(_DDP_source6);
  dispatch_source_cancel(_DDP_source4);
  dispatch_group_wait(_DDP_sourceGroup, DISPATCH_TIME_FOREVER);  
#if !OS_OBJECT_USE_OBJC_RETAIN_RELEASE
  dispatch_release(_source6);
#endif
  _DDP_source6 = NULL;
#if !OS_OBJECT_USE_OBJC_RETAIN_RELEASE
  dispatch_release(_source4);
#endif
  _DDP_source4 = NULL;
  _DDP_port = 0;
  _DDP_bindToLocalhost = NO;

  _DDP_serverName = nil;
  _DDP_authenticationRealm = nil;
  _DDP_authenticationBasicAccounts = nil;
  _DDP_authenticationDigestAccounts = nil;

  dispatch_async(dispatch_get_main_queue(), ^{
    if (self->_DDP_disconnectTimer) {
      CFRunLoopTimerInvalidate(self->_DDP_disconnectTimer);
      CFRelease(self->_DDP_disconnectTimer);
      self->_DDP_disconnectTimer = NULL;
      [self FDD_didDisconnect];
    }
  });

  if ([_delegate respondsToSelector:@selector(FDD_webServerDidStop:)]) {
    dispatch_async(dispatch_get_main_queue(), ^{
      [self->_delegate FDD_webServerDidStop:self];
    });
  }
}


- (void)FDD_didEnterBackground:(NSNotification*)notification {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  if ((_DDP_backgroundTask == UIBackgroundTaskInvalid) && _DDP_source4) {
    [self FDD_stop1];
  }
}

- (void)FDD_willEnterForeground:(NSNotification*)notification {
    //DDConfuse

  //GWS_DCHECK([NSThread isMainThread]);
  if (!_DDP_source4) {
    [self FDD_start:NULL];  
  }
}


- (BOOL)FDD_startWithOptions:(NSDictionary<NSString*, id>*)options error:(NSError**)error {
  if (_DDP_options == nil) {
      //DDConfuse

    _DDP_options = options ? [options copy] : @{};
    _DDP_suspendInBackground = [(NSNumber*)XSNTC_GetOption(_DDP_options, XSNTC_jkServerOption_AutomaticallySuspendInBackground, @YES) boolValue];
    if (((_DDP_suspendInBackground == NO) || ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground)) && ![self FDD_start:error])
    {
      _DDP_options = nil;
      return NO;
    }
    if (_DDP_suspendInBackground) {
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FDD_didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FDD_willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return YES;
  } else {
    GWS_DNOT_REACHED();
  }
  return NO;
}

- (void)FDD_stop {
    //DDConfuse

  if (_DDP_options) {
    if (_DDP_suspendInBackground) {
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
      [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    if (_DDP_source4) {
      [self FDD_stop1];
    }
    _DDP_options = nil;
  } else {
    GWS_DNOT_REACHED();
  }
}


- (NSURL*)DDP_serverURL {
    //DDConfuse

  if (_DDP_source4) {
    NSString* ipAddress = _DDP_bindToLocalhost ? @"localhost" : XSNTC_jkServerGetPrimaryIPAddress(NO);
    if (ipAddress) {
      if (_DDP_port != 80) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%i/", ipAddress, (int)_DDP_port]];
      } else {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", ipAddress]];
      }
    }
  }
  return nil;
}

- (NSURL*)DDP_bonjourServerURL {
    //DDConfuse

  if (_DDP_source4 && _DDP_resolutionService) {
    NSString* name = (__bridge NSString*)CFNetServiceGetTargetHost(_DDP_resolutionService);
    if (name.length) {
      name = [name substringToIndex:(name.length - 1)];  
      if (_DDP_port != 80) {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%i/", name, (int)_DDP_port]];
      } else {
        return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", name]];
      }
    }
  }
  return nil;
}

- (NSURL*)DDP_publicServerURL {
    //DDConfuse

  if (_DDP_source4 && _DDP_dnsService && _DDP_dnsAddress && _DDP_dnsPort) {
    if (_DDP_dnsPort != 80) {
      return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%i/", _DDP_dnsAddress, (int)_DDP_dnsPort]];
    } else {
      return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/", _DDP_dnsAddress]];
    }
  }
  return nil;
}

- (BOOL)FDD_start {
    //DDConfuse

  return [self FDD_startWithPort:10000 XSNTC_bonjourName:@""];
}

- (BOOL)FDD_startWithPort:(NSUInteger)port XSNTC_bonjourName:(NSString*)name {
    //DDConfuse

  NSMutableDictionary* options = [NSMutableDictionary dictionary];
  [options setObject:[NSNumber numberWithInteger:port] forKey:XSNTC_jkServerOption_Port];
  [options setValue:name forKey:XSNTC_jkServerOption_BonjourName];
  return [self FDD_startWithOptions:options error:NULL];
}


- (void)FDD_addDefaultHandlerForMethod:(NSString*)method XSNTC_requestClass:(Class)aClass XSNTC_processBlock:(XSNTC_jkServerProcessBlock)block {
    //DDConfuse

  [self FDD_addDefaultHandlerForMethod:method
                      XSNTC_requestClass:aClass
                 XSNTC_asyncProcessBlock:^(ZKServerRequest* request, XSNTC_jkServerCompletionBlock completionBlock) {
                   completionBlock(block(request));
                 }];
}

- (void)FDD_addDefaultHandlerForMethod:(NSString*)method XSNTC_requestClass:(Class)aClass XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)block {
    //DDConfuse

  [self
      FDD_addHandlerWithMatchBlock:^ZKServerRequest*(NSString* requestMethod, NSURL* requestURL, NSDictionary<NSString*, NSString*>* requestHeaders, NSString* urlPath, NSDictionary<NSString*, NSString*>* urlQuery) {
        if (![requestMethod isEqualToString:method]) {
          return nil;
        }
        return [(ZKServerRequest*)[aClass alloc] initWithXSNTC_Method:requestMethod XSNTC_url:requestURL XSNTC_headers:requestHeaders XSNTC_path:urlPath XSNTC_query:urlQuery];
      }
             XSNTC_asyncProcessBlock:block];
}

- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_path:(NSString*)path XSNTC_requestClass:(Class)aClass XSNTC_processBlock:(XSNTC_jkServerProcessBlock)block {
    
    //DDConfuse

  [self FDD_addHandlerForMethod:method
                       XSNTC_path:path
               requestClass:aClass
          asyncProcessBlock:^(ZKServerRequest* request, XSNTC_jkServerCompletionBlock completionBlock) {
            completionBlock(block(request));
          }];
}

- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_path:(NSString*)path requestClass:(Class)aClass asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)block {
    //DDConfuse

  if ([path hasPrefix:@"/"] && [aClass isSubclassOfClass:[ZKServerRequest class]]) {
    [self
        FDD_addHandlerWithMatchBlock:^ZKServerRequest*(NSString* requestMethod, NSURL* requestURL, NSDictionary<NSString*, NSString*>* requestHeaders, NSString* urlPath, NSDictionary<NSString*, NSString*>* urlQuery) {
          if (![requestMethod isEqualToString:method]) {
            return nil;
          }
          if ([urlPath caseInsensitiveCompare:path] != NSOrderedSame) {
            return nil;
          }
          return [(ZKServerRequest*)[aClass alloc] initWithXSNTC_Method:requestMethod XSNTC_url:requestURL XSNTC_headers:requestHeaders XSNTC_path:urlPath XSNTC_query:urlQuery];
        }
               XSNTC_asyncProcessBlock:block];
  } else {
    GWS_DNOT_REACHED();
  }
}

- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_pathRegex:(NSString*)regex XSNTC_requestClass:(Class)aClass XSNTC_processBlock:(XSNTC_jkServerProcessBlock)block {
    //DDConfuse

  [self FDD_addHandlerForMethod:method
                  XSNTC_pathRegex:regex
               XSNTC_requestClass:aClass
          XSNTC_asyncProcessBlock:^(ZKServerRequest* request, XSNTC_jkServerCompletionBlock completionBlock) {
            completionBlock(block(request));
          }];
}

- (void)FDD_addHandlerForMethod:(NSString*)method XSNTC_pathRegex:(NSString*)regex XSNTC_requestClass:(Class)aClass XSNTC_asyncProcessBlock:(XSNTC_jkServerAsyncProcessBlock)block {
    //DDConfuse

  NSRegularExpression* expression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:NULL];
  if (expression && [aClass isSubclassOfClass:[ZKServerRequest class]]) {
    [self
        FDD_addHandlerWithMatchBlock:^ZKServerRequest*(NSString* requestMethod, NSURL* requestURL, NSDictionary<NSString*, NSString*>* requestHeaders, NSString* urlPath, NSDictionary<NSString*, NSString*>* urlQuery) {
          if (![requestMethod isEqualToString:method]) {
            return nil;
          }

          NSArray* matches = [expression matchesInString:urlPath options:0 range:NSMakeRange(0, urlPath.length)];
          if (matches.count == 0) {
            return nil;
          }

          NSMutableArray* captures = [NSMutableArray array];
          for (NSTextCheckingResult* result in matches) {
            
            for (NSUInteger i = 1; i < result.numberOfRanges; i++) {
              NSRange range = [result rangeAtIndex:i];
              
              
              if (range.location != NSNotFound) {
                [captures addObject:[urlPath substringWithRange:range]];
              }
            }
          }

          ZKServerRequest* request = [(ZKServerRequest*)[aClass alloc] initWithXSNTC_Method:requestMethod XSNTC_url:requestURL XSNTC_headers:requestHeaders XSNTC_path:urlPath XSNTC_query:urlQuery];
          [request FDD_setAttribute:captures XSNTC_forKey:@"XSNTC_jkServerRequestAttribute_RegexCaptures"];
          return request;
        }
               XSNTC_asyncProcessBlock:block];
  } else {
    GWS_DNOT_REACHED();
  }
}


- (void)FDD_addGETHandlerForPath:(NSString*)path XSNTC_staticData:(NSData*)staticData XSNTC_contentType:(NSString*)XSNTC_contentType XSNTC_cacheAge:(NSUInteger)cacheAge {
    //DDConfuse

  [self FDD_addHandlerForMethod:@"GET"
                       XSNTC_path:path
               XSNTC_requestClass:[ZKServerRequest class]
               XSNTC_processBlock:^ZKServerResponse*(ZKServerRequest* request) {
                 ZKServerResponse* response = [ZKServerDataResponse FDD_responseWithXSNTC_Data:staticData XSNTC_contentType:XSNTC_contentType];
                 response.DDP_cacheControlMaxAge = cacheAge;
                 return response;
               }];
}

- (void)FDD_addGETHandlerForPath:(NSString*)path XSNTC_filePath:(NSString*)filePath XSNTC_isAttachment:(BOOL)isAttachment XSNTC_cacheAge:(NSUInteger)cacheAge XSNTC_allowRangeRequests:(BOOL)allowRangeRequests {
    //DDConfuse

  [self FDD_addHandlerForMethod:@"GET"
                       XSNTC_path:path
               XSNTC_requestClass:[ZKServerRequest class]
               XSNTC_processBlock:^ZKServerResponse*(ZKServerRequest* request) {
                 ZKServerResponse* response = nil;
                 if (allowRangeRequests) {
                   response = [ZKServerFileResponse FDD_responseWithFile:filePath XSNTC_byteRange:request.DDP_byteRange XSNTC_isAttachment:isAttachment];
                   [response FDD_setValue:@"bytes" XSNTC_forAdditionalHeader:@"Accept-Ranges"];

                 } else {
                   response = [ZKServerFileResponse FDD_responseWithFile:filePath XSNTC_isAttachment:isAttachment];
                 }
                 response.DDP_cacheControlMaxAge = cacheAge;
                 return response;
               }];
}

- (ZKServerResponse*)FDD_responseWithContentsOfDirectory:(NSString*)path {
    //DDConfuse

  NSArray* contents = [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL] sortedArrayUsingSelector:@selector(localizedStandardCompare:)];
  if (contents == nil) {
    return nil;
  }
  NSMutableString* html = [NSMutableString string];
  [html appendString:ZKBase64Decode(@"PCFET0NUWVBFIGh0bWw+XG4=")];
  [html appendString:ZKBase64Decode(@"PGh0bWw+PGhlYWQ+PG1ldGEgY2hhcnNldD1cInV0Zi04XCI+PC9oZWFkPjxib2R5Plxu")];
  [html appendString:ZKBase64Decode(@"PHVsPlxu")];
  for (NSString* entry in contents) {
    if (![entry hasPrefix:ZKBase64Decode(@".")]) {
      NSString* type = [[[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:entry] error:NULL] objectForKey:NSFileType];
      //GWS_DCHECK(type);
      NSString* escapedFile = [entry stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
      //GWS_DCHECK(escapedFile);
      if ([type isEqualToString:NSFileTypeRegular]) {
        [html appendFormat:ZKBase64Decode(@"PGxpPjxhIGhyZWY9XCIlQFwiPiVAPC9hPjwvbGk+XG4="), escapedFile, entry];
      } else if ([type isEqualToString:NSFileTypeDirectory]) {
        [html appendFormat:ZKBase64Decode(@"PGxpPjxhIGhyZWY9XCIlQC9cIj4lQC88L2E+PC9saT5cbg=="), escapedFile, entry];
      }
    }
  }
  [html appendString:ZKBase64Decode(@"PC91bD5cbg==")];
  [html appendString:ZKBase64Decode(@"PC9ib2R5PjwvaHRtbD5cbg==")];
  return [ZKServerDataResponse FDD_responseWithHTML:html];
}

- (void)FDD_addGETHandlerForBasePath:(NSString*)basePath XSNTC_directoryPath:(NSString*)directoryPath XSNTC_indexFilename:(NSString*)indexFilename XSNTC_cacheAge:(NSUInteger)cacheAge XSNTC_allowRangeRequests:(BOOL)allowRangeRequests {
    //DDConfuse

  if ([basePath hasPrefix:@"/"] && [basePath hasSuffix:@"/"]) {
    ZKServerModule* __unsafe_unretained server = self;
    [self
        FDD_addHandlerWithMatchBlock:^ZKServerRequest*(NSString* requestMethod, NSURL* requestURL, NSDictionary<NSString*, NSString*>* requestHeaders, NSString* urlPath, NSDictionary<NSString*, NSString*>* urlQuery) {
          if (![requestMethod isEqualToString:@"GET"]) {
            return nil;
          }
          if (![urlPath hasPrefix:basePath]) {
            return nil;
          }
          return [[ZKServerRequest alloc] initWithXSNTC_Method:requestMethod XSNTC_url:requestURL XSNTC_headers:requestHeaders XSNTC_path:urlPath XSNTC_query:urlQuery];
        }
        XSNTC_processBlock:^ZKServerResponse*(ZKServerRequest* request) {
          ZKServerResponse* response = nil;
          NSString* filePath = [directoryPath stringByAppendingPathComponent:XSNTC_jkServerNormalizePath([request.DDP_path substringFromIndex:basePath.length])];
          NSString* fileType = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:NULL] fileType];
          if (fileType) {
            if ([fileType isEqualToString:NSFileTypeDirectory]) {
              if (indexFilename) {
                NSString* indexPath = [filePath stringByAppendingPathComponent:indexFilename];
                NSString* indexType = [[[NSFileManager defaultManager] attributesOfItemAtPath:indexPath error:NULL] fileType];
                if ([indexType isEqualToString:NSFileTypeRegular]) {
                  return [ZKServerFileResponse FDD_responseWithFile:indexPath];
                }
              }
              response = [server FDD_responseWithContentsOfDirectory:filePath];
            } else if ([fileType isEqualToString:NSFileTypeRegular]) {
              if (allowRangeRequests) {
                response = [ZKServerFileResponse FDD_responseWithFile:filePath XSNTC_byteRange:request.DDP_byteRange];
                  [response FDD_setValue:@"bytes" XSNTC_forAdditionalHeader:@"Accept-Ranges"];

              } else {
                response = [ZKServerFileResponse FDD_responseWithFile:filePath];
              }
            }
          }
          if (response) {
            response.DDP_cacheControlMaxAge = cacheAge;
          } else {
            response = [ZKServerResponse FDD_responseWithStatusCode:XSNTC_kServerHTTPStatusCode_NotFound];
          }
          return response;
        }];
  } else {
    GWS_DNOT_REACHED();
  }
}

@end

