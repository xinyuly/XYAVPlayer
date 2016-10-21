//
//  ViewController.m
//  XYAVPlayer
//
//  Created by lixinyu on 16/5/26.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "XYAVPlayer.h"
#import "XYAVPlayerView.h"

@interface playerView : UIView

@end
@implementation playerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}


@end


@interface ViewController ()<AVPlayerViewControllerDelegate>

@property (nonatomic, strong) XYAVPlayer *player;
@property (nonatomic, strong) XYAVPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:200/255.0 alpha:1];
    [self test1];
}

- (void)test1 {
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"test.mp4" withExtension:nil];
    self.playerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 250);
    self.playerView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:self.playerView];
    [self.player playWithURL:URL];
    [self.player play];
    self.player.deleagte = self.playerView;
}

- (void)test {
    //  创建播放控制器
    AVPlayerViewController *pvc = [[AVPlayerViewController alloc] init];
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"test.mp4" withExtension:nil];
    //  必须设置AVPlayer
    pvc.player = [[AVPlayer alloc]initWithURL:URL];
    pvc.delegate = self;
    pvc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 250);
    //  展示
    [self presentViewController:pvc animated:YES completion:^{
        //      让他播放
        [pvc.player play];
    }];
}

- (XYAVPlayer *)player {
    if (_player == nil) {
        _player = [[XYAVPlayer alloc] init];
    }
    return _player;
}

-(XYAVPlayerView *)playerView {
    if (_playerView == nil) {
        _playerView = [[XYAVPlayerView alloc] init];
    }
    return _playerView;
}
@end
