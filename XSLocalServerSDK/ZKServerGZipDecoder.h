//
//  ZKServerGZipDecoder.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerBodyDecoder.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKServerGZipDecoder : ZKServerBodyDecoder


- (BOOL)FDD_open:(NSError**)error;
- (BOOL)FDD_writeData:(NSData*)data error:(NSError**)error;

- (BOOL)FDD_close:(NSError**)error;
@end


NS_ASSUME_NONNULL_END
