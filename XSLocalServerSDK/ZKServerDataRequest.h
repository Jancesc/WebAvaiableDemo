#import "ZKServerRequest.h"

NS_ASSUME_NONNULL_BEGIN


@interface ZKServerDataRequest : ZKServerRequest


@property(nonatomic) NSMutableData* DDP_data;

@property(nonatomic, nullable) NSString* DDP_text;


@property(nonatomic, nullable) id DDP_jsonObject;

@end

NS_ASSUME_NONNULL_END
