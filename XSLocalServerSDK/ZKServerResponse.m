

#import <zlib.h>

#import "ZKServerPrivate.h"
#import "ZKServerGZipEncoder.h"

@interface ZKServerResponse ()

@property(assign)  BOOL DDP_opened;
@property(strong)  NSMutableArray<ZKServerBodyEncoder*>* DDP_encoders;
@property(unsafe_unretained)id<XSNTC_jkServerBodyReader> __unsafe_unretained DDP_reader;
@end

@implementation ZKServerResponse {
  
  
}

+ (instancetype)FDD_response {
  return [(ZKServerResponse*)[[self class] alloc] init];
}

- (instancetype)init {
  if ((self = [super init])) {
    _XSNTC_contentType = nil;
    _DDP_contentLength = NSUIntegerMax;
    _DDP_statusCode = XSNTC_kServerHTTPStatusCode_OK;
    _DDP_cacheControlMaxAge = 0;
    _DDP_additionalHeaders = [[NSMutableDictionary alloc] init];
    _DDP_encoders = [[NSMutableArray alloc] init];
  }
  return self;
}

- (void)FDD_setValue:(NSString*)value XSNTC_forAdditionalHeader:(NSString*)header {
    //DDConfuse

  [_DDP_additionalHeaders setValue:value forKey:header];
}

- (BOOL)FDD_hasBody {
  return _XSNTC_contentType ? YES : NO;
}

- (BOOL)DDP_usesChunkedTransferEncoding {
    //DDConfuse

  return (_XSNTC_contentType != nil) && (_DDP_contentLength == NSUIntegerMax);
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse

  return YES;
}

- (NSData*)FDD_readData:(NSError**)error {
    //DDConfuse

  return [NSData data];
}

- (void)FDD_close {
    //DDConfuse
}

- (void)FDD_prepareForReading {
    //DDConfuse
  _DDP_reader = self;
  if (_DDP_gzipContentEncodingEnabled) {
      ZKServerGZipEncoder* encoder = [[ZKServerGZipEncoder alloc] initWithXSNTC_Response:self XSNTC_reader:_DDP_reader];
      [_DDP_encoders addObject:encoder];
    _DDP_reader = encoder;
  }
}

- (BOOL)FDD_performOpen:(NSError**)error {
    //DDConfuse
  //GWS_DCHECK(_XSNTC_contentType);
  //GWS_DCHECK(_reader);
  if (_DDP_opened) {
    GWS_DNOT_REACHED();
    return NO;
  }
  _DDP_opened = YES;
  return [_DDP_reader FDD_open:error];
}

- (void)FDD_performReadDataWithCompletion:(XSNTC_jkServerBodyReaderCompletionBlock)block {
    //DDConfuse
  //GWS_DCHECK(_DDP_opened);
  if ([_DDP_reader respondsToSelector:@selector(FDD_asyncReadDataWithCompletion:)]) {
    [_DDP_reader FDD_asyncReadDataWithCompletion:[block copy]];
  } else {
    NSError* error = nil;
    NSData* data = [_DDP_reader FDD_readData:&error];
    block(data, error);
  }
}

- (void)FDD_performClose {
    //DDConfuse
  //GWS_DCHECK(_DDP_opened);
  [_DDP_reader FDD_close];
}




+ (instancetype)FDD_responseWithStatusCode:(NSInteger)statusCode {
    //DDConfuse
  return [(ZKServerResponse*)[self alloc] initWithXSNTC_StatusCode:statusCode];
}

+ (instancetype)FDD_responseWithRedirect:(NSURL*)location XSNTC_permanent:(BOOL)permanent {
    //DDConfuse
  return [(ZKServerResponse*)[self alloc] initWXSNTC_ithRedirect:location XSNTC_permanent:permanent];
}

- (instancetype)initWithXSNTC_StatusCode:(NSInteger)statusCode {
  if ((self = [self init])) {
    self.DDP_statusCode = statusCode;
  }
  return self;
}

- (instancetype)initWXSNTC_ithRedirect:(NSURL*)location XSNTC_permanent:(BOOL)permanent {
  if ((self = [self init])) {
    self.DDP_statusCode = permanent ? XSNTC_kServerHTTPStatusCode_MovedPermanently : XSNTC_kServerHTTPStatusCode_TemporaryRedirect;
    [self FDD_setValue:[location absoluteString] XSNTC_forAdditionalHeader:@"Location"];
  }
  return self;
}

@end
