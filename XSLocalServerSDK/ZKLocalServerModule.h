//
//  ZKLocalServerModule.h
//  XSLocalServerSDK
//
//  Created by zkJan on 4/23/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZKLocalServerModule : NSObject

@property (nonatomic, assign)NSInteger DDP_port;


+ (instancetype)FDD_sharedModule;

- (void)FDD_setupServer;
@end

NS_ASSUME_NONNULL_END
