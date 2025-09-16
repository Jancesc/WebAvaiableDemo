#import "ZKServerRequest.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerFileRequest : ZKServerRequest


@property(nonatomic) NSString* DDP_temporaryPath;
@property(nonatomic, assign) int DDP_file;

@end

NS_ASSUME_NONNULL_END
