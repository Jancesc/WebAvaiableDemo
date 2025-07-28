//
//  ViewController.h
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet WKWebView *webView;

- (IBAction)loadButtonTapped:(id)sender;

@end

