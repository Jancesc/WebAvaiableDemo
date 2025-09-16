//
//  ZKServerBodyDecoder.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerBodyDecoder.h"

#import "ZKHeader.h"

@implementation ZKServerBodyDecoder {
  ZKServerRequest* __unsafe_unretained _DDP_request;
  id<XSNTC_jkServerBodyWriter> __unsafe_unretained _DDP_writer;
}

- (instancetype)initWithXSNTC_Request:(ZKServerRequest* _Nonnull)request XSNTC_writer:(id<XSNTC_jkServerBodyWriter> _Nonnull)writer {
  if ((self = [super init])) {
    _DDP_request = request;
    _DDP_writer = writer;
  }
  return self;
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  return [_DDP_writer FDD_open:error];
}

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  return [_DDP_writer FDD_writeData:data error:error];
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse
  return [_DDP_writer FDD_close:error];
}

@end
