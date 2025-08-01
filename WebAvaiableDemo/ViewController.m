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
@property (nonatomic, strong) UISwitch *vipSwitch;
@property (nonatomic, strong) UISwitch *ProdductionSwitch;
@property (nonatomic, strong) UILabel *vipDescriptionLabel;
@property (nonatomic, strong) UILabel *ProdductionDescriptionLabel;
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
    
    // 创建VIP开关
    self.vipSwitch = [[UISwitch alloc] init];
    self.vipSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.vipSwitch];
    
    // 创建生产环境开关
    self.ProdductionSwitch = [[UISwitch alloc] init];
    self.ProdductionSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.ProdductionSwitch];
    
    // 创建VIP描述标签
    self.vipDescriptionLabel = [[UILabel alloc] init];
    self.vipDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.vipDescriptionLabel.text = @"VIP环境";
    [self.view addSubview:self.vipDescriptionLabel];
    
    // 创建生产环境描述标签
    self.ProdductionDescriptionLabel = [[UILabel alloc] init];
    self.ProdductionDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.ProdductionDescriptionLabel.text = @"生产环境(默认)";      
    [self.view addSubview:self.ProdductionDescriptionLabel];
    
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
    // VIP描述标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.vipDescriptionLabel.topAnchor constraintEqualToAnchor:self.loadButton.bottomAnchor constant:20],
        [self.vipDescriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20]
    ]];
    // VIP开关约束
    [NSLayoutConstraint activateConstraints:@[
        [self.vipSwitch.topAnchor constraintEqualToAnchor:self.loadButton.bottomAnchor constant:20],
        [self.vipSwitch.leadingAnchor constraintEqualToAnchor:self.vipDescriptionLabel.trailingAnchor constant:20]
    ]];
    // 生产环境描述标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.ProdductionDescriptionLabel.topAnchor constraintEqualToAnchor:self.vipDescriptionLabel.bottomAnchor constant:20],
        [self.ProdductionDescriptionLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20]
    ]];
    // 生产环境开关约束
    [NSLayoutConstraint activateConstraints:@[
        [self.ProdductionSwitch.topAnchor constraintEqualToAnchor:self.vipDescriptionLabel.bottomAnchor constant:20],
        [self.ProdductionSwitch.leadingAnchor constraintEqualToAnchor:self.ProdductionDescriptionLabel.trailingAnchor constant:20]
    ]];
    


}

- (void)loadButtonTapped:(id)sender {
    [self loadWebpage];
}

- (void)loadWebpage {
    NSString *urlString = self.urlTextField.text;
    
    NSMutableString *stringM = [NSMutableString stringWithString:urlString];
    if ([stringM containsString:@"?"]) {
        [stringM appendFormat:@"&gameid=%@",@"10000"];
    } else {
        [stringM appendFormat:@"?gameid=%@",@"10000"];
    }
    if (self.ProdductionSwitch.on == YES) {
        [stringM appendString:@"&c=1"];
    } else {
        [stringM appendString:@"&c=0"];
    }
    
    if (self.vipSwitch.on == YES) {
        [stringM appendString:@"&v=1"];
    } else {
        [stringM appendString:@"&v=0"];
    }
    
    // 创建NSURL对象
    

    WebViewViewController *vc = [WebViewViewController new];
    vc.url = [stringM copy];
    [UIApplication sharedApplication].delegate.window.rootViewController = vc;
   
}


@end
