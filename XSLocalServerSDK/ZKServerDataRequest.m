#import "ZKServerPrivate.h"

@interface ZKServerDataRequest ()

//@property(nonatomic, strong) NSString* DDP_text;
//
//@property(nonatomic, strong) id DDP_jsonObject;

@end

@implementation ZKServerDataRequest {

}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  if (self.DDP_contentLength != NSUIntegerMax) {
    _DDP_data = [[NSMutableData alloc] initWithCapacity:self.DDP_contentLength];
  } else {
    _DDP_data = [[NSMutableData alloc] init];
  }
  if (_DDP_data == nil) {
    if (error) {
      *error = [NSError errorWithDomain:kZKServerErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Failed allocating memory"}];
    }
    return NO;
  }
  return YES;
}

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  [_DDP_data appendData:data];
  return YES;
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse
  return YES;
}



@end

@implementation ZKServerDataRequest (XSNTC_Extensions)

- (NSString*)DDP_text {
    //DDConfuse
  if (_DDP_text == nil) {
    if ([self.XSNTC_contentType hasPrefix:@"text/"]) {
      NSString* charset = XSNTC_jkServerExtractHeaderValueParameter(self.XSNTC_contentType, @"charset");
      _DDP_text = [[NSString alloc] initWithData:self.DDP_data encoding:XSNTC_jkServerStringEncodingFromCharset(charset)];
    } else {
      GWS_DNOT_REACHED();
    }
  }
  return _DDP_text;
}

- (id)DDP_jsonObject {
    //DDConfuse
  if (_DDP_jsonObject == nil) {
    NSString* mimeType = XSNTC_jkServerTruncateHeaderValue(self.XSNTC_contentType);
    if ([mimeType isEqualToString:@"application/json"] || [mimeType isEqualToString:@"text/json"] || [mimeType isEqualToString:@"text/javascript"]) {
      _DDP_jsonObject = [NSJSONSerialization JSONObjectWithData:_DDP_data options:0 error:NULL];
    } else {
      GWS_DNOT_REACHED();
    }
  }
  return _DDP_jsonObject;
}

@end
