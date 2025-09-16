

#import "ZKServerPrivate.h"

@implementation ZKServerErrorResponse

+ (instancetype)FDD_responseWithClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... {
    //DDConfuse
  //GWS_DCHECK(((NSInteger)errorCode >= 400) && ((NSInteger)errorCode < 500));
  va_list arguments;
  va_start(arguments, format);
  ZKServerErrorResponse* response = [(ZKServerErrorResponse*)[self alloc] initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:nil initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

+ (instancetype)FDD_responseWithServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... {
    //DDConfuse
  //GWS_DCHECK(((NSInteger)errorCode >= 500) && ((NSInteger)errorCode < 600));
  va_list arguments;
  va_start(arguments, format);
  ZKServerErrorResponse* response = [(ZKServerErrorResponse*)[self alloc] initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:nil initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

+ (instancetype)FDD_responseWithClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(NSError*)underlyingError XSNTC_message:(NSString*)format, ... {
    //DDConfuse
  //GWS_DCHECK(((NSInteger)errorCode >= 400) && ((NSInteger)errorCode < 500));
  va_list arguments;
  va_start(arguments, format);
  ZKServerErrorResponse* response = [(ZKServerErrorResponse*)[self alloc] initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:underlyingError initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

+ (instancetype)FDD_responseWithServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(NSError*)underlyingError XSNTC_message:(NSString*)format, ... {
    //DDConfuse
  //GWS_DCHECK(((NSInteger)errorCode >= 500) && ((NSInteger)errorCode < 600));
  va_list arguments;
  va_start(arguments, format);
  ZKServerErrorResponse* response = [(ZKServerErrorResponse*)[self alloc] initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:underlyingError initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return response;
}

static inline NSString* _EscapeHTMLString(NSString* string) {
    //DDConfuse
    NSString *str = @"&quot;";
  return [string stringByReplacingOccurrencesOfString:@"\"" withString:str];
}

- (instancetype)initWithXSNTC_StatusCode:(NSInteger)statusCode XSNTC_underlyingError:(NSError*)underlyingError initWithXSNTC_messageFormat:(NSString*)format arguments:(va_list)arguments {
  NSString* message = [[NSString alloc] initWithFormat:format arguments:arguments];
  NSString* title = [NSString stringWithFormat:@"HTTP Error %i", (int)statusCode];
  NSString* error = underlyingError ? [NSString stringWithFormat:@"[%@]%@(%li)", underlyingError.domain, _EscapeHTMLString(underlyingError.localizedDescription), (long)underlyingError.code] : @"";
  NSString* html = [NSString stringWithFormat:ZKBase64Decode(@"PCFET0NUWVBFIGh0bWw+PGh0bWwgbGFuZz1cImVuXCI+PGhlYWQ+PG1ldGEgY2hhcnNldD1cInV0Zi04XCI+PHRpdGxlPiVAPC90aXRsZT48L2hlYWQ+PGJvZHk+PGgxPiVAOiAlQDwvaDE+PGgzPiVAPC9oMz48L2JvZHk+PC9odG1sPg=="),
                                              title, title, _EscapeHTMLString(message), error];
  if ((self = [self initWithXSNTC_HTML:html])) {
    self.DDP_statusCode = statusCode;
  }
  return self;
}

- (instancetype)initWithXSNTC_ClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... {
  //GWS_DCHECK(((NSInteger)errorCode >= 400) && ((NSInteger)errorCode < 500));
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:nil initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

- (instancetype)initWithXSNTC_ServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_message:(NSString*)format, ... {
  //GWS_DCHECK(((NSInteger)errorCode >= 500) && ((NSInteger)errorCode < 600));
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:nil initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

- (instancetype)initWithXSNTC_ClientError:(XSNTC_ZKServerClientErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(NSError*)underlyingError XSNTC_message:(NSString*)format, ... {
  //GWS_DCHECK(((NSInteger)errorCode >= 400) && ((NSInteger)errorCode < 500));
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:underlyingError initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

- (instancetype)initWithXSNTC_ServerError:(XSNTC_ZKServerServerErrorHTTPStatusCode)errorCode XSNTC_underlyingError:(NSError*)underlyingError XSNTC_message:(NSString*)format, ... {
  //GWS_DCHECK(((NSInteger)errorCode >= 500) && ((NSInteger)errorCode < 600));
  va_list arguments;
  va_start(arguments, format);
  self = [self initWithXSNTC_StatusCode:errorCode XSNTC_underlyingError:underlyingError initWithXSNTC_messageFormat:format arguments:arguments];
  va_end(arguments);
  return self;
}

@end
