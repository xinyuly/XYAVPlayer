//
//  AVPlayer.m
//  XYAVPlayer
//
//  Created by lixinyu on 16/5/26.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import "XYAVPlayer.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
NSString *const XYPlayerDidStartPlayNotification     = @"XYPlayerDidStartPlayNotification";
NSString *const XYPlayerDidPlayToEndTimeNotification = @"XYPlayerDidPlayToEndTimeNotification";
NSString *const XYPlayerDidPauseItemNotification     = @"XYPlayerDidPauseItemNotification";
@interface XYAVPlayer ()
//@property (nonatomic, strong)   AVPlayer  *player;
@end

@implementation XYAVPlayer


+ (instancetype)sharedPlayer {
    static id instance;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
#pragma mark - setter & getter 
- (AVPlayerItem *)currentItem {
    return self.player.currentItem;
}
- (void)setCurrentTime:(NSTimeInterval)currentTime {
    if (self.player == nil) {
        return;
    }
    CMTime newTime = self.currentItem.currentTime;
    newTime.value = newTime.timescale *currentTime;
    [self.player seekToTime:newTime];
}

-(NSTimeInterval)currentTime {
    if (self.player == nil) {
        return 0;
    }
    CGFloat currenTime = CMTimeGetSeconds(self.player.currentTime);
    return currenTime;
}
- (void)playWithURL:(NSURL *)URL{
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:URL];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
    //kVO
    [_player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [_player.currentItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    
    __weak typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {
        CGFloat currenTime = weakSelf.currentTime;
        if ([weakSelf.deleagte respondsToSelector:@selector(player:didUpdatePlayProgress:totalSeconds:)]) {
            [weakSelf.deleagte player:weakSelf didUpdatePlayProgress:currenTime totalSeconds:CMTimeGetSeconds(weakSelf.player.currentItem.duration)];
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
     AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath  isEqual: @"status"]) {
        if ([self.deleagte respondsToSelector:@selector(player:readyToPlayItem:)]) {
            [self.deleagte player:self readyToPlayItem:playerItem];
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        if (self.isPlaying == NO) {
            [self play];
        }
        NSTimeInterval availableSeconds = [self availableSeconds:playerItem];
        if ([self.deleagte respondsToSelector:@selector(player:didLoadSeconds:totalSeconds:)]) {
            [self.deleagte player:self didLoadSeconds:availableSeconds totalSeconds:CMTimeGetSeconds(playerItem.duration)];
        }
    }
}
- (NSTimeInterval)availableSeconds:(AVPlayerItem*)playerItem {
    NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue]; //获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds; //计算缓冲总进度
    return result;
}
//移除监听
- (void)dealloc {
    [self removeObserver:self forKeyPath:@"status" ];
    [self removeObserver:self forKeyPath:@"loadedTimeRanges" ];
}
#pragma mark - notification 
- (void) playerItemDidPlayToEndTime:(NSNotification*)noti {
    if ([self.deleagte respondsToSelector:@selector(player:didPlayToEndTime:)]) {
        [self.deleagte player:self didPlayToEndTime:YES];
    }
}


#pragma mark - paly Action
- (void)play{
    if (self.player && ![self isPlaying]) {
        [self.player play];
        [[NSNotificationCenter defaultCenter] postNotificationName:XYPlayerDidStartPlayNotification object:self.player.currentItem];
        if ([self.deleagte respondsToSelector:@selector(playerDidStartPlay:)]) {
            [self.deleagte playerDidStartPlay:self];
        }
    }
}

- (void)pause{
    if (self.player) {
        [self.player pause];
        [[NSNotificationCenter defaultCenter] postNotificationName:XYPlayerDidPauseItemNotification   object:self.player.currentItem];
        if ([self.deleagte respondsToSelector:@selector(playerDidPausePlay:)]) {
            [self.deleagte playerDidPausePlay:self];
        }
    }
}

- (void)stop{
    if (self.player) {
        [self.player pause];
        if ([self.deleagte respondsToSelector:@selector(playerDidStopPlay:)]) {
            [self.deleagte playerDidStopPlay:self];
        }
    }
    [self clean];
}

- (BOOL)isPlaying{
    return self.player.rate != 0;
}

- (void)clean{
    [self.player pause];
    self.player = nil;
}

@end
