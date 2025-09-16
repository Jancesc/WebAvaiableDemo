//
//  ZKServerBodyEncoder.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import <Foundation/Foundation.h>
#import "ZKHeader.h"
NS_ASSUME_NONNULL_BEGIN
@class ZKServerResponse;
@interface ZKServerBodyEncoder : NSObject <XSNTC_jkServerBodyReader>


- (instancetype)initWithXSNTC_Response:(ZKServerResponse* _Nonnull)response XSNTC_reader:(id<XSNTC_jkServerBodyReader> _Nonnull)reader;
- (BOOL)FDD_open:(NSError**)error ;

- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error;

- (BOOL)FDD_close;
@end

NS_ASSUME_NONNULL_END
