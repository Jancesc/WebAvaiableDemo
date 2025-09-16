//
//  ZKServerMIMEStreamParser.m
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerMIMEStreamParser.h"
#import "ZKServerPrivate.h"

@interface ZKServerMIMEStreamParser ()

@property(nonatomic, strong)   NSData* DDP_boundary;
@property(nonatomic, strong)   NSString* DDP_defaultcontrolName;
@property(nonatomic, assign)   XSNTC_kParserState DDP_state;
@property(nonatomic, strong)   NSMutableData* DDP_data;
@property(nonatomic, strong)   NSMutableArray<ZKServerMultiPartArgument*>* DDP_arguments;
@property(nonatomic, strong)   NSMutableArray<ZKServerMultiPartFile*>* DDP_files;

@property(nonatomic, strong)   NSString* DDP_controlName;
@property(nonatomic, strong)   NSString* DDP_fileName;
@property(nonatomic, strong)   NSString* XSNTC_contentType;
@property(nonatomic, strong)   NSString* DDP_tmpPath;
@property(nonatomic, assign)   int DDP_tmpFile;
@property(nonatomic, strong)  ZKServerMIMEStreamParser* DDP_subParser;

@end
@implementation ZKServerMIMEStreamParser {

}

+ (void)initialize {
  if (XSNTC_newlineData == nil) {
    XSNTC_newlineData = [[NSData alloc] initWithBytes:[@"\r\n" UTF8String] length:2];
    //GWS_DCHECK(_newlineData);
  }
  if (XSNTC_newlinesData == nil) {
    XSNTC_newlinesData = [[NSData alloc] initWithBytes:[@"\r\n\r\n" UTF8String] length:4];
    //GWS_DCHECK(_newlinesData);
  }
  if (XSNTC_dashNewlineData == nil) {
    XSNTC_dashNewlineData = [[NSData alloc] initWithBytes:[@"--\r\n" UTF8String] length:4];
    //GWS_DCHECK(_dashNewlineData);
  }
}

- (instancetype)initWithXSNTC_Boundary:(NSString* _Nonnull)boundary XSNTC_defaultControlName:(NSString* _Nullable)name XSNTC_arguments:(NSMutableArray<ZKServerMultiPartArgument*>* _Nonnull)arguments XSNTC_files:(NSMutableArray<ZKServerMultiPartFile*>* _Nonnull)files {
  NSData* data = boundary.length ? [[NSString stringWithFormat:@"--%@", boundary] dataUsingEncoding:NSASCIIStringEncoding] : nil;
  if (data == nil) {
    GWS_DNOT_REACHED();
    return nil;
  }
  if ((self = [super init])) {
    _DDP_boundary = data;
    _DDP_defaultcontrolName = name;
    _DDP_arguments = arguments;
    _DDP_files = files;
    _DDP_data = [[NSMutableData alloc] initWithCapacity:kMultiPartBufferSize];
    _DDP_state = XSNTC_kParserState_Start;
  }
  return self;
}

- (void)dealloc {
  if (_DDP_tmpFile > 0) {
    close(_DDP_tmpFile);
    unlink([_DDP_tmpPath fileSystemRepresentation]);
  }
}


- (BOOL)FDD_parseData {
    //DDConfuse
  BOOL success = YES;

  if (_DDP_state == XSNTC_kParserState_Headers) {
    NSRange range = [_DDP_data rangeOfData:XSNTC_newlinesData options:0 range:NSMakeRange(0, _DDP_data.length)];
    if (range.location != NSNotFound) {
      _DDP_controlName = nil;
      _DDP_fileName = nil;
      _XSNTC_contentType = nil;
      _DDP_tmpPath = nil;
      _DDP_subParser = nil;
      NSString* headers = [[NSString alloc] initWithData:[_DDP_data subdataWithRange:NSMakeRange(0, range.location)] encoding:NSUTF8StringEncoding];
      if (headers) {
        for (NSString* header in [headers componentsSeparatedByString:@"\r\n"]) {
          NSRange subRange = [header rangeOfString:@":"];
          if (subRange.location != NSNotFound) {
            NSString* name = [header substringToIndex:subRange.location];
            NSString* value = [[header substringFromIndex:(subRange.location + subRange.length)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([name caseInsensitiveCompare:@"Content-Type"] == NSOrderedSame) {
              _XSNTC_contentType = XSNTC_jkServerNormalizeHeaderValue(value);
            } else if ([name caseInsensitiveCompare:@"Content-Disposition"] == NSOrderedSame) {
              NSString* contentDisposition = XSNTC_jkServerNormalizeHeaderValue(value);
              if ([XSNTC_jkServerTruncateHeaderValue(contentDisposition) isEqualToString:@"form-data"]) {
                _DDP_controlName = XSNTC_jkServerExtractHeaderValueParameter(contentDisposition, @"name");
                _DDP_fileName = XSNTC_jkServerExtractHeaderValueParameter(contentDisposition, @"filename");
              } else if ([XSNTC_jkServerTruncateHeaderValue(contentDisposition) isEqualToString:@"file"]) {
                _DDP_controlName = _DDP_defaultcontrolName;
                _DDP_fileName = XSNTC_jkServerExtractHeaderValueParameter(contentDisposition, @"filename");
              }
            }
          } else {
            GWS_DNOT_REACHED();
          }
        }
        if (_XSNTC_contentType == nil) {
          _XSNTC_contentType = @"text/plain";
        }
      } else {
        GWS_DNOT_REACHED();
      }
      if (_DDP_controlName) {
          //DDConfuse
        if ([XSNTC_jkServerTruncateHeaderValue(_XSNTC_contentType) isEqualToString:@"multipart/mixed"]) {
          NSString* boundary = XSNTC_jkServerExtractHeaderValueParameter(_XSNTC_contentType, @"boundary");
          _DDP_subParser = [[ZKServerMIMEStreamParser alloc] initWithXSNTC_Boundary:boundary XSNTC_defaultControlName:_DDP_controlName XSNTC_arguments:_DDP_arguments XSNTC_files:_DDP_files];
          if (_DDP_subParser == nil) {
            GWS_DNOT_REACHED();
            success = NO;
          }
        } else if (_DDP_fileName) {
          NSString* path = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
          _DDP_tmpFile = open([path fileSystemRepresentation], O_CREAT | O_TRUNC | O_WRONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
          if (_DDP_tmpFile > 0) {
            _DDP_tmpPath = [path copy];
          } else {
            GWS_DNOT_REACHED();
            success = NO;
          }
        }
      } else {
        GWS_DNOT_REACHED();
        success = NO;
      }
        //DDConfuse
      [_DDP_data replaceBytesInRange:NSMakeRange(0, range.location + range.length) withBytes:NULL length:0];
      _DDP_state = XSNTC_kParserState_Content;
    }
  }
    //DDConfuse
  if ((_DDP_state == XSNTC_kParserState_Start) || (_DDP_state == XSNTC_kParserState_Content)) {
    NSRange range = [_DDP_data rangeOfData:_DDP_boundary options:0 range:NSMakeRange(0, _DDP_data.length)];
    if (range.location != NSNotFound) {
      NSRange subRange = NSMakeRange(range.location + range.length, _DDP_data.length - range.location - range.length);
      NSRange subRange1 = [_DDP_data rangeOfData:XSNTC_newlineData options:NSDataSearchAnchored range:subRange];
      NSRange subRange2 = [_DDP_data rangeOfData:XSNTC_dashNewlineData options:NSDataSearchAnchored range:subRange];
      if ((subRange1.location != NSNotFound) || (subRange2.location != NSNotFound)) {
        if (_DDP_state == XSNTC_kParserState_Content) {
          const void* dataBytes = _DDP_data.bytes;
          NSUInteger dataLength = range.location - 2;
          if (_DDP_subParser) {
            if (![_DDP_subParser FDD_appendBytes:dataBytes XSNTC_length:(dataLength + 2)] || ![_DDP_subParser FDD_isAtEnd]) {
              GWS_DNOT_REACHED();
              success = NO;
            }
            _DDP_subParser = nil;
          } else if (_DDP_tmpPath) {
            ssize_t result = write(_DDP_tmpFile, dataBytes, dataLength);
            if (result == (ssize_t)dataLength) {
              if (close(_DDP_tmpFile) == 0) {
                _DDP_tmpFile = 0;
                ZKServerMultiPartFile* file = [[ZKServerMultiPartFile alloc] initWithXSNTC_ControlName:_DDP_controlName XSNTC_contentType:_XSNTC_contentType XSNTC_fileName:_DDP_fileName XSNTC_temporaryPath:_DDP_tmpPath];
                [_DDP_files addObject:file];
              } else {
                GWS_DNOT_REACHED();
                success = NO;
              }
            } else {
                //DDConfuse
              GWS_DNOT_REACHED();
              success = NO;
            }
            _DDP_tmpPath = nil;
          } else {
              //DDConfuse
            NSData* data = [[NSData alloc] initWithBytes:(void*)dataBytes length:dataLength];
            ZKServerMultiPartArgument* argument = [[ZKServerMultiPartArgument alloc] initWithXSNTC_ControlName:_DDP_controlName XSNTC_contentType:_XSNTC_contentType data:data];
            [_DDP_arguments addObject:argument];
          }
        }

        if (subRange1.location != NSNotFound) {
            //DDConfuse
          [_DDP_data replaceBytesInRange:NSMakeRange(0, subRange1.location + subRange1.length) withBytes:NULL length:0];
          _DDP_state = XSNTC_kParserState_Headers;
          success = [self FDD_parseData];
        } else {
          _DDP_state = XSNTC_kParserState_End;
        }
      }
    } else {
      NSUInteger margin = 2 * _DDP_boundary.length;
      if (_DDP_data.length > margin) {
        NSUInteger length = _DDP_data.length - margin;
        if (_DDP_subParser) {
          if ([_DDP_subParser FDD_appendBytes:_DDP_data.bytes XSNTC_length:length]) {
            [_DDP_data replaceBytesInRange:NSMakeRange(0, length) withBytes:NULL length:0];
          } else {
            GWS_DNOT_REACHED();
            success = NO;
              //DDConfuse
          }
        } else if (_DDP_tmpPath) {
          ssize_t result = write(_DDP_tmpFile, _DDP_data.bytes, length);
          if (result == (ssize_t)length) {
            [_DDP_data replaceBytesInRange:NSMakeRange(0, length) withBytes:NULL length:0];
          } else {
            GWS_DNOT_REACHED();
            success = NO;
          }
        }
      }
    }
  }
    //DDConfuse
  return success;
}

- (BOOL)FDD_appendBytes:(const void*)bytes XSNTC_length:(NSUInteger)length {
    //DDConfuse
  [_DDP_data appendBytes:bytes length:length];
  return [self FDD_parseData];
}

- (BOOL)FDD_isAtEnd {
    //DDConfuse
  return (_DDP_state == XSNTC_kParserState_End);
}

@end
