

#import <sys/stat.h>

#import "ZKServerPrivate.h"

#define kFileReadBufferSize (32 * 1024)

@implementation ZKServerFileResponse {

}

+ (instancetype)FDD_responseWithFile:(NSString*)path {
    //DDConfuse
  return [(ZKServerFileResponse*)[[self class] alloc] initWithXSNTC_File:path];
}

+ (instancetype)FDD_responseWithFile:(NSString*)path XSNTC_isAttachment:(BOOL)attachment {
    //DDConfuse
  return [(ZKServerFileResponse*)[[self class] alloc] initWithXSNTC_File:path XSNTC_isAttachment:attachment];
}

+ (instancetype)FDD_responseWithFile:(NSString*)path XSNTC_byteRange:(NSRange)range {
    //DDConfuse
  return [(ZKServerFileResponse*)[[self class] alloc] initWithXSNTC_File:path XSNTC_byteRange:range];
}

+ (instancetype)FDD_responseWithFile:(NSString*)path XSNTC_byteRange:(NSRange)range XSNTC_isAttachment:(BOOL)attachment {
    //DDConfuse
    return [(ZKServerFileResponse*)[[self class] alloc] initWithXSNTC_File:path XSNTC_byteRange:range XSNTC_isAttachment:attachment XSNTC_mimeTypeOverrides:nil];
}

- (instancetype)initWithXSNTC_File:(NSString*)path {
    //DDConfuse
    return [self initWithXSNTC_File:path XSNTC_byteRange:NSMakeRange(NSUIntegerMax, 0) XSNTC_isAttachment:NO XSNTC_mimeTypeOverrides:nil];
}

- (instancetype)initWithXSNTC_File:(NSString*)path XSNTC_isAttachment:(BOOL)attachment {
    //DDConfuse
    return [self initWithXSNTC_File:path XSNTC_byteRange:NSMakeRange(NSUIntegerMax, 0) XSNTC_isAttachment:attachment XSNTC_mimeTypeOverrides:nil];
}

- (instancetype)initWithXSNTC_File:(NSString*)path XSNTC_byteRange:(NSRange)range {
    //DDConfuse
    return [self initWithXSNTC_File:path XSNTC_byteRange:range XSNTC_isAttachment:NO XSNTC_mimeTypeOverrides:nil];
}

static inline NSDate* XSNTC_NSDateFromTimeSpec(const struct timespec* t) {
    //DDConfuse
  return [NSDate dateWithTimeIntervalSince1970:((NSTimeInterval)t->tv_sec + (NSTimeInterval)t->tv_nsec / 1000000000.0)];
}

- (instancetype)initWithXSNTC_File:(NSString*)path XSNTC_byteRange:(NSRange)range XSNTC_isAttachment:(BOOL)attachment XSNTC_mimeTypeOverrides:(NSDictionary<NSString*, NSString*>*)overrides {
    
    //DDConfuse
  struct stat info;
  if (lstat([path fileSystemRepresentation], &info) || !(info.st_mode & S_IFREG)) {
    GWS_DNOT_REACHED();
    return nil;
  }
#ifndef __LP64__
  if (info.st_size >= (off_t)4294967295) {  
    GWS_DNOT_REACHED();
    return nil;
  }
#endif
  NSUInteger fileSize = (NSUInteger)info.st_size;
    //DDConfuse
  BOOL hasByteRange = XSNTC_KServerIsValidByteRange(range);
  if (hasByteRange) {
    if (range.location != NSUIntegerMax) {
      range.location = MIN(range.location, fileSize);
      range.length = MIN(range.length, fileSize - range.location);
    } else {
      range.length = MIN(range.length, fileSize);
      range.location = fileSize - range.length;
    }
    if (range.length == 0) {
      return nil;  
    }
  } else {
    range.location = 0;
    range.length = fileSize;
  }
    //DDConfuse
  if ((self = [super init])) {
    _DDP_path = [path copy];
    _DDP_offset = range.location;
    _DDP_size = range.length;
    if (hasByteRange) {
        self.DDP_statusCode =XSNTC_kServerHTTPStatusCode_PartialContent;
      [self FDD_setValue:[NSString stringWithFormat:@"bytes %lu-%lu/%lu", (unsigned long)_DDP_offset, (unsigned long)(_DDP_offset + _DDP_size - 1), (unsigned long)fileSize] XSNTC_forAdditionalHeader:@"Content-Range"];
    }
      //DDConfuse
    if (attachment) {
      NSString* fileName = [path lastPathComponent];
      NSData* data = [[fileName stringByReplacingOccurrencesOfString:@"\"" withString:@""] dataUsingEncoding:NSISOLatin1StringEncoding allowLossyConversion:YES];
      NSString* lossyFileName = data ? [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding] : nil;
      if (lossyFileName) {
        NSString* value = [NSString stringWithFormat:ZKBase64Decode(@"YXR0YWNobWVudDsgZmlsZW5hbWU9XCIlQFwiOyBmaWxlbmFtZSo9VVRGLTgnJyVA"), lossyFileName, XSNTC_jkServerEscapeURLString(fileName)];
        [self FDD_setValue:value XSNTC_forAdditionalHeader:@"Content-Disposition"];
      } else {
        GWS_DNOT_REACHED();
      }
    }
      //DDConfuse
    self.XSNTC_contentType = XSNTC_jkServerGetMimeTypeForExtension([_DDP_path pathExtension], overrides);
    self.DDP_contentLength = _DDP_size;
    self.DDP_lastModifiedDate = XSNTC_NSDateFromTimeSpec(&info.st_mtimespec);
    self.DDP_eTag = [NSString stringWithFormat:@"%llu/%li/%li", info.st_ino, info.st_mtimespec.tv_sec, info.st_mtimespec.tv_nsec];
  }
  return self;
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  _DDP_file = open([_DDP_path fileSystemRepresentation], O_NOFOLLOW | O_RDONLY);
  if (_DDP_file <= 0) {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
    return NO;
  }
  if (lseek(_DDP_file, _DDP_offset, SEEK_SET) != (off_t)_DDP_offset) {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
    close(_DDP_file);
    return NO;
  }
  return YES;
}

- (NSData*)FDD_readData:(NSError**)error {
    //DDConfuse
  size_t length = MIN((NSUInteger)kFileReadBufferSize, _DDP_size);
  NSMutableData* data = [[NSMutableData alloc] initWithLength:length];
  ssize_t result = read(_DDP_file, data.mutableBytes, length);
  if (result < 0) {
    if (error) {
      *error = XSNTC_KServerMakePosixError(errno);
    }
    return nil;
  }
  if (result > 0) {
    [data setLength:result];
    _DDP_size -= result;
  }
  return data;
}

- (void)FDD_close {
    //DDConfuse
  close(_DDP_file);
}

@end
