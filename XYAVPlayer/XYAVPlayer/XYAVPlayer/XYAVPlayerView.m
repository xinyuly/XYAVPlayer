//
//  XYAVPlayerView.m
//  XYAVPlayer
//
//  Created by lixinyu on 16/5/26.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "XYAVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

static const CGFloat PlayerBarHeight = 40.0;

@interface XYAVPlayerView ()
@property (weak, nonatomic) IBOutlet UIProgressView *cacheView;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *endTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UIButton *pasueButton;
@property (strong, nonatomic)  UIView *playerBar;

@property (nonatomic, assign) UIView    *normalSuperview;
@property (nonatomic, assign) CGRect    normalFrame;
@property (nonatomic, assign) BOOL      fullScreen;//是否全屏
@property (nonatomic, assign) BOOL wantsFullScreen;
@property (nonatomic, strong) XYAVPlayer *avPlayer;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, assign) BOOL isLandscape;//是否横屏
@end

@implementation XYAVPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
    [[self playerLayer] setPlayer:player];
    
}

- (AVPlayerLayer *)playerLayer {
    return (AVPlayerLayer *)self.layer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ([super initWithFrame:frame]) {
        [self addSubview:self.playerBar];
        [self setupActivityIndicatorView];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:)   name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}
- (void)setupActivityIndicatorView {
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    
    [self.activityIndicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.activityIndicatorView setHidesWhenStopped:YES];
    [self addSubview:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
    [self.cacheView setProgress:0 animated:NO];
    [self.endTimeLabel setText:@"00:00"];
    [self.startTimeLabel setText:@"00:00"];
    [self.progressSlider setValue:0];
}
#pragma mark - 横竖屏和全屏
- (void)changeRotate:(NSNotification*)noti {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIInterfaceOrientationPortrait) {
        //竖屏
        [self setWantsFullScreen:NO];
        self.fullScreenButton.selected = NO;
    } else if (orientation ==  UIDeviceOrientationLandscapeLeft) {
        //横屏
        [self setWantsFullScreen:YES];
        self.fullScreenButton.selected = YES;
    }
}
- (void)setWantsFullScreen:(BOOL)wantsFullScreen {
    if (_wantsFullScreen != wantsFullScreen) {
        _wantsFullScreen = wantsFullScreen;
        [self setNeedsLayout];
    }
}
- (void)layoutSubviews {
    [super layoutSubviews];
    [self setUserInteractionEnabled:YES];
    
    if (!self.isLandscape) {
        if (self.wantsFullScreen) {
            [self showFullScreen];
        } else {
            [self exitFullScreen];
        }
    }
    CGFloat barY = CGRectGetMaxY(self.bounds) - PlayerBarHeight;
    self.playerBar.frame = CGRectMake(0, barY, self.bounds.size.width, PlayerBarHeight);
    self.activityIndicatorView.center = self.center;
}

- (void)showFullScreen {
    if (self.fullScreen) {
        return ;
    }
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    UIView *superview = self.superview;
    CGRect frame = self.frame;
    [self setNormalFrame:frame];
    [self setNormalSuperview:superview];
    CGPoint point = [superview convertPoint:frame.origin toView:window];
    frame.origin = point;
    
    [super setFrame:frame];
    [window addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self setFrame:window.bounds];
    } completion:^(BOOL finished) {
        CGFloat width  = (self.bounds.size.width - 50)*0.5;
        CGFloat height = (self.bounds.size.height-50)*0.5;
        self.activityIndicatorView.frame = CGRectMake(width,height, 50, 50);
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    self.fullScreen = YES;
}

- (void)exitFullScreen {
    if (!self.fullScreen) {
        return ;
    }
    
    [self.normalSuperview addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
        [self setFrame:self.normalFrame];
    } completion:^(BOOL finished) {
    }];
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationFade];
    self.fullScreen = NO;
}



#pragma mark - playerBar

-(UIView *)playerBar {
    if (_playerBar == nil) {
        _playerBar = [[[NSBundle mainBundle] loadNibNamed:@"XYPlayerBar" owner:self options:nil] firstObject];
        
        [_progressSlider setMaximumTrackTintColor:[UIColor colorWithWhite:125/255.0 alpha:0]];
        [_progressSlider setMinimumTrackImage:[UIImage imageNamed:@"progress_h"] forState:UIControlStateNormal];
        
        [_cacheView setProgressImage:[UIImage imageNamed:@"progress_d"]];
        
        [_progressSlider setThumbImage:[UIImage imageNamed:@"video-player-kedu"] forState:UIControlStateNormal];
        
        [_progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
        [_progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
        [_progressSlider setValue:0.f];
    }
    return _playerBar;
}
- (void)progressSliderValueChanged :(UISlider*)progressSlider {
    double currentTime = floor(progressSlider.value);
    self.avPlayer.currentTime = currentTime;
}

- (void)progressSliderTouchBegan :(UISlider*)progressSlider {
}

- (void)progressSliderTouchEnded :(UISlider*)progressSlider {
    if (!self.avPlayer.isPlaying) {
        self.pasueButton.selected = YES;
        [self pauseButton:self.pasueButton];
    }
    
}
- (IBAction)pauseButton:(UIButton*)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.avPlayer pause];
    } else {
        [self.avPlayer play];
    }
    [self.activityIndicatorView stopAnimating];
    
}
- (IBAction)fullscreenButton:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    if (self.fullScreen) {
        [self setWantsFullScreen:NO];
        return ;
    }
    [self setWantsFullScreen:YES];
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updatePlayBarStatus];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(updatePlayBarStatus) withObject:nil afterDelay:3];
    
}

- (void)updatePlayBarStatus {
    CGFloat alpha = self.playerBar.alpha;
    
    if (alpha >= 1.0) {
        alpha = 0.0f;
    } else {
        alpha = 1.0f;
    }
    
    [self setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.3
                     animations:^{
                         [self.playerBar setAlpha:alpha];
                     } completion:^(BOOL finished) {
                         [self setUserInteractionEnabled:YES];
                     }];

}
#pragma mark - delegate

- (void)playerDidStartPlay:(XYAVPlayer *)player {
   [self.activityIndicatorView stopAnimating];
}

- (void)playerDidPausePlay:(XYAVPlayer *)player {
    [self.pasueButton setSelected:YES];
}

- (void)playerDidStopPlay:(XYAVPlayer *)player {
    [self setPlayer:nil];
    [self.pasueButton setSelected:YES];
}
- (void)player:(XYAVPlayer *)player readyToPlayItem:(AVPlayerItem *)playerItem {
    if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
        [self.activityIndicatorView stopAnimating];
        self.playerBar.alpha = 1;
        [self updatePlayBarStatus];
        [self.pasueButton setSelected:NO];
    }
}
- (void)player:(XYAVPlayer *)player didPlayToEndTime:(BOOL)endTime {
    [self setPlayer:nil];
    [self.cacheView setProgress:0];
    [self.progressSlider setValue:0];
    [self.progressSlider setMaximumValue:0];
    [self.progressSlider setMinimumValue:0];
    [self.endTimeLabel setText:@"00:00"];
    [self.startTimeLabel setText:@"00:00"];
    [self.pasueButton setSelected:YES];
    
    if (self.fullScreen) {
        [self fullscreenButton:self.fullScreenButton];
        
    }
}
- (void)player:(XYAVPlayer *)player didLoadSeconds:(NSTimeInterval)availableSeconds totalSeconds:(NSTimeInterval)totalSeconds {
    [self setPlayer:player.player];
     self.avPlayer = player;
    self.progressSlider.minimumValue = 0.f;
    self.progressSlider.maximumValue = totalSeconds;
    
    [self.cacheView setProgress:availableSeconds/totalSeconds animated:YES];
    if (self.avPlayer.player.rate == 0 && self.pasueButton.selected == NO) {
        [self.activityIndicatorView startAnimating];
    }else {
        [self.activityIndicatorView stopAnimating];
    }
}
- (void)player:(XYAVPlayer *)player didUpdatePlayProgress:(NSTimeInterval)currentTime totalSeconds:(NSTimeInterval)totalSeconds {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalSeconds / 60.0);;
    double secondsRemaining = fmod(totalSeconds, 60.0);;
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    if ([timeRmainingString isEqualToString:@"nan:nan"]) {
        timeRmainingString = @"00:00";
    }
    self.startTimeLabel.text = [NSString stringWithFormat:@"%@",timeElapsedString];
    self.endTimeLabel.text = [NSString stringWithFormat:@"%@",timeRmainingString];
    
    self.progressSlider.value = currentTime;

}
@end
