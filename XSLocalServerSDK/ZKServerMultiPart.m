//
//  ZKServerMultiPart.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//
#import "ZKHeader.h"
#import "ZKServerMultiPart.h"
#import "ZKServerPrivate.h"
@implementation ZKServerMultiPart

- (instancetype)initWithXSNTC_ControlName:(NSString* _Nonnull)name XSNTC_contentType:(NSString* _Nonnull)type {
  if ((self = [super init])) {
    _DDP_controlName = [name copy];
    _XSNTC_contentType = [type copy];
    _DDP_mimeType = (NSString*)XSNTC_jkServerTruncateHeaderValue(_XSNTC_contentType);
  }
  return self;
}

@end
