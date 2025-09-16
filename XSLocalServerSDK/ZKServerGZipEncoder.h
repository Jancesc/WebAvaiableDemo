//
//  ZKServerGZipEncoder.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerBodyEncoder.h"
#import "ZKHeader.h"
NS_ASSUME_NONNULL_BEGIN



@interface ZKServerGZipEncoder : ZKServerBodyEncoder

- (instancetype)initWithXSNTC_Response:(ZKServerResponse* _Nonnull)response XSNTC_reader:(id<XSNTC_jkServerBodyReader> _Nonnull)reader;

- (BOOL)FDD_open:(NSError**)error ;

- (NSData*)FDD_readData:(NSError**)error;
- (void)FDD_close;
@end



NS_ASSUME_NONNULL_END
