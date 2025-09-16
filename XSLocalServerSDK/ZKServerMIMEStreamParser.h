//
//  ZKServerMIMEStreamParser.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import <Foundation/Foundation.h>

#import "ZKHeader.h"
#import "ZKServerMultiPartArgument.h"
#import "ZKServerMultiPartFile.h"
NS_ASSUME_NONNULL_BEGIN

@interface ZKServerMIMEStreamParser : NSObject


- (instancetype)initWithXSNTC_Boundary:(NSString* _Nonnull)boundary XSNTC_defaultControlName:(NSString* _Nullable)name XSNTC_arguments:(NSMutableArray<ZKServerMultiPartArgument*>* _Nonnull)arguments XSNTC_files:(NSMutableArray<ZKServerMultiPartFile*>* _Nonnull)files ;


- (BOOL)FDD_parseData;

- (BOOL)FDD_appendBytes:(const void*)bytes XSNTC_length:(NSUInteger)length;
- (BOOL)FDD_isAtEnd;
@end


NS_ASSUME_NONNULL_END
