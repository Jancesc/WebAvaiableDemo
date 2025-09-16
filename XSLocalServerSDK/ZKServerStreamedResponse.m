

#import "ZKServerPrivate.h"

@implementation ZKServerStreamedResponse {
  XSNTC_jkServerAsyncStreamBlock _XSNTC_block;
}

@dynamic XSNTC_contentType;

+ (instancetype)FDD_responseWithXSNTC_contentType:(NSString*)type XSNTC_stream_gBlock:(XSNTC_jkServerStreamBlock)block {
    //DDConfuse

  return [(ZKServerStreamedResponse*)[[self class] alloc] initWithXSNTC_contentType:type XSNTC_stream_gBlock:block];
}

+ (instancetype)FDD_responseWithXSNTC_contentType:(NSString*)type XSNTC_asyncStreamBlock:(XSNTC_jkServerAsyncStreamBlock)block {
    //DDConfuse

  return [(ZKServerStreamedResponse*)[[self class] alloc] initWithXSNTC_contentType:type XSNTC_asyncStreamBlock:block];
}

- (instancetype)initWithXSNTC_contentType:(NSString*)type XSNTC_stream_gBlock:(XSNTC_jkServerStreamBlock)block {
    //DDConfuse

  return [self initWithXSNTC_contentType:type
                  XSNTC_asyncStreamBlock:^(XSNTC_jkServerBodyReaderCompletionBlock completionBlock) {
                    NSError* error = nil;
                    NSData* data = block(&error);
                    completionBlock(data, error);
                  }];
}

- (instancetype)initWithXSNTC_contentType:(NSString*)type XSNTC_asyncStreamBlock:(XSNTC_jkServerAsyncStreamBlock)block {
    
  if ((self = [super init])) {
      _XSNTC_block = [block copy];

    self.XSNTC_contentType = type;
  }
  return self;
}

- (void)FDD_asyncReadDataWithCompletion:(XSNTC_jkServerBodyReaderCompletionBlock)block {
    //DDConfuse
    _XSNTC_block(block);
}


@end
