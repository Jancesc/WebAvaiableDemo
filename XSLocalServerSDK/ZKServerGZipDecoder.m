//
//  ZKServerGZipDecoder.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerGZipDecoder.h"
#import "ZKHeader.h"
#import "ZKServerPrivate.h"
#import <zlib.h>
#import <Foundation/Foundation.h>

@interface ZKServerGZipDecoder ()

@property(nonatomic, assign) z_stream XSNTC_stream;
@property(nonatomic, assign) BOOL XSNTC_finished;
@end
@implementation ZKServerGZipDecoder {

}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  int result = inflateInit2(&_XSNTC_stream, 15 + 16);
  if (result != Z_OK) {
    if (error) {
      *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
    }
    return NO;
  }
  if (![super FDD_open:error]) {
    inflateEnd(&_XSNTC_stream);
    return NO;
  }
  return YES;
}

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  //GWS_DCHECK(!_XSNTC_finished);
  _XSNTC_stream.next_in = (Bytef*)data.bytes;
  _XSNTC_stream.avail_in = (uInt)data.length;
  NSMutableData* decodedData = [[NSMutableData alloc] initWithLength:kGZipInitialBufferSize];
  if (decodedData == nil) {
    GWS_DNOT_REACHED();
    return NO;
  }
  NSUInteger length = 0;
  while (1) {
    NSUInteger maxLength = decodedData.length - length;
    _XSNTC_stream.next_out = (Bytef*)((char*)decodedData.mutableBytes + length);
    _XSNTC_stream.avail_out = (uInt)maxLength;
    int result = inflate(&_XSNTC_stream, Z_NO_FLUSH);
    if ((result != Z_OK) && (result != Z_STREAM_END)) {
      if (error) {
        *error = [NSError errorWithDomain:kZlibErrorDomain code:result userInfo:nil];
      }
      return NO;
    }
    length += maxLength - _XSNTC_stream.avail_out;
    if (_XSNTC_stream.avail_out > 0) {
      if (result == Z_STREAM_END) {
        _XSNTC_finished = YES;
      }
      break;
    }
    decodedData.length = 2 * decodedData.length;
  }
  decodedData.length = length;
  BOOL success = length ? [super FDD_writeData:decodedData error:error] : YES;
  return success;
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse
  //GWS_DCHECK(_XSNTC_finished);
  inflateEnd(&_XSNTC_stream);
  return [super FDD_close:error];
}

@end
