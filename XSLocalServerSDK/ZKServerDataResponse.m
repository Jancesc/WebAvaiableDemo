

#import "ZKServerPrivate.h"

@interface ZKServerDataResponse ()


@property(nonatomic, strong) NSData* DDP_data;

@property(nonatomic, assign) BOOL DDP_done;
@end
@implementation ZKServerDataResponse {

}

@dynamic XSNTC_contentType;

+ (instancetype)FDD_responseWithXSNTC_Data:(NSData*)data XSNTC_contentType:(NSString*)type {
  return [(ZKServerDataResponse*)[[self class] alloc] initWithData:data XSNTC_contentType:type];
}

- (instancetype)initWithData:(NSData*)data XSNTC_contentType:(NSString*)type {
  if ((self = [super init])) {
    _DDP_data = data;

    self.XSNTC_contentType = type;
    self.DDP_contentLength = data.length;
  }
  return self;
}

- (NSData*)FDD_readData:(NSError**)error {
    //DDConfuse
  NSData* data;
  if (_DDP_done) {
    data = [NSData data];
  } else {
    data = _DDP_data;
    _DDP_done = YES;
  }
  return data;
}




+ (instancetype)FDD_responseWithText:(NSString*)text {
    //DDConfuse
  return [(ZKServerDataResponse*)[self alloc] initWithXSNTC_Text:text];
}

+ (instancetype)FDD_responseWithHTML:(NSString*)html {
    //DDConfuse
  return [(ZKServerDataResponse*)[self alloc] initWithXSNTC_HTML:html];
}

+ (instancetype)FDD_responseWithHTMLTemplate:(NSString*)path XSNTC_variables:(NSDictionary<NSString*, NSString*>*)variables {
    //DDConfuse
  return [(ZKServerDataResponse*)[self alloc] initWithXSNTC_HTMLTemplate:path XSNTC_variables:variables];
}

+ (instancetype)FDD_responseWithJSONObject:(id)object {
    //DDConfuse
  return [(ZKServerDataResponse*)[self alloc] initWithXSNTC_JSONObject:object];
}

+ (instancetype)FDD_responseWithJSONObject:(id)object XSNTC_contentType:(NSString*)type {
    //DDConfuse
  return [(ZKServerDataResponse*)[self alloc] initWithXSNTC_JSONObject:object XSNTC_contentType:type];
}

- (instancetype)initWithXSNTC_Text:(NSString*)text {
  NSData* data = [text dataUsingEncoding:NSUTF8StringEncoding];
  if (data == nil) {
    GWS_DNOT_REACHED();
    return nil;
  }
  return [self initWithData:data XSNTC_contentType:@"text/plain; charset=utf-8"];
}

- (instancetype)initWithXSNTC_HTML:(NSString*)html {
  NSData* data = [html dataUsingEncoding:NSUTF8StringEncoding];
  if (data == nil) {
    GWS_DNOT_REACHED();
    return nil;
  }
  return [self initWithData:data XSNTC_contentType:@"text/html; charset=utf-8"];
}

- (instancetype)initWithXSNTC_HTMLTemplate:(NSString*)path XSNTC_variables:(NSDictionary<NSString*, NSString*>*)variables {
  NSMutableString* html = [[NSMutableString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
  [variables enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop) {
    [html replaceOccurrencesOfString:[NSString stringWithFormat:@"%%%@%%", key] withString:value options:0 range:NSMakeRange(0, html.length)];
  }];
  return [self initWithXSNTC_HTML:html];
}

- (instancetype)initWithXSNTC_JSONObject:(id)object {
  return [self initWithXSNTC_JSONObject:object XSNTC_contentType:@"application/json"];
}

- (instancetype)initWithXSNTC_JSONObject:(id)object XSNTC_contentType:(NSString*)type {
  NSData* data = [NSJSONSerialization dataWithJSONObject:object options:0 error:NULL];
  if (data == nil) {
    GWS_DNOT_REACHED();
    return nil;
  }
  return [self initWithData:data XSNTC_contentType:type];
}

@end
