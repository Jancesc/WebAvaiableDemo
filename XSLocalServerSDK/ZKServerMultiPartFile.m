//
//  ZKServerMultiPartFile.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerMultiPartFile.h"
#import "ZKHeader.h"


@implementation ZKServerMultiPartFile

- (instancetype)initWithXSNTC_ControlName:(NSString* _Nonnull)name XSNTC_contentType:(NSString* _Nonnull)type XSNTC_fileName:(NSString* _Nonnull)fileName XSNTC_temporaryPath:(NSString* _Nonnull)temporaryPath {
  if ((self = [super initWithXSNTC_ControlName:name XSNTC_contentType:type])) {
    _DDP_fileName = [fileName copy];
    _DDP_temporaryPath = [temporaryPath copy];
  }
  return self;
}

- (void)dealloc {
  unlink([_DDP_temporaryPath fileSystemRepresentation]);
}



@end
