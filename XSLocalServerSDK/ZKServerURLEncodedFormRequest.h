#import "ZKServerDataRequest.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerURLEncodedFormRequest : ZKServerDataRequest


@property(nonatomic) NSDictionary<NSString*, NSString*>* DDP_arguments;


+ (NSString*)FDD_mimeType;

@end

NS_ASSUME_NONNULL_END
