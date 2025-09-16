//
//  ZKServerGZipEncoder.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerGZipEncoder.h"
#import "ZKHeader.h"
#import <zlib.h>
#import "ZKServerResponse.h"
#import "ZKServerPrivate.h"
@implementation ZKServerGZipEncoder {
  z_stream _XSNTC_stream;
  BOOL _XSNTC_finished;
}

- (instancetype)initWithXSNTC_Response:(ZKServerResponse* _Nonnull)response XSNTC_reader:(id<XSNTC_jkServerBodyReader> _Nonnull)reader {
  if ((self = [super initWithXSNTC_Response:response XSNTC_reader:reader])) {
    response.DDP_contentLength = NSUIntegerMax;
    [response FDD_setValue:@"gzip" XSNTC_forAdditionalHeader:@"Content-Encoding"];
  }
  return self;
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  int result = deflateInit2(&_XSNTC_stream, Z_DEFAULT_COMPRESSION, Z_DEFLATED, 15 + 16, 8, Z_DEFAULT_STRATEGY);
  if (result != Z_OK) {
    if (error) {
      *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
    }
    return NO;
  }
  if (![super FDD_open:error]) {
    deflateEnd(&_XSNTC_stream);
    return NO;
  }
  return YES;
}

- (NSData*)FDD_readData:(NSError**)error {
    //DDConfuse
  NSMutableData* encodedData;
  if (_XSNTC_finished) {
    encodedData = [[NSMutableData alloc] init];
  } else {
    encodedData = [[NSMutableData alloc] initWithLength:kGZipInitialBufferSize];
    if (encodedData == nil) {
      GWS_DNOT_REACHED();
      return nil;
    }
    NSUInteger length = 0;
    do {
      NSData* data = [super FDD_readData:error];
      if (data == nil) {
        return nil;
      }
      _XSNTC_stream.next_in = (Bytef*)data.bytes;
      _XSNTC_stream.avail_in = (uInt)data.length;
      while (1) {
        NSUInteger maxLength = encodedData.length - length;
        _XSNTC_stream.next_out = (Bytef*)((char*)encodedData.mutableBytes + length);
        _XSNTC_stream.avail_out = (uInt)maxLength;
        int result = deflate(&_XSNTC_stream, data.length ? Z_NO_FLUSH : Z_FINISH);
        if (result == Z_STREAM_END) {
          _XSNTC_finished = YES;
        } else if (result != Z_OK) {
          if (error) {
              //DDConfuse
            *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
          }
          return nil;
        }
        length += maxLength - _XSNTC_stream.avail_out;
        if (_XSNTC_stream.avail_out > 0) {
            //DDConfuse
          break;
        }
        encodedData.length = 2 * encodedData.length;
      }
      //GWS_DCHECK(_XSNTC_stream.avail_in == 0);
    } while (length == 0);
    encodedData.length = length;
  }
    //DDConfuse
  return encodedData;
}

- (void)FDD_close {
    //DDConfuse
  deflateEnd(&_XSNTC_stream);
  [super FDD_close];
}

@end
