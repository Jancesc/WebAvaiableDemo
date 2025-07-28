//
//  ViewController.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "ViewController.h"

@interface ViewController () <WKNavigationDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置WebView的导航代理
    self.webView.navigationDelegate = self;
    
    // 设置URL输入框的占位符文本
    self.urlTextField.placeholder = @"Enter URL (e.g., https://www.apple.com)";
    
    // 设置按钮标题
    [self.loadButton setTitle:@"Load Webpage" forState:UIControlStateNormal];
    
    // 设置输入框的键盘类型
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    self.urlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    // 添加输入框的返回键处理
    self.urlTextField.delegate = self;
}

- (IBAction)loadButtonTapped:(id)sender {
    [self loadWebpage];
}

- (void)loadWebpage {
    NSString *urlString = self.urlTextField.text;
    
    // 检查URL是否为空
    if (urlString.length == 0) {
        [self showAlertWithTitle:@"Error" message:@"Please enter a URL"];
        return;
    }
    
    // 确保URL有协议前缀
    if (![urlString hasPrefix:@"http://"] && ![urlString hasPrefix:@"https://"]) {
        urlString = [@"https://" stringByAppendingString:urlString];
    }
    
    // 创建NSURL对象
    NSURL *url = [NSURL URLWithString:urlString];
    
    // 验证URL是否有效
    if (!url) {
        [self showAlertWithTitle:@"Invalid URL" message:@"Please enter a valid URL"];
        return;
    }
    
    // 创建URL请求并加载
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    // 隐藏键盘
    [self.urlTextField resignFirstResponder];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    // 网页开始加载时的处理
    [self.loadButton setTitle:@"Loading..." forState:UIControlStateNormal];
    self.loadButton.enabled = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 网页加载完成时的处理
    [self.loadButton setTitle:@"Load Webpage" forState:UIControlStateNormal];
    self.loadButton.enabled = YES;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    // 网页加载失败时的处理
    [self.loadButton setTitle:@"Load Webpage" forState:UIControlStateNormal];
    self.loadButton.enabled = YES;
    [self showAlertWithTitle:@"Load Failed" message:[NSString stringWithFormat:@"Failed to load webpage: %@", error.localizedDescription]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loadWebpage];
    return YES;
}

@end
