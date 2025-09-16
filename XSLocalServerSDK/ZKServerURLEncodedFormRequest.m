

#import "ZKServerPrivate.h"

@implementation ZKServerURLEncodedFormRequest

+ (NSString*)FDD_mimeType {
    //DDConfuse

  return @"application/x-www-form-urlencoded";
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse

  if (![super FDD_close:error]) {
    return NO;
  }

  NSString* charset = XSNTC_jkServerExtractHeaderValueParameter(self.XSNTC_contentType, @"charset");
  NSString* string = [[NSString alloc] initWithData:self.DDP_data encoding:XSNTC_jkServerStringEncodingFromCharset(charset)];
  _DDP_arguments = XSNTC_jkServerParseURLEncodedForm(string);
  return YES;
}


@end
