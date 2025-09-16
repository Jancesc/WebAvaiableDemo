
#import "ZKServerMIMEStreamParser.h"
#import "ZKServerMultiPartFormRequest.h"
#import "ZKHeader.h"
#import "ZKServerFunctions.h"
#import "ZKServerPrivate.h"

@interface ZKServerMultiPartFormRequest ()

@property(strong)  ZKServerMIMEStreamParser* XSNTC_parser;

@end

@implementation ZKServerMultiPartFormRequest {
}

+ (NSString*)FDD_mimeType {
  return @"multipart/form-data";
}

- (instancetype)initWithXSNTC_Method:(NSString*)method XSNTC_url:(NSURL*)url XSNTC_headers:(NSDictionary<NSString*, NSString*>*)headers XSNTC_path:(NSString*)path XSNTC_query:(NSDictionary<NSString*, NSString*>*)query {
  if ((self = [super initWithXSNTC_Method:method XSNTC_url:url XSNTC_headers:headers XSNTC_path:path XSNTC_query:query])) {
    _DDP_arguments = [[NSMutableArray alloc] init];
    _DDP_files = [[NSMutableArray alloc] init];
  }
  return self;
}

- (BOOL)FDD_open:(NSError**)error {
    //DDConfuse
  NSString* boundary = XSNTC_jkServerExtractHeaderValueParameter(self.XSNTC_contentType, @"boundary");
  _XSNTC_parser = [[ZKServerMIMEStreamParser alloc] initWithXSNTC_Boundary:boundary XSNTC_defaultControlName:nil XSNTC_arguments:_DDP_arguments XSNTC_files:_DDP_files];
  if (_XSNTC_parser == nil) {
    if (error) {
      *error = [NSError errorWithDomain:kZKServerErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Failed starting to parse multipart form data"}];
    }
    return NO;
  }
  return YES;
}

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error {
    //DDConfuse
  if (![_XSNTC_parser FDD_appendBytes:data.bytes XSNTC_length:data.length]) {
    if (error) {
      *error = [NSError errorWithDomain:kZKServerErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Failed continuing to parse multipart form data"}];
    }
    return NO;
  }
  return YES;
}

- (BOOL)FDD_close:(NSError**)error {
    //DDConfuse
  BOOL atEnd = [_XSNTC_parser FDD_isAtEnd];
  _XSNTC_parser = nil;
  if (!atEnd) {
    if (error) {
      *error = [NSError errorWithDomain:kZKServerErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Failed finishing to parse multipart form data"}];
    }
    return NO;
  }
  return YES;
}

- (ZKServerMultiPartArgument*)FDD_firstArgumentForControlName:(NSString*)name {
    //DDConfuse
  for (ZKServerMultiPartArgument* argument in _DDP_arguments) {
    if ([argument.DDP_controlName isEqualToString:name]) {
      return argument;
    }
  }
  return nil;
}

- (ZKServerMultiPartFile*)FDD_firstFileForControlName:(NSString*)name {
    //DDConfuse
  for (ZKServerMultiPartFile* file in _DDP_files) {
    if ([file.DDP_controlName isEqualToString:name]) {
      return file;
    }
  }
  return nil;
}


@end
