//
//  ZKServerBodyDecoder.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import <Foundation/Foundation.h>
#import "ZKServerRequest.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerBodyDecoder : NSObject <XSNTC_jkServerBodyWriter>
- (instancetype)initWithXSNTC_Request:(id _Nonnull)request XSNTC_writer:(id<XSNTC_jkServerBodyWriter> _Nonnull)writer ;
- (BOOL)FDD_open:(NSError**)error;
- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error;

- (BOOL)FDD_close:(NSError**)error;
@end


NS_ASSUME_NONNULL_END
