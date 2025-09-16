

#import "ZKServerPrivate.h"

@implementation ZKServerFileRequest {
}

- (instancetype)initWithXSNTC_Method:(NSString*)method XSNTC_url:(NSURL*)url XSNTC_headers:(NSDictionary<NSString*, NSString*>*)headers XSNTC_path:(NSString*)path XSNTC_query:(NSDictionary<NSString*, NSString*>*)query {
  if ((self = [super initWithXSNTC_Method:method XSNTC_url:url XSNTC_headers:headers XSNTC_path:path XSNTC_query:query])) {
    _DDP_temporaryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
  }
  return self;
}

- (void)dealloc {
  unlink([_DDP_temporaryPath fileSystemRepresentation]);
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  _DDP_file = open([_DDP_temporaryPath fileSystemRepresentation], O_CREAT | O_TRUNC | O_WRONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
  if (_DDP_file <= 0) {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
    return NO;
  }
  return YES;
}

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  if (write(_DDP_file, data.bytes, data.length) != (ssize_t)data.length) {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
    return NO;
  }
  return YES;
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse
  if (close(_DDP_file) < 0) {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
    return NO;
  }

  return YES;
}


@end
