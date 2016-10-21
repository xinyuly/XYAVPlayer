//
//  AVPlayer.h
//  XYAVPlayer
//
//  Created by lixinyu on 16/5/26.
//  Copyright © 2016年 xiaoyu. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AVPlayerItem;
@class AVURLAsset;
@class AVPlayer;
@class XYAVPlayer;
//protocol
@protocol XYAVPlayerDelegate <NSObject>

- (void)playerDidStartPlay:(XYAVPlayer*)player;
- (void)playerDidPausePlay:(XYAVPlayer*)player;
- (void)playerDidStopPlay: (XYAVPlayer*)player;
- (void)player:(XYAVPlayer *)player didLoadSeconds:(NSTimeInterval)availableSeconds totalSeconds:(NSTimeInterval)totalSeconds;
- (void)player:(XYAVPlayer *)player didUpdatePlayProgress:(NSTimeInterval)currentTime totalSeconds:(NSTimeInterval)totalSeconds;

- (void)player:(XYAVPlayer *)player readyToPlayItem:(AVPlayerItem *)playerItem;
- (void)player:(XYAVPlayer *)player didPlayToEndTime:(BOOL)endTime;
@end


@interface XYAVPlayer : NSObject
@property (nonatomic, readonly) AVPlayerItem       *currentItem;
@property (nonatomic, assign)   NSTimeInterval     currentTime;
@property (nonatomic, strong)   AVPlayer  *player;
@property (nonatomic, weak)     id<XYAVPlayerDelegate>deleagte;

+ (instancetype)sharedPlayer ;

- (void)playWithURL:(NSURL *)audioURL;

- (void)play;

- (void)pause;

- (void)stop;

- (BOOL)isPlaying;

- (void)clean;

@end
