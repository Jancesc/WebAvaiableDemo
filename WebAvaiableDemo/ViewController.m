//
//  ViewController.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "ViewController.h"
#import "WebViewViewController.h"
@interface ViewController ()

@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UIButton *loadButton;

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
- (BOOL)prefersStatusBarHidden {
    return  YES;
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
//    self.urlTextField.text = @"http://xtweb.kkxgame.cn/games/EP94R3LtEEmTt2XE/index.html?c=0&v=1";
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
    

    WebViewViewController *vc = [WebViewViewController new];
    vc.url = urlString;
    [UIApplication sharedApplication].delegate.window.rootViewController = vc;
   
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

@end
