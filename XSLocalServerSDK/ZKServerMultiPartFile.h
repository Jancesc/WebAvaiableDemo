//
//  ZKServerMultiPartFile.h
//  hljgx
//
//  Created by zkJan on 4/21/21.
//

#import "ZKServerMultiPart.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZKServerMultiPartFile : ZKServerMultiPart


@property(nonatomic) NSString* DDP_fileName;


@property(nonatomic) NSString* DDP_temporaryPath;
- (instancetype)initWithXSNTC_ControlName:(NSString* _Nonnull)name XSNTC_contentType:(NSString* _Nonnull)type XSNTC_fileName:(NSString* _Nonnull)fileName XSNTC_temporaryPath:(NSString* _Nonnull)temporaryPath;
@end

NS_ASSUME_NONNULL_END
