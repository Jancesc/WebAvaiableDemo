//
//  ZKServerMultiPartArgument.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerMultiPartArgument.h"
#import "ZKServerPrivate.h"
#import "ZKHeader.h"
@implementation ZKServerMultiPartArgument

- (instancetype)initWithXSNTC_ControlName:(NSString* _Nonnull)name XSNTC_contentType:(NSString* _Nonnull)type data:(NSData* _Nonnull)data {
  if ((self = [super initWithXSNTC_ControlName:name XSNTC_contentType:type])) {
    _DDP_data = data;

    if ([self.XSNTC_contentType hasPrefix:@"text/"]) {
      NSString* charset = XSNTC_jkServerExtractHeaderValueParameter(self.XSNTC_contentType, @"charset");
      _DDP_string = [[NSString alloc] initWithData:_DDP_data encoding:XSNTC_jkServerStringEncodingFromCharset(charset)];
    }
  }
  return self;
}



@end
