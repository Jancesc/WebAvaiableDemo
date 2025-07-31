//
//  WebViewViewController.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "WebViewViewController.h"

@interface WebViewViewController ()
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation WebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 创建WebView
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.backgroundColor = [UIColor systemBackgroundColor];
    self.webView.inspectable = YES;

    [self.view addSubview:self.webView];
    
    // WebView约束
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
    [self loadWebpage];
}


- (void)loadWebpage {

    
    // 创建NSURL对象
    NSURL *url = [NSURL URLWithString:self.url];
    

    
    // 创建URL请求并加载
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    

}
- (BOOL)prefersStatusBarHidden {
    return  YES;
}

@end
