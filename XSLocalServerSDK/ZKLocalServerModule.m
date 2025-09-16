//
//  ZKLocalServerModule.m
//  XSLocalServerSDK
//
//  Created by zkJan on 4/23/24.
//

#import "ZKLocalServerModule.h"
#import "ZKServerModule.h"

@interface ZKLocalServerModule ()
@property (nonatomic, strong)ZKServerModule *DDP_mySever;


@end
@implementation ZKLocalServerModule

- (instancetype)init
{
    self = [super init];
    if (self) {
        //根据bundleid创建固定的端口号
        NSString *bundleId = [[NSBundle mainBundle] bundleIdentifier];
        NSUInteger hash = [bundleId hash];
        _DDP_port = 2000;
    }
    return self;
}
+ (instancetype)FDD_sharedModule {
    
    static ZKLocalServerModule *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZKLocalServerModule alloc] init];
    });
    return instance;
}

- (void)FDD_setupServer {
    
    
    _DDP_mySever = [[ZKServerModule alloc] init];
    NSString * docsDir = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"mobile.bundle"];
    //DDConfuse
    [_DDP_mySever FDD_addGETHandlerForBasePath:@"/"
                               XSNTC_directoryPath:docsDir
                               XSNTC_indexFilename:nil
                                    XSNTC_cacheAge:0
                          XSNTC_allowRangeRequests:YES];
    NSError *error = nil;
    [_DDP_mySever FDD_startWithOptions:@{XSNTC_jkServerOption_Port : @(_DDP_port),XSNTC_jkServerOption_BindToLocalhost : @(YES)} error:&error];
}



@end
