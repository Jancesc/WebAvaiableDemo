//
//  AppDelegate.m
//  WebAvaiableDemo
//
//  Created by Jan on 2025/7/28.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "ZKLocalServerModule.h"
@interface AppDelegate ()

@property (nonatomic, strong) AVAudioPlayer *backgroundMusicPlayer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 创建窗口
    [[ZKLocalServerModule FDD_sharedModule] FDD_setupServer];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // 创建根视图控制器
    ViewController *rootViewController = [[ViewController alloc] init];
    
    // 设置根视图控制器
    self.window.rootViewController = rootViewController;
    
    // 显示窗口
    [self.window makeKeyAndVisible];

    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
//    sleep(0.5);
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    NSError *error = nil;
//    [audioSession setCategory:AVAudioSessionCategoryAmbient error:&error];
//    if (error) {
//        NSLog(@"设置音频会话错误：%@", error.localizedDescription);
//    }
//    [audioSession setActive:YES error:&error];
//    if (error) {
//        NSLog(@"激活音频会话错误：%@", error.localizedDescription);
//    }
//    
//    // 播放背景音乐
//    [self playBackgroundMusic];
}

#pragma mark - Background Music

- (void)playBackgroundMusic {
    // 获取bg.mp3文件路径
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
    
    if (!musicPath) {
        NSLog(@"找不到bg.mp3文件");
        return;
    }
    
    NSURL *musicURL = [NSURL fileURLWithPath:musicPath];
    
    NSError *error = nil;
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicURL error:&error];
    
    if (error) {
        NSLog(@"初始化音频播放器错误：%@", error.localizedDescription);
        return;
    }
    
    // 设置音频播放器属性
//    self.backgroundMusicPlayer.numberOfLoops = -1; // 无限循环
    self.backgroundMusicPlayer.volume = 0.5; // 设置音量为50%
    
    // 准备播放
    [self.backgroundMusicPlayer prepareToPlay];
    
    // 开始播放
    BOOL success = [self.backgroundMusicPlayer play];
    if (success) {
        NSLog(@"背景音乐开始播放");
    } else {
        NSLog(@"背景音乐播放失败");
    }
}

- (void)stopBackgroundMusic {
    if (self.backgroundMusicPlayer && self.backgroundMusicPlayer.isPlaying) {
        [self.backgroundMusicPlayer stop];
        NSLog(@"背景音乐已停止");
    }
}

- (void)pauseBackgroundMusic {
    if (self.backgroundMusicPlayer && self.backgroundMusicPlayer.isPlaying) {
        [self.backgroundMusicPlayer pause];
        NSLog(@"背景音乐已暂停");
    }
}

- (void)resumeBackgroundMusic {
    if (self.backgroundMusicPlayer && !self.backgroundMusicPlayer.isPlaying) {
        [self.backgroundMusicPlayer play];
        NSLog(@"背景音乐已恢复播放");
    }
}
@end
