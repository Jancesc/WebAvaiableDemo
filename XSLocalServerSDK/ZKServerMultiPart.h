//
//  ZKServerMultiPart.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerMultiPart : NSObject


@property(nonatomic) NSString* DDP_controlName;


@property(nonatomic) NSString* XSNTC_contentType;


@property(nonatomic) NSString* DDP_mimeType;
- (instancetype)initWithXSNTC_ControlName:(NSString* _Nonnull)name XSNTC_contentType:(NSString* _Nonnull)type;

@end

NS_ASSUME_NONNULL_END
