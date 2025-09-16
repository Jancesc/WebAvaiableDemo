#import "ZKServerRequest.h"
#import "ZKHeader.h"
#import "ZKServerMultiPartArgument.h"
#import "ZKServerMultiPartFile.h"

NS_ASSUME_NONNULL_BEGIN






@interface ZKServerMultiPartFormRequest : ZKServerRequest

@property(nonatomic) NSMutableArray<ZKServerMultiPartArgument*>* DDP_arguments;
@property(nonatomic) NSMutableArray<ZKServerMultiPartFile*>* DDP_files;
+ (NSString*)FDD_mimeType;


- (nullable ZKServerMultiPartArgument*)FDD_firstArgumentForControlName:(NSString*)name;


- (nullable ZKServerMultiPartFile*)FDD_firstFileForControlName:(NSString*)name;

@end

NS_ASSUME_NONNULL_END
