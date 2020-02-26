//
//  IRPlayerController.m
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/23.
//  Copyright © 2020 irons. All rights reserved.
//
//  ZFPlayerController.m
//  ZFPlayer
//
// Copyright (c) 2016年 任子丰 ( http://github.com/renzifeng )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "IRPlayerController.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "UIScrollView+IRPlayer.h"
#import "IRReachabilityManager.h"
#import "IRPlayer.h"
#import "IRScope.h"

@interface IRPlayerController ()

@property (nonatomic, strong) IRPlayerControllerNotification *notification;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) UISlider *volumeViewSlider;
@property (nonatomic, assign) NSInteger containerViewTag;
@property (nonatomic, assign) IRPlayerContainerType containerType;
/// The player's small container view.
@property (nonatomic, strong) IRFloatView *smallFloatView;
/// Whether the small window is displayed.
@property (nonatomic, assign) BOOL isSmallFloatViewShow;
/// The indexPath is playing.
@property (nonatomic, nullable) NSIndexPath *playingIndexPath;

@end

@implementation IRPlayerController

- (instancetype)init {
    self = [super init];
    if (self) {
        @weakify(self)
        [[IRReachabilityManager sharedManager] startMonitoring];
        [[IRReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(IRReachabilityStatus status) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(videoPlayer:reachabilityChanged:)]) {
                [self.controlView videoPlayer:self reachabilityChanged:status];
            }
        }];
        [self configureVolume];
    }
    return self;
}

/// Get system volume
- (void)configureVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
}

- (void)dealloc {
//    [self.currentPlayerManager stop];
    [self.currentPlayerManager pause];
}

//+ (instancetype)playerWithPlayerManager:(id<IRPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
//    IRPlayerController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
//    return player;
//}

+ (instancetype)playerWithPlayerManager:(IRPlayerImp *)playerManager containerView:(UIView *)containerView {
    IRPlayerController *player = [[self alloc] initWithPlayerManager:playerManager containerView:containerView];
    return player;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<IRPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    IRPlayerController *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerViewTag:containerViewTag];
    return player;
}

+ (instancetype)playerWithScrollView:(UIScrollView *)scrollView playerManager:(id<IRPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView {
    IRPlayerController *player = [[self alloc] initWithScrollView:scrollView playerManager:playerManager containerView:containerView];
    return player;
}

//- (instancetype)initWithPlayerManager:(id<IRPlayerMediaPlayback>)playerManager containerView:(nonnull UIView *)containerView {
//    IRPlayerController *player = [self init];
//    player.containerView = containerView;
//    player.currentPlayerManager = playerManager;
//    player.containerType = IRPlayerContainerTypeView;
//    return player;
//}

- (instancetype)initWithPlayerManager:(IRPlayerImp *)playerManager containerView:(nonnull UIView *)containerView {
    IRPlayerController *player = [self init];
    player.containerView = containerView;
    player.currentPlayerManager = playerManager;
    player.containerType = IRPlayerContainerTypeView;
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<IRPlayerMediaPlayback>)playerManager containerViewTag:(NSInteger)containerViewTag {
    IRPlayerController *player = [self init];
    player.scrollView = scrollView;
    player.containerViewTag = containerViewTag;
    player.currentPlayerManager = playerManager;
    player.containerType = IRPlayerContainerTypeCell;
    return player;
}

- (instancetype)initWithScrollView:(UIScrollView *)scrollView playerManager:(id<IRPlayerMediaPlayback>)playerManager containerView:(UIView *)containerView {
    IRPlayerController *player = [self init];
    player.scrollView = scrollView;
    player.containerView = containerView;
    player.currentPlayerManager = playerManager;
    player.containerType = IRPlayerContainerTypeView;
    return player;
}

- (void)playerManagerCallbcak {
    [self.currentPlayerManager registerPlayerNotificationTarget:self
       stateAction:@selector(stateAction:)
    progressAction:@selector(progressAction:)
    playableAction:@selector(playableAction:)
       errorAction:@selector(errorAction:)];
    
    
//    @weakify(self)
//    self.currentPlayerManager.playerPrepareToPlay = ^(id<IRPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
//        @strongify(self)
//        self.currentPlayerManager.view.hidden = NO;
//        [self.notification addNotification];
//        [self addDeviceOrientationObserver];
//        if (self.scrollView) {
//            self.scrollView.ir_stopPlay = NO;
//        }
//        [self layoutPlayerSubViews];
//        if (self.playerPrepareToPlay) self.playerPrepareToPlay(asset,assetURL);
//        if ([self.controlView respondsToSelector:@selector(videoPlayer:prepareToPlay:)]) {
//            [self.controlView videoPlayer:self prepareToPlay:assetURL];
//        }
//    };
//
//    self.currentPlayerManager.playerReadyToPlay = ^(id<IRPlayerMediaPlayback>  _Nonnull asset, NSURL * _Nonnull assetURL) {
//        @strongify(self)
//        if (self.playerReadyToPlay) self.playerReadyToPlay(asset,assetURL);
//        if (!self.customAudioSession) {
//            // Apps using this category don't mute when the phone's mute button is turned on, but play sound when the phone is silent
//            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
//            [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        }
//        if (self.viewControllerDisappear) self.pauseByEvent = YES;
//    };
//
//    self.currentPlayerManager.playerPlayTimeChanged = ^(id<IRPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
//        @strongify(self)
//        if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(asset,currentTime,duration);
//        if ([self.controlView respondsToSelector:@selector(videoPlayer:currentTime:totalTime:)]) {
//            [self.controlView videoPlayer:self currentTime:currentTime totalTime:duration];
//        }
//    };
//
//    self.currentPlayerManager.playerBufferTimeChanged = ^(id<IRPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval bufferTime) {
//        @strongify(self)
//        if ([self.controlView respondsToSelector:@selector(videoPlayer:bufferTime:)]) {
//            [self.controlView videoPlayer:self bufferTime:bufferTime];
//        }
//        if (self.playerBufferTimeChanged) self.playerBufferTimeChanged(asset,bufferTime);
//    };
//
//    self.currentPlayerManager.playerPlayStateChanged = ^(id  _Nonnull asset, IRPlayerPlaybackState playState) {
//        @strongify(self)
//        if (self.playerPlayStateChanged) self.playerPlayStateChanged(asset, playState);
//        if ([self.controlView respondsToSelector:@selector(videoPlayer:playStateChanged:)]) {
//            [self.controlView videoPlayer:self playStateChanged:playState];
//        }
//    };
//
//    self.currentPlayerManager.playerLoadStateChanged = ^(id  _Nonnull asset, IRPlayerLoadState loadState) {
//        @strongify(self)
//        if (self.playerLoadStateChanged) self.playerLoadStateChanged(asset, loadState);
//        if ([self.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
//            [self.controlView videoPlayer:self loadStateChanged:loadState];
//        }
//    };
//
//    self.currentPlayerManager.playerDidToEnd = ^(id  _Nonnull asset) {
//        @strongify(self)
//        if (self.playerDidToEnd) self.playerDidToEnd(asset);
//        if ([self.controlView respondsToSelector:@selector(videoPlayerPlayEnd:)]) {
//            [self.controlView videoPlayerPlayEnd:self];
//        }
//    };
//
//    self.currentPlayerManager.playerPlayFailed = ^(id<IRPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
//        @strongify(self)
//        if (self.playerPlayFailed) self.playerPlayFailed(asset, error);
//        if ([self.controlView respondsToSelector:@selector(videoPlayerPlayFailed:error:)]) {
//            [self.controlView videoPlayerPlayFailed:self error:error];
//        }
//    };
//
//    self.currentPlayerManager.presentationSizeChanged = ^(id<IRPlayerMediaPlayback>  _Nonnull asset, CGSize size){
//        @strongify(self)
//        if (self.orientationObserver.fullScreenMode == IRFullScreenModeAutomatic) {
//            if (size.width > size.height) {
//                self.orientationObserver.fullScreenMode = IRFullScreenModeLandscape;
//            } else {
//                self.orientationObserver.fullScreenMode = IRFullScreenModePortrait;
//            }
//        }
//        if (self.presentationSizeChanged) self.presentationSizeChanged(asset, size);
//        if ([self.controlView respondsToSelector:@selector(videoPlayer:presentationSizeChanged:)]) {
//            [self.controlView videoPlayer:self presentationSizeChanged:size];
//        }
//    };
}

- (void)stateAction:(NSNotification *)notification
{
    [self dealWithNotification:notification Player:self.currentPlayerManager];
}

- (void)progressAction:(NSNotification *)notification
{
    //    IRProgress * progress = [IRProgress progressFromUserInfo:notification.userInfo];
    //    if (!self.progressSilderTouching) {
    //        self.progressSilder.value = progress.percent;
    //    }
    //    self.currentTimeLabel.text = [self timeStringFromSeconds:progress.current];
    
//    if (self.playerPlayTimeChanged) self.playerPlayTimeChanged(asset,currentTime,duration);
    if ([self.controlView respondsToSelector:@selector(videoPlayer:currentTime:totalTime:)]) {
        IRProgress * progress = [IRProgress progressFromUserInfo:notification.userInfo];
//        if (!self.progressSilderTouching) {
//            self.progressSilder.value = progress.percent;
//        }
        [self.controlView videoPlayer:self currentTime:progress.current totalTime:progress.total];
    }
}

- (NSString *)timeStringFromSeconds:(CGFloat)seconds
{
    return [NSString stringWithFormat:@"%ld:%.2ld", (long)seconds / 60, (long)seconds % 60];
}

- (void)playableAction:(NSNotification *)notification
{
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)errorAction:(NSNotification *)notification
{
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

- (void)dealWithNotification:(NSNotification *)notification Player:(IRPlayerImp *)player {
    IRState * state = [IRState stateFromUserInfo:notification.userInfo];
    
    NSString * text;
    switch (state.current) {
        case IRPlayerStateNone:
            text = @"None";
            break;
        case IRPlayerStateBuffering:
            text = @"Buffering...";
            
            self.currentPlayerManager.view.hidden = NO;
            [self.notification addNotification];
            [self addDeviceOrientationObserver];
            if (self.scrollView) {
                self.scrollView.ir_stopPlay = NO;
            }
            [self layoutPlayerSubViews];
//            if (self.playerPrepareToPlay) self.playerPrepareToPlay(asset,assetURL);
            if ([self.controlView respondsToSelector:@selector(videoPlayer:prepareToPlay:)]) {
                [self.controlView videoPlayer:self prepareToPlay:player.contentURL];
            }
            
            if ([self.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                [self.controlView videoPlayer:self loadStateChanged:IRPlayerLoadStateStalled];
            }
            
            break;
        case IRPlayerStateReadyToPlay:
            text = @"Prepare";
            //            self.totalTimeLabel.text = [self timeStringFromSeconds:self.player.duration];
            
            if ([self.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                [self.controlView videoPlayer:self loadStateChanged:IRPlayerLoadStatePlayable];
            }
//            if (self.playerReadyToPlay) self.playerReadyToPlay(asset,assetURL);
            if (!self.customAudioSession) {
                // Apps using this category don't mute when the phone's mute button is turned on, but play sound when the phone is silent
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            }
            if (self.viewControllerDisappear) self.pauseByEvent = YES;
            
            [player play];
            break;
        case IRPlayerStatePlaying:
            text = @"Playing";
            if ([self.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                [self.controlView videoPlayer:self loadStateChanged:IRPlayerLoadStatePlaythroughOK];
            }
            break;
        case IRPlayerStateSuspend:
            text = @"Suspend";
            break;
        case IRPlayerStateFinished:
            text = @"Finished";
            break;
        case IRPlayerStateFailed:
            text = @"Error";
//            if (self.playerPlayFailed) self.playerPlayFailed(asset, error);
            if ([self.controlView respondsToSelector:@selector(videoPlayerPlayFailed:error:)]) {
                IRError *error = [IRError errorFromUserInfo:notification.userInfo];
                [self.controlView videoPlayerPlayFailed:self error:error];
            }
            break;
    }
    //    self.stateLabel.text = text;
}

- (void)layoutPlayerSubViews {
    if (self.containerView && self.currentPlayerManager.view) {
        UIView *superview = nil;
        if (self.isFullScreen) {
            superview = self.orientationObserver.fullScreenContainerView;
        } else if (self.containerView) {
            superview = self.containerView;
        }
        [superview addSubview:self.currentPlayerManager.view];
        [self.currentPlayerManager.view addSubview:self.controlView];
        
        self.currentPlayerManager.view.frame = superview.bounds;
        self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.controlView.frame = self.currentPlayerManager.view.bounds;
        self.controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.orientationObserver updateRotateView:self.currentPlayerManager.view containerView:self.containerView];
    }
}

#pragma mark - getter

- (IRPlayerControllerNotification *)notification {
    if (!_notification) {
        _notification = [[IRPlayerControllerNotification alloc] init];
        @weakify(self)
        _notification.willResignActive = ^(IRPlayerControllerNotification * _Nonnull registrar) {
            @strongify(self)
            if (self.isViewControllerDisappear) return;
            if (self.pauseWhenAppResignActive && self.currentPlayerManager.state == IRPlayerStatePlaying) {
                self.pauseByEvent = YES;
            }
            if (self.isFullScreen && !self.isLockedScreen) self.orientationObserver.lockedScreen = YES;
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            if (!self.pauseWhenAppResignActive) {
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                [[AVAudioSession sharedInstance] setActive:YES error:nil];
            }
        };
        _notification.didBecomeActive = ^(IRPlayerControllerNotification * _Nonnull registrar) {
            @strongify(self)
            if (self.isViewControllerDisappear) return;
            if (self.isPauseByEvent) self.pauseByEvent = NO;
            if (self.isFullScreen && !self.isLockedScreen) self.orientationObserver.lockedScreen = NO;
        };
        _notification.oldDeviceUnavailable = ^(IRPlayerControllerNotification * _Nonnull registrar) {
            @strongify(self)
            if (self.currentPlayerManager.state == IRPlayerStatePlaying) {
                [self.currentPlayerManager play];
            }
        };
    }
    return _notification;
}

- (IRFloatView *)smallFloatView {
    if (!_smallFloatView) {
        _smallFloatView = [[IRFloatView alloc] init];
        _smallFloatView.parentView = [UIApplication sharedApplication].keyWindow;
        _smallFloatView.hidden = YES;
    }
    return _smallFloatView;
}

#pragma mark - setter

- (void)setCurrentPlayerManager:(id<IRPlayerMediaPlayback>)currentPlayerManager {
    if (!currentPlayerManager) return;
    if (_currentPlayerManager.state == IRPlayerStateReadyToPlay) {
        [_currentPlayerManager pause];
        [_currentPlayerManager.view removeFromSuperview];
        [self.orientationObserver removeDeviceOrientationObserver];
        [self.gestureControl removeGestureToView:self.currentPlayerManager.view];
    }
    _currentPlayerManager = currentPlayerManager;
    _currentPlayerManager.view.hidden = YES;
    self.gestureControl.disableTypes = self.disableGestureTypes;
    [self.gestureControl addGestureToView:currentPlayerManager.view];
    [self playerManagerCallbcak];
    [self.orientationObserver updateRotateView:currentPlayerManager.view containerView:self.containerView];
    self.controlView.player = self;
    [self layoutPlayerSubViews];
}

- (void)setContainerView:(UIView *)containerView {
    _containerView = containerView;
    if (self.scrollView) {
        self.scrollView.ir_containerView = containerView;
    }
    if (!containerView) return;
    containerView.userInteractionEnabled = YES;
    [self layoutPlayerSubViews];
}

- (void)setControlView:(UIView<IRPlayerMediaControl> *)controlView {
    _controlView = controlView;
    if (!controlView) return;
    controlView.player = self;
    [self layoutPlayerSubViews];
}

- (void)setContainerType:(IRPlayerContainerType)containerType {
    _containerType = containerType;
    if (self.scrollView) {
        self.scrollView.ir_containerType = containerType;
    }
}

@end

@implementation IRPlayerController (IRPlayerTimeControl)

- (NSTimeInterval)currentTime {
    return self.currentPlayerManager.progress;
}

- (NSTimeInterval)totalTime {
    return self.currentPlayerManager.duration;
}

- (NSTimeInterval)bufferTime {
    return self.currentPlayerManager.playableBufferInterval;
}

- (float)progress {
    if (self.totalTime == 0) return 0;
    return self.currentTime/self.totalTime;
}

- (float)bufferProgress {
    if (self.totalTime == 0) return 0;
    return self.bufferTime/self.totalTime;
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    [self.currentPlayerManager seekToTime:time completeHandler:completionHandler];
}

@end

@implementation IRPlayerController (IRPlayerPlaybackControl)

- (void)playTheNext {
    if (self.assetURLs.count > 0) {
        NSInteger index = self.currentPlayIndex + 1;
        if (index >= self.assetURLs.count) return;
        NSURL *assetURL = [self.assetURLs objectAtIndex:index];
        self.assetURL = assetURL;
        self.currentPlayIndex = [self.assetURLs indexOfObject:assetURL];
    }
}

- (void)playThePrevious {
    if (self.assetURLs.count > 0) {
        NSInteger index = self.currentPlayIndex - 1;
        if (index < 0) return;
        NSURL *assetURL = [self.assetURLs objectAtIndex:index];
        self.assetURL = assetURL;
        self.currentPlayIndex = [self.assetURLs indexOfObject:assetURL];
    }
}

- (void)playTheIndex:(NSInteger)index {
    if (self.assetURLs.count > 0) {
        if (index >= self.assetURLs.count) return;
        NSURL *assetURL = [self.assetURLs objectAtIndex:index];
        self.assetURL = assetURL;
        self.currentPlayIndex = index;
    }
}

- (void)stop {
    [self.notification removeNotification];
    [self.orientationObserver removeDeviceOrientationObserver];
    if (self.isFullScreen && self.exitFullScreenWhenStop) {
        [self.orientationObserver exitFullScreenWithAnimated:NO];
    }
    [self.currentPlayerManager pause];
    [self.currentPlayerManager.view removeFromSuperview];
    if (self.scrollView) {
        self.scrollView.ir_stopPlay = YES;
    }
}

- (void)replaceCurrentPlayerManager:(id<IRPlayerMediaPlayback>)playerManager {
    self.currentPlayerManager = playerManager;
}

//// Add video to the cell
- (void)addPlayerViewToCell {
    self.isSmallFloatViewShow = NO;
    self.smallFloatView.hidden = YES;
    UIView *cell = [self.scrollView ir_getCellForIndexPath:self.playingIndexPath];
    self.containerView = [cell viewWithTag:self.containerViewTag];
    [self.containerView addSubview:self.currentPlayerManager.view];
    self.currentPlayerManager.view.frame = self.containerView.bounds;
    self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver cellModelRotateView:self.currentPlayerManager.view rotateViewAtCell:cell playerViewTag:self.containerViewTag];
    if ([self.controlView respondsToSelector:@selector(videoPlayer:floatViewShow:)]) {
        [self.controlView videoPlayer:self floatViewShow:NO];
    }
}

//// Add video to the container view
- (void)addPlayerViewToContainerView:(UIView *)containerView {
    self.isSmallFloatViewShow = NO;
    self.smallFloatView.hidden = YES;
    self.containerView = containerView;
    [self.containerView addSubview:self.currentPlayerManager.view];
    self.currentPlayerManager.view.frame = self.containerView.bounds;
    self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver cellOtherModelRotateView:self.currentPlayerManager.view containerView:self.containerView];
    if ([self.controlView respondsToSelector:@selector(videoPlayer:floatViewShow:)]) {
        [self.controlView videoPlayer:self floatViewShow:NO];
    }
}

/// Add to the keyWindow
- (void)addPlayerViewToKeyWindow {
    self.isSmallFloatViewShow = YES;
    self.smallFloatView.hidden = NO;
    [self.smallFloatView addSubview:self.currentPlayerManager.view];
    self.currentPlayerManager.view.frame = self.smallFloatView.bounds;
    self.currentPlayerManager.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.orientationObserver cellOtherModelRotateView:self.currentPlayerManager.view containerView:self.smallFloatView];
    if ([self.controlView respondsToSelector:@selector(videoPlayer:floatViewShow:)]) {
        [self.controlView videoPlayer:self floatViewShow:YES];
    }
}

- (void)stopCurrentPlayingView {
    if (self.containerView) {
        [self stop];
        self.isSmallFloatViewShow = NO;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
    }
}

- (void)stopCurrentPlayingCell {
    if (self.scrollView.ir_playingIndexPath) {
        [self stop];
        self.isSmallFloatViewShow = NO;
        self.playingIndexPath = nil;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
    }
}

#pragma mark - getter

- (NSURL *)assetURL {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSArray<NSURL *> *)assetURLs {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isLastAssetURL {
    if (self.assetURLs.count > 0) {
        return self.assetURL == self.assetURLs.lastObject;
    }
    return NO;
}

- (BOOL)isFirstAssetURL {
    if (self.assetURLs.count > 0) {
        return self.assetURL == self.assetURLs.firstObject;
    }
    return NO;
}

- (BOOL)isPauseByEvent {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (float)brightness {
    return [UIScreen mainScreen].brightness;
}

- (float)volume {
    CGFloat volume = self.volumeViewSlider.value;
    if (volume == 0) {
        volume = [[AVAudioSession sharedInstance] outputVolume];
    }
    return volume;
}

- (BOOL)isMuted {
    return self.volume == 0;
}

- (float)lastVolumeValue {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (IRPlayerState)playState {
    return self.currentPlayerManager.state;
}

- (BOOL)isPlaying {
    return self.currentPlayerManager.state == IRPlayerStatePlaying;
}

- (BOOL)pauseWhenAppResignActive {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.pauseWhenAppResignActive = YES;
    return YES;
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerPrepareToPlay {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerReadyToPlay {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSTimeInterval, NSTimeInterval))playerPlayTimeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSTimeInterval))playerBufferTimeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, IRPlayerPlaybackState))playerPlayStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, IRPlayerLoadState))playerLoadStateChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull))playerDidToEnd {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, id _Nonnull))playerPlayFailed {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(id<IRPlayerMediaPlayback> _Nonnull, CGSize ))presentationSizeChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)currentPlayIndex {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)isViewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)customAudioSession {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setAssetURL:(NSURL *)assetURL {
    objc_setAssociatedObject(self, @selector(assetURL), assetURL, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    self.currentPlayerManager.assetURL = assetURL;
    [self.currentPlayerManager replaceVideoWithURL:assetURL];
}

- (void)setAssetURLs:(NSArray<NSURL *> * _Nullable)assetURLs {
    objc_setAssociatedObject(self, @selector(assetURLs), assetURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setVolume:(float)volume {
    volume = MIN(MAX(0, volume), 1);
    objc_setAssociatedObject(self, @selector(volume), @(volume), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.volumeViewSlider.value = volume;
}

- (void)setMuted:(BOOL)muted {
    if (muted) {
        if (self.volumeViewSlider.value > 0) {
            self.lastVolumeValue = self.volumeViewSlider.value;
        }
        self.volumeViewSlider.value = 0;
    } else {
        self.volumeViewSlider.value = self.lastVolumeValue;
    }
}

- (void)setLastVolumeValue:(float)lastVolumeValue {
    objc_setAssociatedObject(self, @selector(lastVolumeValue), @(lastVolumeValue), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setBrightness:(float)brightness {
    brightness = MIN(MAX(0, brightness), 1);
    objc_setAssociatedObject(self, @selector(brightness), @(brightness), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [UIScreen mainScreen].brightness = brightness;
}

- (void)setPauseByEvent:(BOOL)pauseByEvent {
    objc_setAssociatedObject(self, @selector(isPauseByEvent), @(pauseByEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (pauseByEvent) {
        [self.currentPlayerManager pause];
    } else {
        [self.currentPlayerManager play];
    }
}

- (void)setPauseWhenAppResignActive:(BOOL)pauseWhenAppResignActive {
    objc_setAssociatedObject(self, @selector(pauseWhenAppResignActive), @(pauseWhenAppResignActive), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerPrepareToPlay:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerPrepareToPlay {
    objc_setAssociatedObject(self, @selector(playerPrepareToPlay), playerPrepareToPlay, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerReadyToPlay:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSURL * _Nonnull))playerReadyToPlay {
    objc_setAssociatedObject(self, @selector(playerReadyToPlay), playerReadyToPlay, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerPlayTimeChanged:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSTimeInterval, NSTimeInterval))playerPlayTimeChanged {
    objc_setAssociatedObject(self, @selector(playerPlayTimeChanged), playerPlayTimeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerBufferTimeChanged:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, NSTimeInterval))playerBufferTimeChanged {
    objc_setAssociatedObject(self, @selector(playerBufferTimeChanged), playerBufferTimeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerPlayStateChanged:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, IRPlayerPlaybackState))playerPlayStateChanged {
    objc_setAssociatedObject(self, @selector(playerPlayStateChanged), playerPlayStateChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerLoadStateChanged:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, IRPlayerLoadState))playerLoadStateChanged {
    objc_setAssociatedObject(self, @selector(playerLoadStateChanged), playerLoadStateChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerDidToEnd:(void (^)(id<IRPlayerMediaPlayback> _Nonnull))playerDidToEnd {
    objc_setAssociatedObject(self, @selector(playerDidToEnd), playerDidToEnd, OBJC_ASSOCIATION_COPY);
}

- (void)setPlayerPlayFailed:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, id _Nonnull))playerPlayFailed {
    objc_setAssociatedObject(self, @selector(playerPlayFailed), playerPlayFailed, OBJC_ASSOCIATION_COPY);
}

- (void)setPresentationSizeChanged:(void (^)(id<IRPlayerMediaPlayback> _Nonnull, CGSize))presentationSizeChanged {
    objc_setAssociatedObject(self, @selector(presentationSizeChanged), presentationSizeChanged, OBJC_ASSOCIATION_COPY);
}

- (void)setCurrentPlayIndex:(NSInteger)currentPlayIndex {
    objc_setAssociatedObject(self, @selector(currentPlayIndex), @(currentPlayIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setViewControllerDisappear:(BOOL)viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(isViewControllerDisappear), @(viewControllerDisappear), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.scrollView) self.scrollView.ir_viewControllerDisappear = viewControllerDisappear;
    if (!(self.currentPlayerManager.state == IRPlayerStateReadyToPlay)) return;
    if (viewControllerDisappear) {
        [self removeDeviceOrientationObserver];
        if (self.currentPlayerManager.state == IRPlayerStatePlaying) self.pauseByEvent = YES;
    } else {
        if (self.isPauseByEvent) self.pauseByEvent = NO;
        [self addDeviceOrientationObserver];
    }
}

- (void)setCustomAudioSession:(BOOL)customAudioSession {
    objc_setAssociatedObject(self, @selector(customAudioSession), @(customAudioSession), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation IRPlayerController (IRPlayerOrientationRotation)

- (void)addDeviceOrientationObserver {
    [self.orientationObserver addDeviceOrientationObserver];
}

- (void)removeDeviceOrientationObserver {
    [self.orientationObserver removeDeviceOrientationObserver];
}

- (void)enterLandscapeFullScreen:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    self.orientationObserver.fullScreenMode = IRFullScreenModeLandscape;
    [self.orientationObserver enterLandscapeFullScreen:orientation animated:animated];
}

- (void)enterPortraitFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    self.orientationObserver.fullScreenMode = IRFullScreenModePortrait;
    [self.orientationObserver enterPortraitFullScreen:fullScreen animated:animated];
}

- (void)enterFullScreen:(BOOL)fullScreen animated:(BOOL)animated {
    if (self.orientationObserver.fullScreenMode == IRFullScreenModePortrait) {
        [self.orientationObserver enterPortraitFullScreen:fullScreen animated:animated];
    } else {
        UIInterfaceOrientation orientation = UIInterfaceOrientationUnknown;
        orientation = fullScreen? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
        [self.orientationObserver enterLandscapeFullScreen:orientation animated:animated];
    }
}

- (BOOL)shouldForceDeviceOrientation {
    if (self.forceDeviceOrientation) return YES;
    return NO;
}

#pragma mark - getter

- (IROrientationObserver *)orientationObserver {
    @weakify(self)
    IROrientationObserver *orientationObserver = objc_getAssociatedObject(self, _cmd);
    if (!orientationObserver) {
        orientationObserver = [[IROrientationObserver alloc] init];
        orientationObserver.orientationWillChange = ^(IROrientationObserver * _Nonnull observer, BOOL isFullScreen) {
            @strongify(self)
            if (self.orientationWillChange) self.orientationWillChange(self, isFullScreen);
            if ([self.controlView respondsToSelector:@selector(videoPlayer:orientationWillChange:)]) {
                [self.controlView videoPlayer:self orientationWillChange:observer];
            }
            [self.controlView setNeedsLayout];
            [self.controlView layoutIfNeeded];
        };
        orientationObserver.orientationDidChanged = ^(IROrientationObserver * _Nonnull observer, BOOL isFullScreen) {
            @strongify(self)
            if (self.orientationDidChanged) self.orientationDidChanged(self, isFullScreen);
            if ([self.controlView respondsToSelector:@selector(videoPlayer:orientationDidChanged:)]) {
                [self.controlView videoPlayer:self orientationDidChanged:observer];
            }
        };
        objc_setAssociatedObject(self, _cmd, orientationObserver, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return orientationObserver;
}

- (void (^)(IRPlayerController * _Nonnull, BOOL))orientationWillChange {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(IRPlayerController * _Nonnull, BOOL))orientationDidChanged {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)isFullScreen {
    return self.orientationObserver.isFullScreen;
}

- (BOOL)exitFullScreenWhenStop {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.exitFullScreenWhenStop = YES;
    return YES;
}

- (UIInterfaceOrientation)currentOrientation {
    return self.orientationObserver.currentOrientation;
}

- (BOOL)isStatusBarHidden {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)isLockedScreen {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)shouldAutorotate {
    return [self shouldForceDeviceOrientation];
}

- (BOOL)allowOrentitaionRotation {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.allowOrentitaionRotation = YES;
    return YES;
}

- (BOOL)forceDeviceOrientation {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setOrientationWillChange:(void (^)(IRPlayerController * _Nonnull, BOOL))orientationWillChange {
    objc_setAssociatedObject(self, @selector(orientationWillChange), orientationWillChange, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setOrientationDidChanged:(void (^)(IRPlayerController * _Nonnull, BOOL))orientationDidChanged {
    objc_setAssociatedObject(self, @selector(orientationDidChanged), orientationDidChanged, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    objc_setAssociatedObject(self, @selector(isStatusBarHidden), @(statusBarHidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.statusBarHidden = statusBarHidden;
}

- (void)setLockedScreen:(BOOL)lockedScreen {
    objc_setAssociatedObject(self, @selector(isLockedScreen), @(lockedScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.lockedScreen = lockedScreen;
    if ([self.controlView respondsToSelector:@selector(lockedVideoPlayer:lockedScreen:)]) {
        [self.controlView lockedVideoPlayer:self lockedScreen:lockedScreen];
    }
}

- (void)setAllowOrentitaionRotation:(BOOL)allowOrentitaionRotation {
    objc_setAssociatedObject(self, @selector(allowOrentitaionRotation), @(allowOrentitaionRotation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.allowOrentitaionRotation = allowOrentitaionRotation;
}

- (void)setForceDeviceOrientation:(BOOL)forceDeviceOrientation {
    objc_setAssociatedObject(self, @selector(forceDeviceOrientation), @(forceDeviceOrientation), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.orientationObserver.forceDeviceOrientation = forceDeviceOrientation;
}

- (void)setExitFullScreenWhenStop:(BOOL)exitFullScreenWhenStop {
    objc_setAssociatedObject(self, @selector(exitFullScreenWhenStop), @(exitFullScreenWhenStop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end


@implementation IRPlayerController (IRPlayerViewGesture)

#pragma mark - getter

- (IRGestureController *)gestureControl {
    IRGestureController *gestureControl = objc_getAssociatedObject(self, _cmd);
    if (!gestureControl) {
        gestureControl = [[IRGestureController alloc] init];
        @weakify(self)
        gestureControl.triggerCondition = ^BOOL(IRGestureController * _Nonnull control, IRGestureType type, UIGestureRecognizer * _Nonnull gesture, UITouch *touch) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureTriggerCondition:gestureType:gestureRecognizer:touch:)]) {
                return [self.controlView gestureTriggerCondition:control gestureType:type gestureRecognizer:gesture touch:touch];
            }
            return YES;
        };
        
        gestureControl.singleTapped = ^(IRGestureController * _Nonnull control) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureSingleTapped:)]) {
                [self.controlView gestureSingleTapped:control];
            }
        };
        
        gestureControl.doubleTapped = ^(IRGestureController * _Nonnull control) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureDoubleTapped:)]) {
                [self.controlView gestureDoubleTapped:control];
            }
        };
        
        gestureControl.beganPan = ^(IRGestureController * _Nonnull control, IRPanDirection direction, IRPanLocation location) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureBeganPan:panDirection:panLocation:)]) {
                [self.controlView gestureBeganPan:control panDirection:direction panLocation:location];
            }
        };
        
        gestureControl.changedPan = ^(IRGestureController * _Nonnull control, IRPanDirection direction, IRPanLocation location, CGPoint velocity) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureChangedPan:panDirection:panLocation:withVelocity:)]) {
                [self.controlView gestureChangedPan:control panDirection:direction panLocation:location withVelocity:velocity];
            }
        };
        
        gestureControl.endedPan = ^(IRGestureController * _Nonnull control, IRPanDirection direction, IRPanLocation location) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gestureEndedPan:panDirection:panLocation:)]) {
                [self.controlView gestureEndedPan:control panDirection:direction panLocation:location];
            }
        };
        
        gestureControl.pinched = ^(IRGestureController * _Nonnull control, float scale) {
            @strongify(self)
            if ([self.controlView respondsToSelector:@selector(gesturePinched:scale:)]) {
                [self.controlView gesturePinched:control scale:scale];
            }
        };
        objc_setAssociatedObject(self, _cmd, gestureControl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return gestureControl;
}

- (IRDisableGestureTypes)disableGestureTypes {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (IRDisablePanMovingDirection)disablePanMovingDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

#pragma mark - setter

- (void)setDisableGestureTypes:(IRDisableGestureTypes)disableGestureTypes {
    objc_setAssociatedObject(self, @selector(disableGestureTypes), @(disableGestureTypes), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.gestureControl.disableTypes = disableGestureTypes;
}

- (void)setDisablePanMovingDirection:(IRDisablePanMovingDirection)disablePanMovingDirection {
    objc_setAssociatedObject(self, @selector(disablePanMovingDirection), @(disablePanMovingDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.gestureControl.disablePanMovingDirection = disablePanMovingDirection;
}

@end

@implementation IRPlayerController (IRPlayerScrollView)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        SEL selectors[] = {
            NSSelectorFromString(@"dealloc")
        };
        
        for (NSInteger index = 0; index < sizeof(selectors) / sizeof(SEL); ++index) {
            SEL originalSelector = selectors[index];
            SEL swizzledSelector = NSSelectorFromString([@"ir_" stringByAppendingString:NSStringFromSelector(originalSelector)]);
            Method originalMethod = class_getInstanceMethod(self, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(self, swizzledSelector);
            if (class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        }
    });
}

- (void)ir_dealloc {
    [self.smallFloatView removeFromSuperview];
    self.smallFloatView = nil;
    [self ir_dealloc];
}

#pragma mark - setter

- (void)setScrollView:(UIScrollView *)scrollView {
    objc_setAssociatedObject(self, @selector(scrollView), scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.ir_WWANAutoPlay = self.isWWANAutoPlay;
    @weakify(self)
    scrollView.ir_playerWillAppearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.ir_playerWillAppearInScrollView) self.ir_playerWillAppearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerDidAppearInScrollView:)]) {
            [self.controlView playerDidAppearInScrollView:self];
        }
    };
    
    scrollView.ir_playerDidAppearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.ir_playerDidAppearInScrollView) self.ir_playerDidAppearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerDidAppearInScrollView:)]) {
            [self.controlView playerDidAppearInScrollView:self];
        }
    };
    
    scrollView.ir_playerWillDisappearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.ir_playerWillDisappearInScrollView) self.ir_playerWillDisappearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerWillDisappearInScrollView:)]) {
            [self.controlView playerWillDisappearInScrollView:self];
        }
    };
    
    scrollView.ir_playerDidDisappearInScrollView = ^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(indexPath);
        if ([self.controlView respondsToSelector:@selector(playerDidDisappearInScrollView:)]) {
            [self.controlView playerDidDisappearInScrollView:self];
        }
    };
    
    scrollView.ir_playerAppearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerApperaPercent) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.ir_playerAppearingInScrollView) self.ir_playerAppearingInScrollView(indexPath, playerApperaPercent);
        if ([self.controlView respondsToSelector:@selector(playerAppearingInScrollView:playerApperaPercent:)]) {
            [self.controlView playerAppearingInScrollView:self playerApperaPercent:playerApperaPercent];
        }
        if (!self.stopWhileNotVisible && playerApperaPercent >= self.playerApperaPercent) {
            if (self.containerType == IRPlayerContainerTypeView) {
                [self addPlayerViewToContainerView:self.containerView];
            } else if (self.containerType == IRPlayerContainerTypeCell) {
                [self addPlayerViewToCell];
            }
        }
    };
    
    scrollView.ir_playerDisappearingInScrollView = ^(NSIndexPath * _Nonnull indexPath, CGFloat playerDisapperaPercent) {
        @strongify(self)
        if (self.isFullScreen) return;
        if (self.ir_playerDisappearingInScrollView) self.ir_playerDisappearingInScrollView(indexPath, playerDisapperaPercent);
        if ([self.controlView respondsToSelector:@selector(playerDisappearingInScrollView:playerDisapperaPercent:)]) {
            [self.controlView playerDisappearingInScrollView:self playerDisapperaPercent:playerDisapperaPercent];
        }
        /// stop playing
        if (self.stopWhileNotVisible && playerDisapperaPercent >= self.playerDisapperaPercent) {
            if (self.containerType == IRPlayerContainerTypeView) {
                [self stopCurrentPlayingView];
            } else if (self.containerType == IRPlayerContainerTypeCell) {
                [self stopCurrentPlayingCell];
            }
        }
        /// add to window
        if (!self.stopWhileNotVisible && playerDisapperaPercent >= self.playerDisapperaPercent) [self addPlayerViewToKeyWindow];
    };
}

- (void)setWWANAutoPlay:(BOOL)WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(isWWANAutoPlay), @(WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (self.scrollView) self.scrollView.ir_WWANAutoPlay = self.isWWANAutoPlay;
}

- (void)setStopWhileNotVisible:(BOOL)stopWhileNotVisible {
    self.scrollView.ir_stopWhileNotVisible = stopWhileNotVisible;
    objc_setAssociatedObject(self, @selector(stopWhileNotVisible), @(stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setContainerViewTag:(NSInteger)containerViewTag {
    objc_setAssociatedObject(self, @selector(containerViewTag), @(containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.ir_containerViewTag = containerViewTag;
}

- (void)setPlayingIndexPath:(NSIndexPath *)playingIndexPath {
    objc_setAssociatedObject(self, @selector(playingIndexPath), playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (playingIndexPath) {
        // Stop the current playing cell video.
        [self stop];
        self.isSmallFloatViewShow = NO;
        if (self.smallFloatView) self.smallFloatView.hidden = YES;
        
        UIView *cell = [self.scrollView ir_getCellForIndexPath:playingIndexPath];
        self.containerView = [cell viewWithTag:self.containerViewTag];
        [self.orientationObserver cellModelRotateView:self.currentPlayerManager.view rotateViewAtCell:cell playerViewTag:self.containerViewTag];
        [self addDeviceOrientationObserver];
        self.scrollView.ir_playingIndexPath = playingIndexPath;
        [self layoutPlayerSubViews];
    } else {
        self.scrollView.ir_playingIndexPath = playingIndexPath;
    }
}

- (void)setShouldAutoPlay:(BOOL)shouldAutoPlay {
    objc_setAssociatedObject(self, @selector(shouldAutoPlay), @(shouldAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.scrollView.ir_shouldAutoPlay = shouldAutoPlay;
}

- (void)setSectionAssetURLs:(NSArray<NSArray<NSURL *> *> * _Nullable)sectionAssetURLs {
    objc_setAssociatedObject(self, @selector(sectionAssetURLs), sectionAssetURLs, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerDisapperaPercent:(CGFloat)playerDisapperaPercent {
    playerDisapperaPercent = MIN(MAX(0.0, playerDisapperaPercent), 1.0);
    self.scrollView.ir_playerDisapperaPercent = playerDisapperaPercent;
    objc_setAssociatedObject(self, @selector(playerDisapperaPercent), @(playerDisapperaPercent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setPlayerApperaPercent:(CGFloat)playerApperaPercent {
    playerApperaPercent = MIN(MAX(0.0, playerApperaPercent), 1.0);
    self.scrollView.ir_playerApperaPercent = playerApperaPercent;
    objc_setAssociatedObject(self, @selector(playerApperaPercent), @(playerApperaPercent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_playerAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerAppearingInScrollView), ir_playerAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerDisappearingInScrollView), ir_playerDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerDidAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))ir_playerDidAppearInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerDidAppearInScrollView), ir_playerDidAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerWillDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))ir_playerWillDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerWillDisappearInScrollView), ir_playerWillDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerWillAppearInScrollView:(void (^)(NSIndexPath * _Nonnull))ir_playerWillAppearInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerWillAppearInScrollView), ir_playerWillAppearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerDidDisappearInScrollView:(void (^)(NSIndexPath * _Nonnull))ir_playerDidDisappearInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerDidDisappearInScrollView), ir_playerDidDisappearInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - getter

- (UIScrollView *)scrollView {
    UIScrollView *scrollView = objc_getAssociatedObject(self, _cmd);
    return scrollView;
}

- (BOOL)isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)stopWhileNotVisible {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.stopWhileNotVisible = YES;
    return YES;
}

- (NSInteger)containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (NSIndexPath *)playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSArray<NSArray<NSURL *> *> *)sectionAssetURLs {
    return objc_getAssociatedObject(self, _cmd);
}

- (BOOL)shouldAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (CGFloat)playerDisapperaPercent {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.floatValue;
    self.playerDisapperaPercent = 0.5;
    return 0.5;
}

- (CGFloat)playerApperaPercent {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.floatValue;
    self.playerApperaPercent = 0.0;
    return 0.0;
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerAppearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))ir_playerDidAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))ir_playerWillDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))ir_playerWillAppearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))ir_playerDidDisappearInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - Public method

- (void)playTheIndexPath:(NSIndexPath *)indexPath {
    self.playingIndexPath = indexPath;
    NSURL *assetURL;
    if (self.sectionAssetURLs.count) {
        assetURL = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetURL = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    self.assetURL = assetURL;
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop completionHandler:(void (^ _Nullable)(void))completionHandler {
    NSURL *assetURL;
    if (self.sectionAssetURLs.count) {
        assetURL = self.sectionAssetURLs[indexPath.section][indexPath.row];
    } else if (self.assetURLs.count) {
        assetURL = self.assetURLs[indexPath.row];
        self.currentPlayIndex = indexPath.row;
    }
    if (scrollToTop) {
        @weakify(self)
        [self.scrollView ir_scrollToRowAtIndexPath:indexPath completionHandler:^{
            @strongify(self)
            if (completionHandler) completionHandler();
            self.playingIndexPath = indexPath;
            self.assetURL = assetURL;
        }];
    } else {
        if (completionHandler) completionHandler();
        self.playingIndexPath = indexPath;
        self.assetURL = assetURL;
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    if ([indexPath compare:self.playingIndexPath] == NSOrderedSame) return;
    if (scrollToTop) {
        @weakify(self)
        [self.scrollView ir_scrollToRowAtIndexPath:indexPath completionHandler:^{
            @strongify(self)
            [self playTheIndexPath:indexPath];
        }];
    } else {
        [self playTheIndexPath:indexPath];
    }
}

- (void)playTheIndexPath:(NSIndexPath *)indexPath assetURL:(NSURL *)assetURL scrollToTop:(BOOL)scrollToTop {
    self.playingIndexPath = indexPath;
    self.assetURL = assetURL;
    if (scrollToTop) {
        [self.scrollView ir_scrollToRowAtIndexPath:indexPath completionHandler:nil];
    }
}

@end

@implementation IRPlayerController (IRPlayerDeprecated)

- (void)updateScrollViewPlayerToCell {
    if (self.currentPlayerManager.view && self.playingIndexPath && self.containerViewTag) {
        UIView *cell = [self.scrollView ir_getCellForIndexPath:self.playingIndexPath];
        self.containerView = [cell viewWithTag:self.containerViewTag];
        [self.orientationObserver cellModelRotateView:self.currentPlayerManager.view rotateViewAtCell:cell playerViewTag:self.containerViewTag];
        [self layoutPlayerSubViews];
    }
}

- (void)updateNoramlPlayerWithContainerView:(UIView *)containerView {
    if (self.currentPlayerManager.view && self.containerView) {
        self.containerView = containerView;
        [self.orientationObserver cellOtherModelRotateView:self.currentPlayerManager.view containerView:self.containerView];
        [self layoutPlayerSubViews];
    }
}

@end
