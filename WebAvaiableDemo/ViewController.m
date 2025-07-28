//
//  ViewController.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "ViewController.h"

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置视图背景色
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建UI组件
    [self setupUI];
    
    // 设置约束
    [self setupConstraints];
}

- (void)setupUI {
    // 创建URL输入框
    self.urlTextField = [[UITextField alloc] init];
    self.urlTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.urlTextField.placeholder = @"Enter URL (e.g., https://www.apple.com)";
    self.urlTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.urlTextField.font = [UIFont systemFontOfSize:14];
    self.urlTextField.keyboardType = UIKeyboardTypeURL;
    self.urlTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.urlTextField.delegate = self;
    [self.view addSubview:self.urlTextField];
    
    // 创建加载按钮
    self.loadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loadButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.loadButton setTitle:@"Load Webpage" forState:UIControlStateNormal];
    self.loadButton.backgroundColor = [UIColor systemBlueColor];
    [self.loadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loadButton.layer.cornerRadius = 8;
    self.loadButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.loadButton addTarget:self action:@selector(loadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loadButton];
    
    // 创建WebView
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.navigationDelegate = self;
    self.webView.backgroundColor = [UIColor systemBackgroundColor];
    [self.view addSubview:self.webView];
}

- (void)setupConstraints {
    // URL输入框约束
    [NSLayoutConstraint activateConstraints:@[
        [self.urlTextField.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.urlTextField.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.urlTextField.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [self.urlTextField.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // 加载按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.loadButton.topAnchor constraintEqualToAnchor:self.urlTextField.bottomAnchor constant:20],
        [self.loadButton.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.loadButton.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [self.loadButton.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // WebView约束
    [NSLayoutConstraint activateConstraints:@[
        [self.webView.topAnchor constraintEqualToAnchor:self.loadButton.bottomAnchor constant:20],
        [self.webView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor],
        [self.webView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor],
        [self.webView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];
}

- (void)loadButtonTapped:(id)sender {
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
