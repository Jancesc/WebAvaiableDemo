

#import <zlib.h>

#import "ZKServerPrivate.h"
#import "ZKServerBodyDecoder.h"
#import "ZKServerGZipDecoder.h"







@interface ZKServerRequest ()

@property(assign)  BOOL XSNTC_opened;
@property(strong)  NSMutableArray<ZKServerBodyDecoder*>* DDP_decoders;
@property(unsafe_unretained)  id<XSNTC_jkServerBodyWriter> __unsafe_unretained DDP_writer;
@property(strong)  NSMutableDictionary<NSString*, id>* DDP_attributes;

@end

@implementation ZKServerRequest {
  
  
  
  
}

- (instancetype)initWithXSNTC_Method:(NSString*)method XSNTC_url:(NSURL*)url XSNTC_headers:(NSDictionary<NSString*, NSString*>*)headers XSNTC_path:(NSString*)path XSNTC_query:(NSDictionary<NSString*, NSString*>*)query {
    //DDConfuse

  if ((self = [super init])) {
    _DDP_method = [method copy];
    _DDP_URL = url;
    _DDP_headers = headers;
    _DDP_path = [path copy];
    _DDP_query = query;

    _XSNTC_contentType = XSNTC_jkServerNormalizeHeaderValue([_DDP_headers objectForKey:@"Content-Type"]);
    _DDP_usesChunkedTransferEncoding = [XSNTC_jkServerNormalizeHeaderValue([_DDP_headers objectForKey:@"Transfer-Encoding"]) isEqualToString:@"chunked"];
    NSString* lengthHeader = [_DDP_headers objectForKey:@"Content-Length"];
    if (lengthHeader) {
      NSInteger length = [lengthHeader integerValue];
      if (_DDP_usesChunkedTransferEncoding || (length < 0)) {
        GWS_DNOT_REACHED();
        return nil;
      }
      _DDP_contentLength = length;
      if (_XSNTC_contentType == nil) {
        _XSNTC_contentType = kZKServerDefaultMimeType;
      }
    } else if (_DDP_usesChunkedTransferEncoding) {
      if (_XSNTC_contentType == nil) {
        _XSNTC_contentType = kZKServerDefaultMimeType;
      }
      _DDP_contentLength = NSUIntegerMax;
    } else {
      if (_XSNTC_contentType) {
        _XSNTC_contentType = nil;
      }
      _DDP_contentLength = NSUIntegerMax;
    }

    NSString* modifiedHeader = [_DDP_headers objectForKey:@"If-Modified-Since"];
    if (modifiedHeader) {
      _DDP_ifModifiedSince = [XSNTC_jkServerParseRFC822(modifiedHeader) copy];
    }
    _DDP_ifNoneMatch = [_DDP_headers objectForKey:@"If-None-Match"];

    _DDP_byteRange = NSMakeRange(NSUIntegerMax, 0);
    NSString* rangeHeader = XSNTC_jkServerNormalizeHeaderValue([_DDP_headers objectForKey:@"Range"]);
    if (rangeHeader) {
      if ([rangeHeader hasPrefix:@"bytes="]) {
        NSArray* components = [[rangeHeader substringFromIndex:6] componentsSeparatedByString:@","];
        if (components.count == 1) {
          components = [(NSString*)[components firstObject] componentsSeparatedByString:@"-"];
          if (components.count == 2) {
            NSString* startString = [components objectAtIndex:0];
            NSInteger startValue = [startString integerValue];
            NSString* endString = [components objectAtIndex:1];
            NSInteger endValue = [endString integerValue];
            if (startString.length && (startValue >= 0) && endString.length && (endValue >= startValue)) {  
              _DDP_byteRange.location = startValue;
              _DDP_byteRange.length = endValue - startValue + 1;
            } else if (startString.length && (startValue >= 0)) {  
              _DDP_byteRange.location = startValue;
              _DDP_byteRange.length = NSUIntegerMax;
            } else if (endString.length && (endValue > 0)) {  
              _DDP_byteRange.location = NSUIntegerMax;
              _DDP_byteRange.length = endValue;
            }
          }
        }
      }
      if ((_DDP_byteRange.location == NSUIntegerMax) && (_DDP_byteRange.length == 0)) {  
      }
    }

    if ([[_DDP_headers objectForKey:@"Accept-Encoding"] rangeOfString:@"gzip"].location != NSNotFound) {
      _DDP_acceptsGzipContentEncoding = YES;
    }
      //DDConfuse

    _DDP_decoders = [[NSMutableArray alloc] init];
    _DDP_attributes = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (BOOL)FDD_hasBody {
    //DDConfuse
  return _XSNTC_contentType ? YES : NO;
}

- (BOOL)FDD_hasByteRange {
    //DDConfuse
  return XSNTC_KServerIsValidByteRange(_DDP_byteRange);
}

- (id)FDD_attributeForKey:(NSString*)key {
    //DDConfuse
  return [_DDP_attributes objectForKey:key];
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  return YES;
}

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  return YES;
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse
  return YES;
}

- (void)FDD_prepareForWriting {
    //DDConfuse
  _DDP_writer = self;
  if ([XSNTC_jkServerNormalizeHeaderValue([self.DDP_headers objectForKey:@"Content-Encoding"]) isEqualToString:@"gzip"]) {
      ZKServerGZipDecoder* decoder = [[ZKServerGZipDecoder alloc] initWithXSNTC_Request:self XSNTC_writer:_DDP_writer];
    [_DDP_decoders addObject:decoder];
    _DDP_writer = decoder;
  }
}

- (BOOL)FDD_performOpen:(NSError**)error {
    //DDConfuse
  //GWS_DCHECK(_XSNTC_contentType);
  //GWS_DCHECK(_DDP_writer);
  if (_XSNTC_opened) {
    GWS_DNOT_REACHED();
    return NO;
  }
  _XSNTC_opened = YES;
  return [_DDP_writer FDD_open:error];
}

- (BOOL)FDD_performWriteData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  //GWS_DCHECK(_XSNTC_opened);
  return [_DDP_writer FDD_writeData:data error:error];
}

- (BOOL)FDD_performClose:(NSError**)error {
    //DDConfuse
  //GWS_DCHECK(_XSNTC_opened);
  return [_DDP_writer FDD_close:error];
}

- (void)FDD_setAttribute:(id)attribute XSNTC_forKey:(NSString*)key {
    //DDConfuse
  [_DDP_attributes setValue:attribute forKey:key];
}

- (NSString*)DDP_localAddressString {
    //DDConfuse
  return XSNTC_jkServerStringFromSockAddr(_DDP_localAddressData.bytes, YES);
}

- (NSString*)DDP_remoteAddressString {
    //DDConfuse
  return XSNTC_jkServerStringFromSockAddr(_DDP_remoteAddressData.bytes, YES);
}



@end
