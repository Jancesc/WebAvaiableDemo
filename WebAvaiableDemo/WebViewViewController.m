//
//  WebViewViewController.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()
@property (nonatomic, strong) WKWebView *DDP_webView;

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 创建WebView
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES;
    [configuration.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];
    configuration.userContentController = [WKUserContentController new];
    self.DDP_webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    [configuration.userContentController addScriptMessageHandler:self name:@"ZKWK"];
    self.DDP_webView.navigationDelegate = self;
    UIColor *bgColor = [UIColor blackColor];
    self.view.backgroundColor = bgColor;
    self.DDP_webView .backgroundColor = bgColor;
    //DDConfuse
    self.DDP_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    self.DDP_webView.inspectable = YES;
    //DDConfuse
    [self.view addSubview:self.DDP_webView];
   
    [UIApplication sharedApplication].idleTimerDisabled = YES;

    [self.view addSubview:self.DDP_webView];
    
    // WebView约束
    [NSLayoutConstraint activateConstraints:@[
        [self.DDP_webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.DDP_webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.DDP_webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.DDP_webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    [self loadWebpage];
}


- (void)loadWebpage {

    
    // 创建NSURL对象
    NSURL *url = [NSURL URLWithString:self.url];
    

    
    // 创建URL请求并加载
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.DDP_webView loadRequest:request];
    

}
- (BOOL)prefersStatusBarHidden {
    return  YES;
}

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
        NSString *top = dict[@"data"][@"top"];
        NSString *bottom = dict[@"data"][@"bottom"];
        NSString *left = dict[@"data"][@"left"];
        NSString *right = dict[@"data"][@"right"];
    } else if ([name isEqualToString:@"rewardVideo"]) {

        [self FDD_videoDidClose];


    } else if ([name isEqualToString:@"updateRewardAdId"]) {
        

    }
}


- (void)FDD_videoDidClose {
    //DDConfuse

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSString *jsString = [NSString stringWithFormat:@"videoDidClosed();"];
        [self FDD_OCCallToJSWithString:jsString];
    });

}

#pragma mark - Objective-C 调 JS

- (void)FDD_OCCallToJSWithString:(NSString *)jsString;{
    //DDConfuse
    [self.DDP_webView evaluateJavaScript:jsString completionHandler:^(id obj, NSError * _Nullable error) {
        //DDConfuse
    }];
}

#pragma mark - methods

- (void)FDD_getInitInfoWithCallback:(NSString *)callback {
    //DDConfuse
    NSDictionary *info = nil;
    info = @{
        @"state" : @(1),
        @"data" : @{
            @"app_version": @"1.0",
            @"system_version":@"1.0",
            @"device_name":@"1.0",
            @"device_id" : @"1.0",
            @"session_id" : @"1.0",
            @"app_id" : @"1.0",
            @"bundle_id" :@"1.0",
            @"production": @"1.0",
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
//    [[ZKWindowModule FDD_sharedInstance] FDD_createNormalAddOneWindow];
    //DDConfuse

}

- (void)FDD_openSafari:(NSString *)path {
    //DDConfuse
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:path] options:[NSDictionary dictionary] completionHandler:nil];
}

@end
