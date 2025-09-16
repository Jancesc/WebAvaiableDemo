//
//  ZKServerBodyEncoder.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerBodyEncoder.h"
#import "ZKHeader.h"
#import "ZKServerPrivate.h"


@implementation ZKServerBodyEncoder {
  ZKServerResponse* __unsafe_unretained _response;
  id<XSNTC_jkServerBodyReader> __unsafe_unretained _reader;
}

- (instancetype)initWithXSNTC_Response:(ZKServerResponse* _Nonnull)response XSNTC_reader:(id<XSNTC_jkServerBodyReader> _Nonnull)reader {
  if ((self = [super init])) {
    _response = response;
    _reader = reader;
  }
  return self;
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  return [_reader FDD_open:error];
}

- (NSData*)FDD_readData:(NSError**)error {
    //DDConfuse
  return [_reader FDD_readData:error];
}

- (void)FDD_close {
    //DDConfuse
  [_reader FDD_close];
}

@end
