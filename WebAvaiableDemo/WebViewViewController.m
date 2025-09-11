
#import "WebViewViewController.h"
#import <WebKit/WebKit.h>

#import <AudioToolbox/AudioToolbox.h>

@interface WebViewViewController ()<WKScriptMessageHandler,WKNavigationDelegate>


@property (nonatomic, strong)WKWebView *DDP_webView;
@property (nonatomic, assign)NSInteger DDP_timeoutInterval;
@property (nonatomic, assign)CGFloat DDP_isPortrait;
@property (nonatomic, assign)BOOL DDP_isWebInit;

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //DDConfuse
    self.DDP_isPortrait = 1;
    self.DDP_timeoutInterval = 10;
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    // 默认是NO，这个值决定了用内嵌HTML5播放视频还是用本地的全屏控制
    configuration.allowsInlineMediaPlayback = YES;
    // 自动播放, 不需要用户采取任何手势开启播放
    // WKAudiovisualMediaTypeNone 音视频的播放不需要用户手势触发, 即为自动播放
    configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    configuration.allowsAirPlayForMediaPlayback = YES;
    configuration.allowsPictureInPictureMediaPlayback = YES;
    
    configuration.userContentController = [WKUserContentController new];
    self.DDP_webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [configuration.userContentController addScriptMessageHandler:self name:@"ZKWK"];
    self.DDP_webView.navigationDelegate = self;
    UIColor *bgColor = [UIColor blackColor];
    self.view.backgroundColor = bgColor;
    self.DDP_webView .backgroundColor = bgColor;
    //DDConfuse
    self.DDP_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    //DDConfuse
    [self.view addSubview:self.DDP_webView];
   
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [self FDD_loadRequest];
    [self FDD_updateWebviewFrame];
 
    if (@available(iOS 16.4, *)) {
        self.DDP_webView.inspectable = YES;
    } else {
        // Fallback on earlier versions
    }

    
    //DDConfuse

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FDD_BecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FDD_EnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    


}

- (void)FDD_BecomeActive {
    //DDConfuse

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *jsString = [NSString stringWithFormat:@"intoforeground();"];
        [self FDD_OCCallToJSWithString:jsString];
    });
}


- (void)FDD_EnterBackground {
    //DDConfuse
    NSString *jsString = [NSString stringWithFormat:@"intobackground();"];
    [self FDD_OCCallToJSWithString:jsString];
}

-(void)dealloc {
    //DDConfuse

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)FDD_updateWebviewFrame {
    //DDConfuse
    
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.DDP_webView.frame = bounds;

}



-(void)FDD_showTips:(NSString *)tips XSNTC_stable:(BOOL) stable{

    //DDConfuse
    UIView *view = self.view;
    UILabel *tipsLabel = [view viewWithTag:110];
       
    if (tipsLabel == nil) {
               
        tipsLabel = [UILabel new];
        tipsLabel.tag = 110;
        tipsLabel.alpha = 0;
        tipsLabel.textColor = [UIColor whiteColor];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = [UIFont systemFontOfSize:18];
        tipsLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
        tipsLabel.layer.cornerRadius = 5.f;
        tipsLabel.clipsToBounds = YES;
        tipsLabel.numberOfLines = 0;
        [view addSubview:tipsLabel];
    }
        
    //DDConfuse
    tipsLabel.text = tips;
    CGSize size = [tips boundingRectWithSize:CGSizeMake(275, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : tipsLabel.font} context:nil].size;
    if (size.width < 50) {
        
        size.width = 50;
    }
    
    if (size.height < 30) {
        
        size.height = 30;
    }
    CGRect frame = tipsLabel.frame;
    frame.size.width = size.width + 20;
    frame.size.height = size.height + 10;
    tipsLabel.frame = frame;
    tipsLabel.center = CGPointMake(view.bounds.size.width*0.5, view.bounds.size.height*0.5);
//DDConfuse
    tipsLabel.alpha = 1;
    [tipsLabel.superview bringSubviewToFront:tipsLabel];
    if (stable == NO) {
        [UIView animateWithDuration:1.5 delay:1.5 options:UIViewAnimationOptionCurveEaseOut animations:^{
           
            tipsLabel.alpha = 0;
        } completion:^(BOOL finished) {
            //DDConfuse
        }];
    }
}

- (void)FDD_loadRequest {


    //DDConfuse
    NSMutableString *stringM = [NSMutableString stringWithString:self.url];

    NSURL *baseURL = [NSURL URLWithString:[stringM copy]];
    //DDConfuse
    NSURLRequest *request = [NSURLRequest requestWithURL:baseURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:self.DDP_timeoutInterval];
    [self.DDP_webView loadRequest:request];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((self.DDP_timeoutInterval+0.5) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.DDP_isWebInit == NO) {
            //DDConfuse
            if (self.DDP_timeoutInterval < 15) {
                self.DDP_timeoutInterval = self.DDP_timeoutInterval+2;
            }
            [self FDD_loadRequest];
        }
    });
}

- (void)viewDidLayoutSubviews {
    //DDConfuse
    [super viewDidLayoutSubviews];
    [self FDD_updateWebviewFrame];

}

- (UIStatusBarStyle)preferredStatusBarStyle {
    //DDConfuse

    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    //DDConfuse

    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    //DDConfuse

    return YES;
}

#pragma mark - JS调Objective-C

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    //DDConfuse
    NSDictionary *dict = message.body;
    NSString *name = message.body[@"name"];
    NSLog(@"++++%@", name);
    if ([name isEqualToString:@"getInitInfo"]) {

        //DDConfuse
        NSString *callback = dict[@"callback"];
        [self FDD_getInitInfoWithCallback:callback];
    }else if ([name isEqualToString:@"onWebInit"]) {
        //DDConfuse
        
        [self FDD_onWebInit];
    } else if ([name isEqualToString:@"openSafari"]) {
        //DDConfuse
        NSString *path = dict[@"data"][@"url"];
        [self FDD_openSafari:path];

    } else if ([name isEqualToString:@"inset"]) {
        //DDConfuse

        [self FDD_updateWebviewFrame];
    } else if ([name isEqualToString:@"rewardVideo"]) {
        if ([self.url containsString:@"v=1"]) {
            [self FDD_videoShowFinished:YES XSNTC_rewarded:YES];
        }else {
            [self FDD_showTips:@"模拟广告..." XSNTC_stable:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self FDD_videoShowFinished:YES XSNTC_rewarded:YES];
            });
        }
        


    }else if ([name isEqualToString:@"gamevVibrate"]) {
        // 处理震动请求
        NSInteger level = [dict[@"level"] integerValue];
        [self FDD_vibrateWithLevel:level];
    }
}

#pragma mark - Objective-C 调 JS

- (void)FDD_OCCallToJSWithString:(NSString *)jsString;{
    //DDConfuse
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.DDP_webView evaluateJavaScript:jsString completionHandler:^(id obj, NSError * _Nullable error) {
            //DDConfuse
        }];
    });

}

#pragma mark - methods

- (void)FDD_vibrateWithLevel:(NSInteger)level {
    //DDConfuse

    // 根据级别选择不同的震动效果
    switch (level) {
        case 1: // 轻微震动
            if (@available(iOS 13.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
                [generator prepare];
                [generator impactOccurred];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 2: // 中等震动
            if (@available(iOS 13.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [generator prepare];
                [generator impactOccurred];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 3: // 强烈震动
            if (@available(iOS 13.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                [generator prepare];
                [generator impactOccurred];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 4: // 成功反馈震动
            if (@available(iOS 13.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator prepare];
                [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 5: // 警告反馈震动
            if (@available(iOS 13.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator prepare];
                [generator notificationOccurred:UINotificationFeedbackTypeWarning];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 6: // 错误反馈震动
            if (@available(iOS 13.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator prepare];
                [generator notificationOccurred:UINotificationFeedbackTypeError];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        default: // 默认震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
    }
}
- (void)FDD_getInitInfoWithCallback:(NSString *)callback {
    //DDConfuse
    NSDictionary *info = nil;
    info = @{
        @"state" : @(1),
        @"data" : @{
            @"app_version": @"1.0.0",
            @"system_version":@"test",
            @"device_name":@"test",
            @"device_id" : @"test",
            @"session_id" : @"test",
            @"app_id" : @"test",
            @"bundle_id" : @"test",
        },
        @"msg":@"",
    };
    
    //DDConfuse
    NSData *data = [NSJSONSerialization dataWithJSONObject:info options:(NSJSONWritingPrettyPrinted) error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *jsString = [NSString stringWithFormat:@"%@(%@);", callback, jsonString];
    [self FDD_OCCallToJSWithString:jsString];
}



- (void)FDD_onWebInit {
    //DDConfuse
    
    self.DDP_isWebInit = YES;

}

- (void)FDD_openSafari:(NSString *)path {
    //DDConfuse
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path] options:[NSDictionary dictionary] completionHandler:nil];
}


- (BOOL)shouldAutorotate {
    //DDConfuse

    return  YES;;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    //DDConfuse
    return self.DDP_isPortrait ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskLandscape;

}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    //DDConfuse

    return self.DDP_isPortrait ? UIInterfaceOrientationPortrait : UIInterfaceOrientationLandscapeRight;
}





- (void)FDD_videoShowFinished:(BOOL)success XSNTC_rewarded:(BOOL)rewarded {

    if (rewarded) {
        NSString *jsString = [NSString stringWithFormat:@"videoDidEarnReward();"];
        [self FDD_OCCallToJSWithString:jsString];
    }
    NSString *jsString1 = [NSString stringWithFormat:@"videoDidClosed();"];
    [self FDD_OCCallToJSWithString:jsString1];

}



#pragma mark - 震动功能

- (void)vibrateWithLevel:(NSInteger)level {
    // 根据级别选择不同的震动效果
    switch (level) {
        case 1: // 轻微震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
            
        case 2: // 中等震动
            if (@available(iOS 13.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [generator prepare];
                [generator impactOccurred];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 3: // 强烈震动
            if (@available(iOS 13.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                [generator prepare];
                [generator impactOccurred];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 4: // 成功反馈震动
            if (@available(iOS 13.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator prepare];
                [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 5: // 警告反馈震动
            if (@available(iOS 13.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator prepare];
                [generator notificationOccurred:UINotificationFeedbackTypeWarning];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        case 6: // 错误反馈震动
            if (@available(iOS 13.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator prepare];
                [generator notificationOccurred:UINotificationFeedbackTypeError];
            } else {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
            break;
            
        default: // 默认震动
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            break;
    }
}
@end

