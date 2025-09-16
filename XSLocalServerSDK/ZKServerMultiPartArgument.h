//
//  ZKServerMultiPartArgument.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerMultiPart.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKServerMultiPartArgument : ZKServerMultiPart


@property(nonatomic) NSData* DDP_data;


@property(nonatomic, nullable) NSString* DDP_string;
- (instancetype)initWithXSNTC_ControlName:(NSString* _Nonnull)name XSNTC_contentType:(NSString* _Nonnull)type data:(NSData* _Nonnull)data;
@end


NS_ASSUME_NONNULL_END
