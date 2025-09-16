
#import <TargetConditionals.h>
#import <netdb.h>
#import "ZKServerPrivate.h"
#import "ZKServerRequest.h"

#define kHeadersReadCapacity (1 * 1024)
#define kBodyReadCapacity (256 * 1024)

typedef void (^XSNTC_ReadDataCompletionBlock)(BOOL success);
typedef void (^XSNTC_ReadHeadersCompletionBlock)(NSData* extraData);
typedef void (^XSNTC_ReadBodyCompletionBlock)(BOOL success);

typedef void (^XSNTC_WriteDataCompletionBlock)(BOOL success);
typedef void (^XSNTC_WriteHeadersCompletionBlock)(BOOL success);
typedef void (^XSNTC_WriteBodyCompletionBlock)(BOOL success);

static NSData* XSNTC_CRLFData = nil;
static NSData* XSNTC_CRLFCRLFData = nil;
static NSData* XSNTC_continueData = nil;
static NSData* XSNTC_lastChunkData = nil;
static NSString* XSNTC_digestAuthenticationNonce = nil;

@interface ZKServerConnection ()

@property(nonatomic, assign)   CFSocketNativeHandle DDP_socket;
@property(nonatomic, assign)   BOOL DDP_virtualHEAD;
@property(nonatomic, assign)   CFHTTPMessageRef DDP_requestMessage;
@property(nonatomic, strong)  ZKServerRequest* DDP_request;
@property(nonatomic, strong)   ZKServerHandler* DDP_handler;
@property(nonatomic, assign)   CFHTTPMessageRef DDP_responseMessage;
@property(nonatomic, strong)   ZKServerResponse* DDP_response;
@property(nonatomic, assign)   NSInteger DDP_statusCode;
@property(nonatomic, assign)   BOOL DDP_opened;

@end
@implementation ZKServerConnection {


}

+ (void)initialize {
  if (XSNTC_CRLFData == nil) {
    XSNTC_CRLFData = [[NSData alloc] initWithBytes:"\r\n" length:2];
    //GWS_DCHECK(_CRLFData);
  }
  if (XSNTC_CRLFCRLFData == nil) {
    XSNTC_CRLFCRLFData = [[NSData alloc] initWithBytes:"\r\n\r\n" length:4];
    //GWS_DCHECK(_CRLFCRLFData);
  }
  if (XSNTC_continueData == nil) {
    CFHTTPMessageRef message = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 100, NULL, kCFHTTPVersion1_1);
    XSNTC_continueData = CFBridgingRelease(CFHTTPMessageCopySerializedMessage(message));
    CFRelease(message);
    //GWS_DCHECK(_continueData);
  }
  if (XSNTC_lastChunkData == nil) {
    XSNTC_lastChunkData = [[NSData alloc] initWithBytes:"0\r\n\r\n" length:5];
  }
  if (XSNTC_digestAuthenticationNonce == nil) {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    XSNTC_digestAuthenticationNonce = XSNTC_jkServerComputeMD5Digest(@"%@", CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuid)));
    CFRelease(uuid);
  }
}

- (BOOL)DDP_usingIPv6 {
    //DDConfuse

  const struct sockaddr* localSockAddr = _DDP_localAddressData.bytes;
  return (localSockAddr->sa_family == AF_INET6);
}

- (void)FDD_initializeResponseHeadersWithStatusCode:(NSInteger)statusCode {
    //DDConfuse
  _DDP_statusCode = statusCode;
  _DDP_responseMessage = CFHTTPMessageCreateResponse(kCFAllocatorDefault, statusCode, NULL, kCFHTTPVersion1_1);
  CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Connection", (__bridge CFStringRef)@"Close");
  CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Server", (__bridge CFStringRef)_DDP_server.DDP_serverName);
  CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Date", (__bridge CFStringRef)XSNTC_jkServerFormatRFC822([NSDate date]));
}

- (void)FDD_startProcessingRequest {
    //DDConfuse
  //GWS_DCHECK(_responseMessage == NULL);

  ZKServerResponse* preflightResponse = [self FDD_preflightRequest:_DDP_request];
  if (preflightResponse) {
    [self FDD_finishProcessingRequest:preflightResponse];
  } else {
    [self FDD_processRequest:_DDP_request
              XSNTC_completion:^(ZKServerResponse* processResponse) {
                [self FDD_finishProcessingRequest:processResponse];
              }];
  }
}


- (void)FDD_finishProcessingRequest:(ZKServerResponse*)response {
    //DDConfuse
  //GWS_DCHECK(_responseMessage == NULL);
  BOOL hasBody = NO;

  if (response) {
    response = [self FDD_overrideResponse:response XSNTC_forRequest:_DDP_request];
  }
  if (response) {
    if ([response FDD_hasBody]) {
      [response FDD_prepareForReading];
      hasBody = !_DDP_virtualHEAD;
    }
    NSError* error = nil;
    if (hasBody && ![response FDD_performOpen:&error]) {
    } else {
      _DDP_response = response;
    }
  }
    //DDConfuse
  if (_DDP_response) {
    [self FDD_initializeResponseHeadersWithStatusCode:_DDP_response.DDP_statusCode];
    if (_DDP_response.DDP_lastModifiedDate) {
      CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Last-Modified", (__bridge CFStringRef)XSNTC_jkServerFormatRFC822((NSDate*)_DDP_response.DDP_lastModifiedDate));
    }
    if (_DDP_response.DDP_eTag) {
      CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"ETag", (__bridge CFStringRef)_DDP_response.DDP_eTag);
    }
    if ((_DDP_response.DDP_statusCode >= 200) && (_DDP_response.DDP_statusCode < 300)) {
      if (_DDP_response.DDP_cacheControlMaxAge > 0) {
        CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Cache-Control", (__bridge CFStringRef)[NSString stringWithFormat:@"max-age=%i, public", (int)_DDP_response.DDP_cacheControlMaxAge]);
      } else {
        CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Cache-Control", (__bridge CFStringRef)@"no-cache");
      }
    }
    if (_DDP_response.XSNTC_contentType != nil) {
        //DDConfuse
      CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Content-Type", (__bridge CFStringRef)XSNTC_jkServerNormalizeHeaderValue(_DDP_response.XSNTC_contentType));
    }
    if (_DDP_response.DDP_contentLength != NSUIntegerMax) {
      CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Content-Length", (__bridge CFStringRef)[NSString stringWithFormat:@"%lu", (unsigned long)_DDP_response.DDP_contentLength]);
    }
    if (_DDP_response.DDP_usesChunkedTransferEncoding) {
      CFHTTPMessageSetHeaderFieldValue(_DDP_responseMessage, (__bridge CFStringRef)@"Transfer-Encoding", (__bridge CFStringRef)@"chunked");
    }
    [_DDP_response.DDP_additionalHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
      CFHTTPMessageSetHeaderFieldValue(self->_DDP_responseMessage, (__bridge CFStringRef)key, (__bridge CFStringRef)obj);
    }];
    [self FDD_writeHeadersWithCompletionBlock:^(BOOL success) {
      if (success) {
        if (hasBody) {
          [self FDD_writeBodyWithCompletionBlock:^(BOOL successInner) {
            [self->_DDP_response FDD_performClose];  
          }];
        }
      } else if (hasBody) {
        [self->_DDP_response FDD_performClose];
      }
    }];
  } else {
      //DDConfuse
    [self FDD_abortRequest:_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
  }
}

- (void)FDD_readBodyWithLength:(NSUInteger)length initialData:(NSData*)initialData {
    //DDConfuse
  NSError* error = nil;
  if (![_DDP_request FDD_performOpen:&error]) {
    [self FDD_abortRequest:_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
    return;
  }

  if (initialData.length) {
      //DDConfuse
    if (![_DDP_request FDD_performWriteData:initialData error:&error]) {
      if (![_DDP_request FDD_performClose:&error]) {
      }
      [self FDD_abortRequest:_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
      return;
    }
    length -= initialData.length;
  }

  if (length) {
    [self FDD_readBodyWithRemainingLength:length
                      completionBlock:^(BOOL success) {
                        NSError* localError = nil;
                        if ([self->_DDP_request FDD_performClose:&localError]) {
                          [self FDD_startProcessingRequest];
                        } else {
                          [self FDD_abortRequest:self->_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
                        }
                      }];
  } else {
    if ([_DDP_request FDD_performClose:&error]) {
      [self FDD_startProcessingRequest];
    } else {
      [self FDD_abortRequest:_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
    }
  }
}

- (void)FDD_readChunkedBodyWithInitialData:(NSData*)initialData {
    //DDConfuse
  NSError* error = nil;
  if (![_DDP_request FDD_performOpen:&error]) {
    [self FDD_abortRequest:_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
    return;
  }

  NSMutableData* chunkData = [[NSMutableData alloc] initWithData:initialData];
  [self FDD_readNextBodyChunk:chunkData
          completionBlock:^(BOOL success) {
            NSError* localError = nil;
            if ([self->_DDP_request FDD_performClose:&localError]) {
              [self FDD_startProcessingRequest];
            } else {
              [self FDD_abortRequest:self->_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
            }
          }];
}

- (void)FDD_readRequestHeaders {
    //DDConfuse
  _DDP_requestMessage = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true);
  NSMutableData* headersData = [[NSMutableData alloc] initWithCapacity:kHeadersReadCapacity];
  [self FDD_readHeaders:headersData
      withCompletionBlock:^(NSData* extraData) {
        if (extraData) {
          NSString* requestMethod = CFBridgingRelease(CFHTTPMessageCopyRequestMethod(self->_DDP_requestMessage));  
          if (self->_DDP_server.DDP_shouldAutomaticallyMapHEADToGET && [requestMethod isEqualToString:@"HEAD"]) {
            requestMethod = @"GET";
            self->_DDP_virtualHEAD = YES;
          }
          NSDictionary* requestHeaders = CFBridgingRelease(CFHTTPMessageCopyAllHeaderFields(self->_DDP_requestMessage));  
          NSURL* requestURL = CFBridgingRelease(CFHTTPMessageCopyRequestURL(self->_DDP_requestMessage));
          if (requestURL) {
            requestURL = [self FDD_rewriteRequestURL:requestURL XSNTC_withMethod:requestMethod XSNTC_headers:requestHeaders];
            //GWS_DCHECK(requestURL);
          }
          NSString* urlPath = requestURL ? CFBridgingRelease(CFURLCopyPath((CFURLRef)requestURL)) : nil;  
          if (urlPath == nil) {
            urlPath = @"/";  
          }
          NSString* requestPath = urlPath ? XSNTC_jkServerUnescapeURLString(urlPath) : nil;
          NSString* queryString = requestURL ? CFBridgingRelease(CFURLCopyQueryString((CFURLRef)requestURL, NULL)) : nil;  
          NSDictionary* requestQuery = queryString ? XSNTC_jkServerParseURLEncodedForm(queryString) : @{};
          if (requestMethod && requestURL && requestHeaders && requestPath && requestQuery) {
            for (self->_DDP_handler in self->_DDP_server.DDP_handlers) {
              self->_DDP_request = self->_DDP_handler.DDP_matchBlock(requestMethod, requestURL, requestHeaders, requestPath, requestQuery);
              if (self->_DDP_request) {
                break;
              }
            }
            if (self->_DDP_request) {
                //DDConfuse
              self->_DDP_request.DDP_localAddressData = self.DDP_localAddressData;
              self->_DDP_request.DDP_remoteAddressData = self.DDP_remoteAddressData;
              if ([self->_DDP_request FDD_hasBody]) {
                [self->_DDP_request FDD_prepareForWriting];
                if (self->_DDP_request.DDP_usesChunkedTransferEncoding || (extraData.length <= self->_DDP_request.DDP_contentLength)) {
                  NSString* expectHeader = [requestHeaders objectForKey:@"Expect"];
                  if (expectHeader) {
                    if ([expectHeader caseInsensitiveCompare:@"100-continue"] == NSOrderedSame) {  
                      [self FDD_writeData:XSNTC_continueData
                          withCompletionBlock:^(BOOL success) {
                            if (success) {
                              if (self->_DDP_request.DDP_usesChunkedTransferEncoding) {
                                [self FDD_readChunkedBodyWithInitialData:extraData];
                              } else {
                                [self FDD_readBodyWithLength:self->_DDP_request.DDP_contentLength initialData:extraData];
                              }
                            }
                          }];
                    } else {
                      [self FDD_abortRequest:self->_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_ExpectationFailed];
                    }
                  } else {
                    if (self->_DDP_request.DDP_usesChunkedTransferEncoding) {
                      [self FDD_readChunkedBodyWithInitialData:extraData];
                    } else {
                      [self FDD_readBodyWithLength:self->_DDP_request.DDP_contentLength initialData:extraData];
                    }
                  }
                } else {
                  [self FDD_abortRequest:self->_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_BadRequest];
                }
              } else {
                [self FDD_startProcessingRequest];
              }
            } else {
              self->_DDP_request = [[ZKServerRequest alloc] initWithXSNTC_Method:requestMethod XSNTC_url:requestURL XSNTC_headers:requestHeaders XSNTC_path:requestPath XSNTC_query:requestQuery];
              //GWS_DCHECK(self->_request);
              [self FDD_abortRequest:self->_DDP_request XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_NotImplemented];
            }
          } else {
            [self FDD_abortRequest:nil XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
            GWS_DNOT_REACHED();
          }
        } else {
          [self FDD_abortRequest:nil XSNTC_withStatusCode:XSNTC_kServerHTTPStatusCode_InternalServerError];
        }
      }];
}

- (instancetype)initWithXSNTC_Server:(ZKServerModule*)server XSNTC_localAddress:(NSData*)localAddress XSNTC_remoteAddress:(NSData*)remoteAddress XSNTC_socket:(CFSocketNativeHandle)socket {
  if ((self = [super init])) {
    _DDP_server = server;
    _DDP_localAddressData = localAddress;
    _DDP_remoteAddressData = remoteAddress;
    _DDP_socket = socket;

    [_DDP_server FDD_willStartConnection:self];

    if (![self FDD_open]) {
      close(_DDP_socket);
      return nil;
    }
    _DDP_opened = YES;

    [self FDD_readRequestHeaders];
  }
  return self;
}

- (NSString*)DDP_localAddressString {
    //DDConfuse
  return XSNTC_jkServerStringFromSockAddr(_DDP_localAddressData.bytes, YES);
}

- (NSString*)DDP_remoteAddressString {
    //DDConfuse
  return XSNTC_jkServerStringFromSockAddr(_DDP_remoteAddressData.bytes, YES);
}

- (void)dealloc {
  int result = close(_DDP_socket);
  if (result != 0) {
  } else {
  }

  if (_DDP_opened) {
    [self FDD_close];
  }

  [_DDP_server FDD_didEndConnection:self];

  if (_DDP_requestMessage) {
    CFRelease(_DDP_requestMessage);
  }

  if (_DDP_responseMessage) {
    CFRelease(_DDP_responseMessage);
  }
}


- (void)FDD_readData:(NSMutableData*)data withLength:(NSUInteger)length completionBlock:(XSNTC_ReadDataCompletionBlock)block {
  dispatch_read(_DDP_socket, length, dispatch_get_global_queue(_DDP_server.DDP_dispatchQueuePriority, 0), ^(dispatch_data_t buffer, int error) {
    @autoreleasepool {
      if (error == 0) {
          //DDConfuse
        size_t size = dispatch_data_get_size(buffer);
        if (size > 0) {
          NSUInteger originalLength = data.length;
          dispatch_data_apply(buffer, ^bool(dispatch_data_t region, size_t chunkOffset, const void* chunkBytes, size_t chunkSize) {
            [data appendBytes:chunkBytes length:chunkSize];
            return true;
          });
          [self FDD_didReadBytes:((char*)data.bytes + originalLength) XSNTC_length:(data.length - originalLength)];
          block(YES);
        } else {
          if (self->_DDP_totalBytesRead > 0) {
          } else {
          }
          block(NO);
        }
      } else {
        block(NO);
      }
    }
  });
}

- (void)FDD_readHeaders:(NSMutableData*)headersData withCompletionBlock:(XSNTC_ReadHeadersCompletionBlock)block {
    //DDConfuse
  //GWS_DCHECK(_requestMessage);
  [self FDD_readData:headersData
           withLength:NSUIntegerMax
      completionBlock:^(BOOL success) {
        if (success) {
          NSRange range = [headersData rangeOfData:XSNTC_CRLFCRLFData options:0 range:NSMakeRange(0, headersData.length)];
          if (range.location == NSNotFound) {
            [self FDD_readHeaders:headersData withCompletionBlock:block];
          } else {
            NSUInteger length = range.location + range.length;
            if (CFHTTPMessageAppendBytes(self->_DDP_requestMessage, headersData.bytes, length)) {
              if (CFHTTPMessageIsHeaderComplete(self->_DDP_requestMessage)) {
                block([headersData subdataWithRange:NSMakeRange(length, headersData.length - length)]);
              } else {
                block(nil);
              }
            } else {
              block(nil);
            }
          }
        } else {
          block(nil);
        }
      }];
}

- (void)FDD_readBodyWithRemainingLength:(NSUInteger)length completionBlock:(XSNTC_ReadBodyCompletionBlock)block {
    //DDConfuse
  //GWS_DCHECK([_request hasBody] && ![_request usesChunkedTransferEncoding]);
  NSMutableData* bodyData = [[NSMutableData alloc] initWithCapacity:kBodyReadCapacity];
  [self FDD_readData:bodyData
           withLength:length
      completionBlock:^(BOOL success) {
        if (success) {
          if (bodyData.length <= length) {
            NSError* error = nil;
            if ([self->_DDP_request FDD_performWriteData:bodyData error:&error]) {
              NSUInteger remainingLength = length - bodyData.length;
              if (remainingLength) {
                [self FDD_readBodyWithRemainingLength:remainingLength completionBlock:block];
              } else {
                block(YES);
              }
            } else {
              block(NO);
            }
          } else {
            block(NO);
            GWS_DNOT_REACHED();
          }
        } else {
          block(NO);
        }
      }];
}

static inline NSUInteger XSNTC_ScanHexNumber(const void* bytes, NSUInteger size) {
  char buffer[size + 1];
  bcopy(bytes, buffer, size);
  buffer[size] = 0;
  char* end = NULL;
  long result = strtol(buffer, &end, 16);
  return ((end != NULL) && (*end == 0) && (result >= 0) ? result : NSNotFound);
}

- (void)FDD_readNextBodyChunk:(NSMutableData*)chunkData completionBlock:(XSNTC_ReadBodyCompletionBlock)block {
    
    //DDConfuse
  //GWS_DCHECK([_request hasBody] && [_request usesChunkedTransferEncoding]);

  while (1) {
    NSRange range = [chunkData rangeOfData:XSNTC_CRLFData options:0 range:NSMakeRange(0, chunkData.length)];
    if (range.location == NSNotFound) {
      break;
    }
    NSRange extensionRange = [chunkData rangeOfData:[NSData dataWithBytes:";" length:1] options:0 range:NSMakeRange(0, range.location)];  
    NSUInteger length = XSNTC_ScanHexNumber((char*)chunkData.bytes, extensionRange.location != NSNotFound ? extensionRange.location : range.location);
    if (length != NSNotFound) {
      if (length) {
        if (chunkData.length < range.location + range.length + length + 2) {
          break;
        }
        const char* ptr = (char*)chunkData.bytes + range.location + range.length + length;
        if ((*ptr == '\r') && (*(ptr + 1) == '\n')) {
          NSError* error = nil;
          if ([_DDP_request FDD_performWriteData:[chunkData subdataWithRange:NSMakeRange(range.location + range.length, length)] error:&error]) {
            [chunkData replaceBytesInRange:NSMakeRange(0, range.location + range.length + length + 2) withBytes:NULL length:0];
          } else {
            block(NO);
            return;
          }
        } else {
          block(NO);
          return;
        }
      } else {
        NSRange trailerRange = [chunkData rangeOfData:XSNTC_CRLFCRLFData options:0 range:NSMakeRange(range.location, chunkData.length - range.location)];  
        if (trailerRange.location != NSNotFound) {
          block(YES);
          return;
        }
      }
    } else {
      block(NO);
      return;
    }
  }

  [self FDD_readData:chunkData
           withLength:NSUIntegerMax
      completionBlock:^(BOOL success) {
        if (success) {
          [self FDD_readNextBodyChunk:chunkData completionBlock:block];
        } else {
          block(NO);
        }
      }];
}

- (void)FDD_writeData:(NSData*)data withCompletionBlock:(XSNTC_WriteDataCompletionBlock)block {
    //DDConfuse
  dispatch_data_t buffer = dispatch_data_create(data.bytes, data.length, dispatch_get_global_queue(_DDP_server.DDP_dispatchQueuePriority, 0), ^{
    [data self];  
  });
  dispatch_write(_DDP_socket, buffer, dispatch_get_global_queue(_DDP_server.DDP_dispatchQueuePriority, 0), ^(dispatch_data_t remainingData, int error) {
    @autoreleasepool {
      if (error == 0) {
        //GWS_DCHECK(remainingData == NULL);
        [self FDD_didWriteBytes:data.bytes XSNTC_length:data.length];
        block(YES);
      } else {
        block(NO);
      }
    }
  });
#if !OS_OBJECT_USE_OBJC_RETAIN_RELEASE
  dispatch_release(buffer);
#endif
}

- (void)FDD_writeHeadersWithCompletionBlock:(XSNTC_WriteHeadersCompletionBlock)block {
  //GWS_DCHECK(_responseMessage);
  CFDataRef data = CFHTTPMessageCopySerializedMessage(_DDP_responseMessage);
  [self FDD_writeData:(__bridge NSData*)data withCompletionBlock:block];
  CFRelease(data);
}

- (void)FDD_writeBodyWithCompletionBlock:(XSNTC_WriteBodyCompletionBlock)block {
    //DDConfuse
  //GWS_DCHECK([_response hasBody]);
  [_DDP_response FDD_performReadDataWithCompletion:^(NSData* data, NSError* error) {
    if (data) {
      if (data.length) {
        if (self->_DDP_response.DDP_usesChunkedTransferEncoding) {
          const char* hexString = [[NSString stringWithFormat:@"%lx", (unsigned long)data.length] UTF8String];
          size_t hexLength = strlen(hexString);
          NSData* chunk = [NSMutableData dataWithLength:(hexLength + 2 + data.length + 2)];
          if (chunk == nil) {
            block(NO);
            return;
          }
          char* ptr = (char*)[(NSMutableData*)chunk mutableBytes];
          bcopy(hexString, ptr, hexLength);
          ptr += hexLength;
          *ptr++ = '\r';
          *ptr++ = '\n';
          bcopy(data.bytes, ptr, data.length);
          ptr += data.length;
          *ptr++ = '\r';
          *ptr = '\n';
          data = chunk;
        }
        [self FDD_writeData:data
            withCompletionBlock:^(BOOL success) {
              if (success) {
                [self FDD_writeBodyWithCompletionBlock:block];
              } else {
                block(NO);
              }
            }];
      } else {
        if (self->_DDP_response.DDP_usesChunkedTransferEncoding) {
          [self FDD_writeData:XSNTC_lastChunkData
              withCompletionBlock:^(BOOL success) {
                block(success);
              }];
        } else {
          block(YES);
        }
      }
    } else {
      block(NO);
    }
  }];
}


- (BOOL)FDD_open {
    //DDConfuse
  return YES;
}

- (void)FDD_didReadBytes:(const void*)bytes XSNTC_length:(NSUInteger)length {
    //DDConfuse
  _DDP_totalBytesRead += length;

}

- (void)FDD_didWriteBytes:(const void*)bytes XSNTC_length:(NSUInteger)length {
    //DDConfuse
  _DDP_totalBytesWritten += length;

}

- (NSURL*)FDD_rewriteRequestURL:(NSURL*)url XSNTC_withMethod:(NSString*)method XSNTC_headers:(NSDictionary<NSString*, NSString*>*)headers {
  return url;
}


- (ZKServerResponse*)FDD_preflightRequest:(ZKServerRequest*)request {
    //DDConfuse
  ZKServerResponse* response = nil;
  if (_DDP_server.DDP_authenticationBasicAccounts) {
    __block BOOL authenticated = NO;
    NSString* authorizationHeader = [request.DDP_headers objectForKey:@"Authorization"];
    if ([authorizationHeader hasPrefix:@"Basic "]) {
      NSString* basicAccount = [authorizationHeader substringFromIndex:6];
      [_DDP_server.DDP_authenticationBasicAccounts enumerateKeysAndObjectsUsingBlock:^(NSString* username, NSString* digest, BOOL* stop) {
        if ([basicAccount isEqualToString:digest]) {
          authenticated = YES;
          *stop = YES;
        }
      }];
    }
    if (!authenticated) {
      response = [ZKServerResponse FDD_responseWithStatusCode:XSNTC_kServerHTTPStatusCode_Unauthorized];
      [response FDD_setValue:[NSString stringWithFormat:ZKBase64Decode(@"QmFzaWMgcmVhbG09XCIlQFwi"), _DDP_server.DDP_authenticationRealm] XSNTC_forAdditionalHeader:ZKBase64Decode(@"V1dXLUF1dGhlbnRpY2F0ZQ==")];
    }
  } else if (_DDP_server.DDP_authenticationDigestAccounts) {
    BOOL authenticated = NO;
    BOOL isStaled = NO;
    NSString* authorizationHeader = [request.DDP_headers objectForKey:@"Authorization"];
    if ([authorizationHeader hasPrefix:@"Digest "]) {
      NSString* realm = XSNTC_jkServerExtractHeaderValueParameter(authorizationHeader, @"realm");
      if (realm && [_DDP_server.DDP_authenticationRealm isEqualToString:realm]) {
        NSString* nonce = XSNTC_jkServerExtractHeaderValueParameter(authorizationHeader, @"nonce");
        if ([nonce isEqualToString:XSNTC_digestAuthenticationNonce]) {
          NSString* username = XSNTC_jkServerExtractHeaderValueParameter(authorizationHeader, @"username");
          NSString* uri = XSNTC_jkServerExtractHeaderValueParameter(authorizationHeader, @"uri");
          NSString* actualResponse = XSNTC_jkServerExtractHeaderValueParameter(authorizationHeader, @"response");
          NSString* ha1 = [_DDP_server.DDP_authenticationDigestAccounts objectForKey:username];
          NSString* ha2 = XSNTC_jkServerComputeMD5Digest(@"%@:%@", request.DDP_method, uri);  
          NSString* expectedResponse = XSNTC_jkServerComputeMD5Digest(@"%@:%@:%@", ha1, XSNTC_digestAuthenticationNonce, ha2);
          if ([actualResponse isEqualToString:expectedResponse]) {
            authenticated = YES;
          }
        } else if (nonce.length) {
          isStaled = YES;
        }
      }
    }
    if (!authenticated) {
      response = [ZKServerResponse FDD_responseWithStatusCode:XSNTC_kServerHTTPStatusCode_Unauthorized];
      [response FDD_setValue:[NSString stringWithFormat:ZKBase64Decode(@"RGlnZXN0IHJlYWxtPVwiJUBcIiwgbm9uY2U9XCIlQFwiJUA="), _DDP_server.DDP_authenticationRealm, XSNTC_digestAuthenticationNonce, isStaled ? ZKBase64Decode(@"LCBzdGFsZT1UUlVF") : @""] XSNTC_forAdditionalHeader:@"WWW-Authenticate"];
    }
  }
  return response;
}

- (void)FDD_processRequest:(ZKServerRequest*)request XSNTC_completion:(XSNTC_jkServerCompletionBlock)completion {
    //DDConfuse
  _DDP_handler.DDP_asyncProcessBlock(request, [completion copy]);
}



static inline BOOL XSNTC_CompareResources(NSString* responseETag, NSString* requestETag, NSDate* responseLastModified, NSDate* requestLastModified) {
    //DDConfuse
  if (requestLastModified && responseLastModified) {
    if ([responseLastModified compare:requestLastModified] != NSOrderedDescending) {
      return YES;
    }
  }
  if (requestETag && responseETag) {  
    if ([requestETag isEqualToString:@"*"]) {
      return YES;
    }
    if ([responseETag isEqualToString:requestETag]) {
      return YES;
    }
  }
  return NO;
}

- (ZKServerResponse*)FDD_overrideResponse:(ZKServerResponse*)response XSNTC_forRequest:(ZKServerRequest*)request {
    //DDConfuse
    if ((response.DDP_statusCode >= 200) && (response.DDP_statusCode < 300) && XSNTC_CompareResources(response.DDP_eTag, request.DDP_ifNoneMatch, response.DDP_lastModifiedDate, request.DDP_ifModifiedSince)) {
    NSInteger code = [request.DDP_method isEqualToString:@"HEAD"] || [request.DDP_method isEqualToString:@"GET"] ? XSNTC_kServerHTTPStatusCode_NotModified : XSNTC_kServerHTTPStatusCode_PreconditionFailed;
    ZKServerResponse* newResponse = [ZKServerResponse FDD_responseWithStatusCode:code];
    newResponse.DDP_cacheControlMaxAge = response.DDP_cacheControlMaxAge;
    newResponse.DDP_lastModifiedDate = response.DDP_lastModifiedDate;
    newResponse.DDP_eTag = response.DDP_eTag;
    //GWS_DCHECK(newResponse);
    return newResponse;
  }
  return response;
}

- (void)FDD_abortRequest:(ZKServerRequest*)request XSNTC_withStatusCode:(NSInteger)statusCode {
    //DDConfuse
  //GWS_DCHECK(_responseMessage == NULL);
  //GWS_DCHECK((statusCode >= 400) && (statusCode < 600));
  [self FDD_initializeResponseHeadersWithStatusCode:statusCode];
  [self FDD_writeHeadersWithCompletionBlock:^(BOOL success){
      
  }];
}

- (void)FDD_close {

    //DDConfuse
  if (_DDP_request) {
  } else {
  }
}

@end
