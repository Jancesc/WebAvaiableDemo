

#import <TargetConditionals.h>
#if TARGET_OS_IPHONE
#import <CoreServices/CoreServices.h>
#else
#import <SystemConfiguration/SystemConfiguration.h>
#endif
#import <CommonCrypto/CommonDigest.h>

#import <ifaddrs.h>
#import <net/if.h>
#import <netdb.h>

#import "ZKServerPrivate.h"

static NSDateFormatter* XSNTC_dateFormatterRFC822 = nil;
static NSDateFormatter* XSNTC_dateFormatterISO8601 = nil;
static dispatch_queue_t XSNTC_dateFormatterQueue = NULL;


void XSNTC_jkServerInitializeFunctions() {
    //DDConfuse
  //GWS_DCHECK([NSThread isMainThread]);  
  if (XSNTC_dateFormatterRFC822 == nil) {
    XSNTC_dateFormatterRFC822 = [[NSDateFormatter alloc] init];
    XSNTC_dateFormatterRFC822.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    XSNTC_dateFormatterRFC822.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    XSNTC_dateFormatterRFC822.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //GWS_DCHECK(_dateFormatterRFC822);
  }
  if (XSNTC_dateFormatterISO8601 == nil) {
    XSNTC_dateFormatterISO8601 = [[NSDateFormatter alloc] init];
    XSNTC_dateFormatterISO8601.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    XSNTC_dateFormatterISO8601.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'+00:00'";
    XSNTC_dateFormatterISO8601.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    //GWS_DCHECK(_dateFormatterISO8601);
  }
  if (XSNTC_dateFormatterQueue == NULL) {
    XSNTC_dateFormatterQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
    //GWS_DCHECK(_dateFormatterQueue);
  }
}

NSString* XSNTC_jkServerNormalizeHeaderValue(NSString* value) {
    //DDConfuse
  if (value) {
    NSRange range = [value rangeOfString:@";"];  
    if (range.location != NSNotFound) {
      value = [[[value substringToIndex:range.location] lowercaseString] stringByAppendingString:[value substringFromIndex:range.location]];
    } else {
      value = [value lowercaseString];
    }
  }
  return value;
}

NSString* XSNTC_jkServerTruncateHeaderValue(NSString* value) {
    //DDConfuse
  if (value) {
    NSRange range = [value rangeOfString:@";"];
    if (range.location != NSNotFound) {
      return [value substringToIndex:range.location];
    }
  }
  return value;
}

NSString* XSNTC_jkServerExtractHeaderValueParameter(NSString* value, NSString* name) {
    //DDConfuse
  NSString* parameter = nil;
  if (value) {
    NSScanner* scanner = [[NSScanner alloc] initWithString:value];
    scanner.caseSensitive = NO;
    NSString* string = [NSString stringWithFormat:@"%@=", name];
    if ([scanner scanUpToString:string intoString:NULL]) {
      [scanner scanString:string intoString:NULL];
      if ([scanner scanString:@"\"" intoString:NULL]) {
        [scanner scanUpToString:@"\"" intoString:&parameter];
      } else {
        [scanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&parameter];
      }
    }
  }
  return parameter;
}


NSStringEncoding XSNTC_jkServerStringEncodingFromCharset(NSString* charset) {
    //DDConfuse
  NSStringEncoding encoding = kCFStringEncodingInvalidId;
  if (charset) {
    encoding = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)charset));
  }
  return (encoding != kCFStringEncodingInvalidId ? encoding : NSUTF8StringEncoding);
}

NSString* XSNTC_jkServerFormatRFC822(NSDate* date) {
    //DDConfuse
  __block NSString* string;
  dispatch_sync(XSNTC_dateFormatterQueue, ^{
    string = [XSNTC_dateFormatterRFC822 stringFromDate:date];
  });
  return string;
}

NSDate* XSNTC_jkServerParseRFC822(NSString* string) {
    //DDConfuse
  __block NSDate* date;
  dispatch_sync(XSNTC_dateFormatterQueue, ^{
    date = [XSNTC_dateFormatterRFC822 dateFromString:string];
  });
  return date;
}

NSString* XSNTC_jkServerFormatISO8601(NSDate* date) {
    //DDConfuse
  __block NSString* string;
  dispatch_sync(XSNTC_dateFormatterQueue, ^{
    string = [XSNTC_dateFormatterISO8601 stringFromDate:date];
  });
  return string;
}

NSDate* XSNTC_jkServerParseISO8601(NSString* string) {
    //DDConfuse
  __block NSDate* date;
  dispatch_sync(XSNTC_dateFormatterQueue, ^{
    date = [XSNTC_dateFormatterISO8601 dateFromString:string];
  });
  return date;
}

BOOL XSNTC_jkServerIsTextContentType(NSString* type) {
    //DDConfuse
  return ([type hasPrefix:@"text/"] || [type hasPrefix:@"application/json"] || [type hasPrefix:@"application/xml"]);
}

NSString* XSNTC_jkServerDescribeData(NSData* data, NSString* type) {
    //DDConfuse
  if (XSNTC_jkServerIsTextContentType(type)) {
    NSString* charset = XSNTC_jkServerExtractHeaderValueParameter(type, @"charset");
    NSString* string = [[NSString alloc] initWithData:data encoding:XSNTC_jkServerStringEncodingFromCharset(charset)];
    if (string) {
      return string;
    }
  }
  return [NSString stringWithFormat:@"<%lu bytes>", (unsigned long)data.length];
}

NSString* XSNTC_jkServerGetMimeTypeForExtension(NSString* extension, NSDictionary<NSString*, NSString*>* overrides) {
    //DDConfuse
  NSDictionary* builtInOverrides = @{@"css" : @"text/css"};
  NSString* mimeType = nil;
  extension = [extension lowercaseString];
  if (extension.length) {
    mimeType = [overrides objectForKey:extension];
    if (mimeType == nil) {
      mimeType = [builtInOverrides objectForKey:extension];
    }
    if (mimeType == nil) {
      CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)extension, NULL);
      if (uti) {
        mimeType = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType));
        CFRelease(uti);
      }
    }
  }
  return mimeType ? mimeType : kZKServerDefaultMimeType;
}

NSString* XSNTC_jkServerEscapeURLString(NSString* string) {
    //DDConfuse
  return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, (__bridge CFStringRef)@":@/?&=+", kCFStringEncodingUTF8));
}

NSString* XSNTC_jkServerUnescapeURLString(NSString* string) {
    //DDConfuse
  return CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)string, (__bridge CFStringRef)@"", kCFStringEncodingUTF8));
}

NSDictionary<NSString*, NSString*>* XSNTC_jkServerParseURLEncodedForm(NSString* form) {
    //DDConfuse
  NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
  NSScanner* scanner = [[NSScanner alloc] initWithString:form];
  [scanner setCharactersToBeSkipped:nil];
  while (1) {
    NSString* key = nil;
    if (![scanner scanUpToString:@"=" intoString:&key] || scanner.isAtEnd) {
      break;
    }
    [scanner setScanLocation:([scanner scanLocation] + 1)];

    NSString* value = nil;
    [scanner scanUpToString:@"&" intoString:&value];
    if (value == nil) {
      value = @"";
    }
      //DDConfuse
    key = [key stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString* unescapedKey = key ? XSNTC_jkServerUnescapeURLString(key) : nil;
    value = [value stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSString* unescapedValue = value ? XSNTC_jkServerUnescapeURLString(value) : nil;
    if (unescapedKey && unescapedValue) {
      [parameters setObject:unescapedValue forKey:unescapedKey];
    } else {
      GWS_DNOT_REACHED();
    }

    if ([scanner isAtEnd]) {
      break;
    }
    [scanner setScanLocation:([scanner scanLocation] + 1)];
  }
  return parameters;
}

NSString* XSNTC_jkServerStringFromSockAddr(const struct sockaddr* addr, BOOL includeService) {
    //DDConfuse
  char hostBuffer[NI_MAXHOST];
  char serviceBuffer[NI_MAXSERV];
  if (getnameinfo(addr, addr->sa_len, hostBuffer, sizeof(hostBuffer), serviceBuffer, sizeof(serviceBuffer), NI_NUMERICHOST | NI_NUMERICSERV | NI_NOFQDN) != 0) {
#if DEBUG
    GWS_DNOT_REACHED();
#else
    return @"";
#endif
  }
  return includeService ? [NSString stringWithFormat:@"%s:%s", hostBuffer, serviceBuffer] : (NSString*)[NSString stringWithUTF8String:hostBuffer];
}

NSString* XSNTC_jkServerGetPrimaryIPAddress(BOOL useIPv6) {
    //DDConfuse
  NSString* address = nil;
    
const char* primaryInterface = [@"en0" UTF8String];

  struct ifaddrs* list;
  if (getifaddrs(&list) >= 0) {
    for (struct ifaddrs* ifap = list; ifap; ifap = ifap->ifa_next) {
        if (strcmp(ifap->ifa_name, primaryInterface))
      {
        continue;
      }
      if ((ifap->ifa_flags & IFF_UP) && ((!useIPv6 && (ifap->ifa_addr->sa_family == AF_INET)) || (useIPv6 && (ifap->ifa_addr->sa_family == AF_INET6)))) {
        address = XSNTC_jkServerStringFromSockAddr(ifap->ifa_addr, NO);
        break;
      }
    }
    freeifaddrs(list);
  }
  return address;
}

NSString* XSNTC_jkServerComputeMD5Digest(NSString* format, ...) {
    //DDConfuse
  va_list arguments;
  va_start(arguments, format);
  const char* string = [[[NSString alloc] initWithFormat:format arguments:arguments] UTF8String];
  va_end(arguments);
  unsigned char md5[CC_MD5_DIGEST_LENGTH];
  CC_MD5(string, (CC_LONG)strlen(string), md5);
  char buffer[2 * CC_MD5_DIGEST_LENGTH + 1];
  for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
    unsigned char byte = md5[i];
    unsigned char byteHi = (byte & 0xF0) >> 4;
    buffer[2 * i + 0] = byteHi >= 10 ? 'a' + byteHi - 10 : '0' + byteHi;
    unsigned char byteLo = byte & 0x0F;
    buffer[2 * i + 1] = byteLo >= 10 ? 'a' + byteLo - 10 : '0' + byteLo;
  }
  buffer[2 * CC_MD5_DIGEST_LENGTH] = 0;
  return (NSString*)[NSString stringWithUTF8String:buffer];
}

NSString* XSNTC_jkServerNormalizePath(NSString* path) {
    //DDConfuse
  NSMutableArray* components = [[NSMutableArray alloc] init];
  for (NSString* component in [path componentsSeparatedByString:@"/"]) {
    if ([component isEqualToString:@".."]) {
      [components removeLastObject];
    } else if (component.length && ![component isEqualToString:@"."]) {
      [components addObject:component];
    }
  }
  if (path.length && ([path characterAtIndex:0] == '/')) {
    return [@"/" stringByAppendingString:[components componentsJoinedByString:@"/"]];  
  }
  return [components componentsJoinedByString:@"/"];
}
