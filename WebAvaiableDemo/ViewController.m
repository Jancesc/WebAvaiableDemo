//
//  ViewController.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "ViewController.h"
#import "WebViewViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *urlTextField;
@property (nonatomic, strong) UITextField *gameNameTextField;
@property (nonatomic, strong) UIButton *loadButton;
@property (nonatomic, strong) UISwitch *vipSwitch;
@property (nonatomic, strong) UISwitch *ProdductionSwitch;
@property (nonatomic, strong) UILabel *vipDescriptionLabel;
@property (nonatomic, strong) UILabel *ProdductionDescriptionLabel;
@property (nonatomic, strong) UITableView *historyTableView;
@property (nonatomic, strong) UILabel *historyLabel;
@property (nonatomic, strong) NSMutableArray *historyArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化历史记录数组
    self.historyArray = [NSMutableArray array];
    
    // 设置视图背景色
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // 创建UI组件
    [self setupUI];
    
    // 设置约束
    [self setupConstraints];
    
    // 加载历史记录
    [self loadHistory];
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
    
    // 创建游戏名称输入框
    self.gameNameTextField = [[UITextField alloc] init];
    self.gameNameTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.gameNameTextField.placeholder = @"Enter Game Name";
    self.gameNameTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.gameNameTextField.font = [UIFont systemFontOfSize:14];
    self.gameNameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.gameNameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.view addSubview:self.gameNameTextField];
    
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
    
    // 创建历史记录标签
    self.historyLabel = [[UILabel alloc] init];
    self.historyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.historyLabel.text = @"历史记录";
    self.historyLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.view addSubview:self.historyLabel];
    
    // 创建历史记录表格
    self.historyTableView = [[UITableView alloc] init];
    self.historyTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.historyTableView.delegate = self;
    self.historyTableView.dataSource = self;
    self.historyTableView.backgroundColor = [UIColor systemBackgroundColor];
    self.historyTableView.layer.cornerRadius = 8;
    self.historyTableView.layer.borderWidth = 1;
    self.historyTableView.layer.borderColor = [UIColor systemGray4Color].CGColor;
    [self.historyTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"HistoryCell"];
    [self.view addSubview:self.historyTableView];
}

- (void)setupConstraints {
    // URL输入框约束
    [NSLayoutConstraint activateConstraints:@[
        [self.urlTextField.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20],
        [self.urlTextField.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.urlTextField.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [self.urlTextField.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // 游戏名称输入框约束
    [NSLayoutConstraint activateConstraints:@[
        [self.gameNameTextField.topAnchor constraintEqualToAnchor:self.urlTextField.bottomAnchor constant:10],
        [self.gameNameTextField.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.gameNameTextField.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [self.gameNameTextField.heightAnchor constraintEqualToConstant:44]
    ]];
    
    // 加载按钮约束
    [NSLayoutConstraint activateConstraints:@[
        [self.loadButton.topAnchor constraintEqualToAnchor:self.gameNameTextField.bottomAnchor constant:20],
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
    
    // 历史记录标签约束
    [NSLayoutConstraint activateConstraints:@[
        [self.historyLabel.topAnchor constraintEqualToAnchor:self.ProdductionDescriptionLabel.bottomAnchor constant:20],
        [self.historyLabel.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.historyLabel.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20]
    ]];
    
    // 历史记录表格约束
    [NSLayoutConstraint activateConstraints:@[
        [self.historyTableView.topAnchor constraintEqualToAnchor:self.historyLabel.bottomAnchor constant:10],
        [self.historyTableView.leadingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leadingAnchor constant:20],
        [self.historyTableView.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-20],
        [self.historyTableView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20]
    ]];
}

- (void)loadButtonTapped:(id)sender {
    [self loadWebpage];
}

- (void)loadWebpage {
    NSString *urlString = self.urlTextField.text;
    NSString *gameName = self.gameNameTextField.text;
    
    // 检查URL是否为空
    if (urlString.length == 0) {
        [self showAlertWithTitle:@"Error" message:@"Please enter a URL"];
        return;
    }
    
    // 检查游戏名称是否为空
    if (gameName.length == 0) {
        [self showAlertWithTitle:@"Error" message:@"Please enter a game name"];
        return;
    }
    
    // 保存到历史记录（包含游戏名和URL）
    [self saveToHistory:gameName urlString:urlString];
    
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
    
    // 添加游戏名称参数
    [stringM appendFormat:@"&gamename=%@", gameName];
    

    
    WebViewViewController *vc = [WebViewViewController new];
    vc.url = [stringM copy];
    [UIApplication sharedApplication].delegate.window.rootViewController = vc;
}

- (void)saveToHistory:(NSString *)gameName urlString:(NSString *)urlString {
    // 创建包含游戏名和URL的字典
    NSDictionary *historyItem = @{
        @"gameName": gameName,
        @"url": urlString
    };
    
    // 检查是否已存在相同的游戏名
    BOOL exists = NO;
    for (NSDictionary *item in self.historyArray) {
        if ([item[@"gameName"] isEqualToString:gameName]) {
            exists = YES;
            break;
        }
    }
    
    if (!exists) {
        [self.historyArray insertObject:historyItem atIndex:0];
        
        // 限制历史记录数量为20条
        if (self.historyArray.count > 20) {
            [self.historyArray removeLastObject];
        }
        
        // 保存到本地
        [self saveHistory];
        
        // 刷新表格
        [self.historyTableView reloadData];
    }
}

- (void)loadHistory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *savedHistory = [defaults objectForKey:@"WebHistory"];
    
    if (savedHistory && [savedHistory isKindOfClass:[NSArray class]]) {
        // 验证数据格式，过滤掉无效的数据
        NSMutableArray *validHistory = [NSMutableArray array];
        
        for (id item in savedHistory) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = (NSDictionary *)item;
                // 检查是否包含必要的键
                if (dict[@"gameName"] && dict[@"url"] && 
                    [dict[@"gameName"] isKindOfClass:[NSString class]] && 
                    [dict[@"url"] isKindOfClass:[NSString class]]) {
                    [validHistory addObject:item];
                }
            }
        }
        
        self.historyArray = validHistory;
    } else {
        // 如果没有保存的历史记录或格式不正确，初始化为空数组
        self.historyArray = [NSMutableArray array];
    }
    
    // 清理无效数据
    [self cleanupInvalidHistoryData];
    
    [self.historyTableView reloadData];
}

- (void)cleanupInvalidHistoryData {
    // 清理无效的历史记录数据
    NSMutableArray *validItems = [NSMutableArray array];
    
    for (id item in self.historyArray) {
        if ([item isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)item;
            if (dict[@"gameName"] && dict[@"url"] && 
                [dict[@"gameName"] isKindOfClass:[NSString class]] && 
                [dict[@"url"] isKindOfClass:[NSString class]] &&
                [dict[@"gameName"] length] > 0 && [dict[@"url"] length] > 0) {
                [validItems addObject:item];
            }
        }
    }
    
    self.historyArray = validItems;
    [self saveHistory];
    [self.historyTableView reloadData];
}

- (void)saveHistory {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.historyArray forKey:@"WebHistory"];
    [defaults synchronize];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.historyArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell" forIndexPath:indexPath];
    
    // 边界检查
    if (indexPath.row >= self.historyArray.count) {
        cell.textLabel.text = @"Invalid Item";
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    id item = self.historyArray[indexPath.row];
    
    // 数据格式验证
    if (![item isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = @"Invalid Data";
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    NSDictionary *historyItem = (NSDictionary *)item;
    NSString *gameName = historyItem[@"gameName"];
    NSString *urlString = historyItem[@"url"];
    
    // 验证必要字段
    if (!gameName || !urlString || ![gameName isKindOfClass:[NSString class]] || ![urlString isKindOfClass:[NSString class]]) {
        cell.textLabel.text = @"Invalid Data";
        cell.detailTextLabel.text = @"";
        return cell;
    }
    
    // 显示游戏名作为主标题
    cell.textLabel.text = gameName;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    cell.textLabel.numberOfLines = 1;
    
    // 显示完整URL作为副标题
    cell.detailTextLabel.text = urlString;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    cell.detailTextLabel.textColor = [UIColor systemGrayColor];
    cell.detailTextLabel.numberOfLines = 1;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 边界检查
    if (indexPath.row >= self.historyArray.count) {
        return;
    }
    
    id item = self.historyArray[indexPath.row];
    
    // 数据格式验证
    if (![item isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    NSDictionary *selectedHistoryItem = (NSDictionary *)item;
    NSString *selectedURL = selectedHistoryItem[@"url"];
    NSString *selectedGameName = selectedHistoryItem[@"gameName"];
    
    // 验证必要字段
    if (!selectedURL || !selectedGameName || ![selectedURL isKindOfClass:[NSString class]] || ![selectedGameName isKindOfClass:[NSString class]]) {
        return;
    }
    
    self.urlTextField.text = selectedURL;
    self.gameNameTextField.text = selectedGameName;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.historyArray removeObjectAtIndex:indexPath.row];
        [self saveHistory];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self loadWebpage];
    return YES;
}

@end
