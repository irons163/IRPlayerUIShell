//
//  IRPlayerControlView.m
//  IRPlayerUIShell
//
//  Created by irons on 2020/1/18.
//  Copyright © 2020年 irons. All rights reserved.
//
//
//  ZFPlayerControlView.m
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

#import "IRPlayerControlView.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "IRPortraitControlView.h"
#import "IRLandScapeControlView.h"
#import "IRSpeedLoadingView.h"
#import "IRSmallFloatControlView.h"
#import "IRVolumeBrightnessView.h"
#import "UIView+IRFrame.h"
#import "IRSliderView.h"
#import "IRUtilities.h"
#import "IRScope.h"
#import "UIImageView+IRCache.h"
#import <MediaPlayer/MediaPlayer.h>

@interface IRPlayerControlView () <IRSliderViewDelegate>

@property (nonatomic, strong) IRPortraitControlView *portraitControlView;

@property (nonatomic, strong) IRLandScapeControlView *landScapeControlView;
/// Loading view
@property (nonatomic, strong) IRSpeedLoadingView *activity;

@property (nonatomic, strong) UIView *fastView;

@property (nonatomic, strong) IRSliderView *fastProgressView;

@property (nonatomic, strong) UILabel *fastTimeLabel;

@property (nonatomic, strong) UIImageView *fastImageView;
/// Button for loading video fail
@property (nonatomic, strong) UIButton *failBtn;
///  Progress bar in the bottom
@property (nonatomic, strong) IRSliderView *bottomPgrogress;

@property (nonatomic, strong) UIImageView *coverImageView;

@property (nonatomic, assign, getter=isShowing) BOOL showing;
///  Is play to end
@property (nonatomic, assign, getter=isPlayEnd) BOOL playeEnd;

@property (nonatomic, assign) BOOL controlViewAppeared;

@property (nonatomic, assign) NSTimeInterval sumTime;

@property (nonatomic, strong) dispatch_block_t afterBlock;

@property (nonatomic, strong) IRSmallFloatControlView *floatControlView;

@property (nonatomic, strong) IRVolumeBrightnessView *volumeBrightnessView;

@property (nonatomic, strong) UIImageView *bgImgView;

@property (nonatomic, strong) UIView *effectView;

@end

@implementation IRPlayerControlView
@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addAllSubViews];
        self.landScapeControlView.hidden = YES;
        self.floatControlView.hidden = YES;
        self.seekToPlay = YES;
        self.effectViewShow = YES;
        self.horizontalPanShowControlView = YES;
        self.autoFadeTimeInterval = 0.25;
        self.autoHiddenTimeInterval = 2.5;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(volumeChanged:)
                                                     name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat min_x = 0;
    CGFloat min_y = 0;
    CGFloat min_w = 0;
    CGFloat min_h = 0;
    CGFloat min_view_w = self.ir_width;
    CGFloat min_view_h = self.ir_height;
    
    self.portraitControlView.frame = self.bounds;
    self.landScapeControlView.frame = self.bounds;
    self.floatControlView.frame = self.bounds;
    self.coverImageView.frame = self.bounds;
    self.bgImgView.frame = self.bounds;
    self.effectView.frame = self.bounds;
    
    min_w = 80;
    min_h = 80;
    self.activity.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.activity.ir_centerX = self.ir_centerX;
    self.activity.ir_centerY = self.ir_centerY + 10;
    
    min_w = 150;
    min_h = 30;
    self.failBtn.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.failBtn.center = self.center;
    
    min_w = 140;
    min_h = 80;
    self.fastView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.fastView.center = self.center;
    
    min_w = 32;
    min_x = (self.fastView.ir_width - min_w) / 2;
    min_y = 5;
    min_h = 32;
    self.fastImageView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = self.fastImageView.ir_bottom + 2;
    min_w = self.fastView.ir_width;
    min_h = 20;
    self.fastTimeLabel.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 12;
    min_y = self.fastTimeLabel.ir_bottom + 5;
    min_w = self.fastView.ir_width - 2 * min_x;
    min_h = 10;
    self.fastProgressView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = min_view_h - 1;
    min_w = min_view_w;
    min_h = 1;
    self.bottomPgrogress.frame = CGRectMake(min_x, min_y, min_w, min_h);
    
    min_x = 0;
    min_y = iPhoneX ? 54 : 30;
    min_w = 170;
    min_h = 35;
    self.volumeBrightnessView.frame = CGRectMake(min_x, min_y, min_w, min_h);
    self.volumeBrightnessView.ir_centerX = self.ir_centerX;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self cancelAutoFadeOutControlView];
}

- (void)addAllSubViews {
    [self addSubview:self.portraitControlView];
    [self addSubview:self.landScapeControlView];
    [self addSubview:self.floatControlView];
    [self addSubview:self.activity];
    [self addSubview:self.failBtn];
    [self addSubview:self.fastView];
    [self.fastView addSubview:self.fastImageView];
    [self.fastView addSubview:self.fastTimeLabel];
    [self.fastView addSubview:self.fastProgressView];
    [self addSubview:self.bottomPgrogress];
    [self addSubview:self.volumeBrightnessView];
}

- (void)autoFadeOutControlView {
    self.controlViewAppeared = YES;
    [self cancelAutoFadeOutControlView];
    @weakify(self)
    self.afterBlock = dispatch_block_create(0, ^{
        @strongify(self)
        [self hideControlViewWithAnimated:YES];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.autoHiddenTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(),self.afterBlock);
}

- (void)cancelAutoFadeOutControlView {
    if (self.afterBlock) {
        dispatch_block_cancel(self.afterBlock);
        self.afterBlock = nil;
    }
}

- (void)hideControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = NO;
    if (self.controlViewAppearedCallback) {
        self.controlViewAppearedCallback(NO);
    }
    [UIView animateWithDuration:animated ? self.autoFadeTimeInterval : 0 animations:^{
        if (self.player.isFullScreen) {
            [self.landScapeControlView hideControlView];
        } else {
            if (!self.player.isSmallFloatViewShow) {
                [self.portraitControlView hideControlView];
            }
        }
    } completion:^(BOOL finished) {
        self.bottomPgrogress.hidden = NO;
    }];
}

- (void)showControlViewWithAnimated:(BOOL)animated {
    self.controlViewAppeared = YES;
    if (self.controlViewAppearedCallback) {
        self.controlViewAppearedCallback(YES);
    }
    [self autoFadeOutControlView];
    [UIView animateWithDuration:animated ? self.autoFadeTimeInterval : 0 animations:^{
        if (self.player.isFullScreen) {
            [self.landScapeControlView showControlView];
        } else {
            if (!self.player.isSmallFloatViewShow) {
                [self.portraitControlView showControlView];
            }
        }
    } completion:^(BOOL finished) {
        self.bottomPgrogress.hidden = YES;
    }];
}

- (void)volumeChanged:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    NSString *reasonstr = userInfo[@"AVSystemController_AudioVolumeChangeReasonNotificationParameter"];
    if ([reasonstr isEqualToString:@"ExplicitVolumeChange"]) {
        float volume = [ userInfo[@"AVSystemController_AudioVolumeNotificationParameter"] floatValue];
        if (self.player.isFullScreen) {
            [self.volumeBrightnessView updateProgress:volume withVolumeBrightnessType:IRVolumeBrightnessTypeVolume];
        } else {
            [self.volumeBrightnessView addSystemVolumeView];
        }
    }
}

#pragma mark - Public Method

- (void)resetControlView {
    [self.portraitControlView resetControlView];
    [self.landScapeControlView resetControlView];
    [self cancelAutoFadeOutControlView];
    self.bottomPgrogress.value = 0;
    self.bottomPgrogress.bufferValue = 0;
    self.floatControlView.hidden = YES;
    self.failBtn.hidden = YES;
    self.volumeBrightnessView.hidden = YES;
    self.portraitControlView.hidden = self.player.isFullScreen;
    self.landScapeControlView.hidden = !self.player.isFullScreen;
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fullScreenMode:(IRFullScreenMode)fullScreenMode {
    UIImage *placeholder = [IRUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:self.bgImgView.bounds.size];
    [self showTitle:title coverURLString:coverUrl placeholderImage:placeholder fullScreenMode:fullScreenMode];
}

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fullScreenMode:(IRFullScreenMode)fullScreenMode {
    [self resetControlView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.landScapeControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.coverImageView setImageWithURLString:coverUrl placeholder:placeholder];
    [self.bgImgView setImageWithURLString:coverUrl placeholder:placeholder];
    if (self.prepareShowControlView) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fullScreenMode:(IRFullScreenMode)fullScreenMode {
    [self resetControlView];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
    [self.portraitControlView showTitle:title fullScreenMode:fullScreenMode];
    [self.landScapeControlView showTitle:title fullScreenMode:fullScreenMode];
    self.coverImageView.image = image;
    self.bgImgView.image = image;
    if (self.prepareShowControlView) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

#pragma mark - IRPlayerControlViewDelegate

/// Gesture filter, if return NO, then not respond for this gesture
- (BOOL)gestureTriggerCondition:(IRGestureController *)gestureControl gestureType:(IRGestureType)gestureType gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer touch:(nonnull UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen && gestureType != IRGestureTypeSingleTap) {
        return NO;
    }
    if (self.player.isFullScreen) {
        if (!self.customDisablePanMovingDirection) {
            /// Allow pan gestures.
            self.player.disablePanMovingDirection = IRDisablePanMovingDirectionNone;
        }
        return [self.landScapeControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    } else {
        if (!self.customDisablePanMovingDirection) {
            if (self.player.scrollView) {  /// Avoid conflict with the gestures of scrollView itself
                self.player.disablePanMovingDirection = IRDisablePanMovingDirectionVertical;
            } else { /// Allow pan gestures.
                self.player.disablePanMovingDirection = IRDisablePanMovingDirectionNone;
            }
        }
        return [self.portraitControlView shouldResponseGestureWithPoint:point withGestureType:gestureType touch:touch];
    }
}

- (void)gestureSingleTapped:(IRGestureController *)gestureControl {
    if (!self.player) return;
    if (self.player.isSmallFloatViewShow && !self.player.isFullScreen) {
        [self.player enterFullScreen:YES animated:YES];
    } else {
        if (self.controlViewAppeared) {
            [self hideControlViewWithAnimated:YES];
        } else {
            [self hideControlViewWithAnimated:NO];
            [self showControlViewWithAnimated:YES];
        }
    }
}

- (void)gestureDoubleTapped:(IRGestureController *)gestureControl {
    if (self.player.isFullScreen) {
        [self.landScapeControlView playOrPause];
    } else {
        [self.portraitControlView playOrPause];
    }
}

- (void)gestureBeganPan:(IRGestureController *)gestureControl panDirection:(IRPanDirection)direction panLocation:(IRPanLocation)location {
    if (direction == IRPanDirectionH) {
        self.sumTime = self.player.currentTime;
    }
}

- (void)gestureChangedPan:(IRGestureController *)gestureControl panDirection:(IRPanDirection)direction panLocation:(IRPanLocation)location withVelocity:(CGPoint)velocity {
    if (direction == IRPanDirectionH) {
        self.sumTime += velocity.x / 200;
        NSTimeInterval totalMovieDuration = self.player.totalTime;
        if (totalMovieDuration == 0) return;
        if (self.sumTime > totalMovieDuration) self.sumTime = totalMovieDuration;
        if (self.sumTime < 0) self.sumTime = 0;
        BOOL style = NO;
        if (velocity.x > 0) style = YES;
        if (velocity.x < 0) style = NO;
        if (velocity.x == 0) return;
        [self sliderValueChangingValue:self.sumTime/totalMovieDuration isForward:style];
    } else if (direction == IRPanDirectionV) {
        if (location == IRPanLocationLeft) { /// Control brightness
            self.player.brightness -= (velocity.y) / 10000;
            [self.volumeBrightnessView updateProgress:self.player.brightness withVolumeBrightnessType:IRVolumeBrightnessTypeumeBrightness];
        } else if (location == IRPanLocationRight) { /// Control volume
            self.player.volume -= (velocity.y) / 10000;
            if (self.player.isFullScreen) {
                [self.volumeBrightnessView updateProgress:self.player.volume withVolumeBrightnessType:IRVolumeBrightnessTypeVolume];
            }
        }
    }
}

- (void)gestureEndedPan:(IRGestureController *)gestureControl panDirection:(IRPanDirection)direction panLocation:(IRPanLocation)location {
    @weakify(self)
    if (direction == IRPanDirectionH && self.sumTime >= 0 && self.player.totalTime > 0) {
        [self.player seekToTime:self.sumTime completionHandler:^(BOOL finished) {
            @strongify(self)
            /// Control video progress
            [self.portraitControlView sliderChangeEnded];
            [self.landScapeControlView sliderChangeEnded];
            if (self.controlViewAppeared) {
                [self autoFadeOutControlView];
            }
        }];
        if (self.seekToPlay) {
            [self.player.currentPlayerManager play];
        }
        self.sumTime = 0;
    }
}

- (void)gesturePinched:(IRGestureController *)gestureControl scale:(float)scale {
    if (scale > 1) {
//        self.player.currentPlayerManager.viewGravityMode = IRPlayerScalingModeAspectFill;
        self.player.currentPlayerManager.scalingMode = IRPlayerScalingModeAspectFill;
    } else {
//        self.player.currentPlayerManager.viewGravityMode = IRPlayerScalingModeAspectFit;
        self.player.currentPlayerManager.scalingMode = IRPlayerScalingModeAspectFit;
    }
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL {
    [self hideControlViewWithAnimated:NO];
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer playStateChanged:(IRPlayerPlaybackState)state {
    if (state == IRPlayerPlayStatePlaying) {
        [self.portraitControlView playBtnSelectedState:YES];
        [self.landScapeControlView playBtnSelectedState:YES];
        self.failBtn.hidden = YES;
        /// Check for show loading view or not.
//        if (videoPlayer.currentPlayerManager.state == IRPlayerStatePlaying && !self.prepareShowLoading) {
//            [self.activity startAnimating];
//        } else if ((videoPlayer.currentPlayerManager.state == IRPlayerStatePlaying || videoPlayer.currentPlayerManager.state == IRPlayerStateReadyToPlay) && self.prepareShowLoading) {
//            [self.activity startAnimating];
//        }
        if (videoPlayer.currentPlayerManager.playState == IRPlayerPlayStatePlaying && !self.prepareShowLoading) {
            [self.activity startAnimating];
        } else if ((videoPlayer.currentPlayerManager.playState == IRPlayerPlayStatePlaying || videoPlayer.currentPlayerManager.loadState == IRPlayerLoadStatePlayable) && self.prepareShowLoading) {
            [self.activity startAnimating];
        }
    } else if (state == IRPlayerPlayStatePaused) {
        [self.portraitControlView playBtnSelectedState:NO];
        [self.landScapeControlView playBtnSelectedState:NO];
        /// Hide loading view
        [self.activity stopAnimating];
        self.failBtn.hidden = YES;
    } else if (state == IRPlayerPlayStatePlayFailed) {
        self.failBtn.hidden = NO;
        [self.activity stopAnimating];
    }
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer loadStateChanged:(IRPlayerLoadState)state {
    if (state == IRPlayerLoadStatePrepare) {
        self.coverImageView.hidden = NO;
//        [self.portraitControlView playBtnSelectedState:videoPlayer.currentPlayerManager.shouldAutoPlay];
//        [self.landScapeControlView playBtnSelectedState:videoPlayer.currentPlayerManager.shouldAutoPlay];
        [self.portraitControlView playBtnSelectedState:YES];
        [self.landScapeControlView playBtnSelectedState:YES];
    } else if (state == IRPlayerLoadStatePlaythroughOK || state == IRPlayerLoadStatePlayable) {
        self.coverImageView.hidden = YES;
        if (self.effectViewShow) {
            self.effectView.hidden = NO;
        } else {
            self.effectView.hidden = YES;
            self.player.currentPlayerManager.view.backgroundColor = [UIColor blackColor];
        }
    }
//    if (state == IRPlayerLoadStateStalled && videoPlayer.currentPlayerManager.state == IRPlayerStateBuffering && !self.prepareShowLoading) {
//        [self.activity startAnimating];
//    } else if ((state == IRPlayerLoadStateStalled || state == IRPlayerLoadStatePrepare) && videoPlayer.currentPlayerManager.state == IRPlayerStateBuffering && self.prepareShowLoading) {
//        [self.activity startAnimating];
//    } else {
//        [self.activity stopAnimating];
//    }
    if (state == IRPlayerLoadStateStalled && videoPlayer.currentPlayerManager.loadState == IRPlayerLoadStatePrepare && !self.prepareShowLoading) {
        [self.activity startAnimating];
    } else if ((state == IRPlayerLoadStateStalled || state == IRPlayerLoadStatePrepare) && videoPlayer.currentPlayerManager.loadState == IRPlayerLoadStatePrepare && self.prepareShowLoading) {
        [self.activity startAnimating];
    } else {
        [self.activity stopAnimating];
    }
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    [self.portraitControlView videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];
    [self.landScapeControlView videoPlayer:videoPlayer currentTime:currentTime totalTime:totalTime];
    self.bottomPgrogress.value = videoPlayer.progress;
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime {
    [self.portraitControlView videoPlayer:videoPlayer bufferTime:bufferTime];
    [self.landScapeControlView videoPlayer:videoPlayer bufferTime:bufferTime];
    self.bottomPgrogress.bufferValue = videoPlayer.bufferProgress;
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size {
    [self.landScapeControlView videoPlayer:videoPlayer presentationSizeChanged:size];
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer orientationWillChange:(IROrientationObserver *)observer {
    self.portraitControlView.hidden = observer.isFullScreen;
    self.landScapeControlView.hidden = !observer.isFullScreen;
    if (videoPlayer.isSmallFloatViewShow) {
        self.floatControlView.hidden = observer.isFullScreen;
        self.portraitControlView.hidden = YES;
        if (observer.isFullScreen) {
            self.controlViewAppeared = NO;
            [self cancelAutoFadeOutControlView];
        }
    }
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
    
    if (observer.isFullScreen) {
        [self.volumeBrightnessView removeSystemVolumeView];
    } else {
        [self.volumeBrightnessView addSystemVolumeView];
    }
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer orientationDidChanged:(IROrientationObserver *)observer {
    if (self.controlViewAppeared) {
        [self showControlViewWithAnimated:NO];
    } else {
        [self hideControlViewWithAnimated:NO];
    }
}

- (void)lockedVideoPlayer:(IRPlayerController *)videoPlayer lockedScreen:(BOOL)locked {
    [self showControlViewWithAnimated:YES];
}

- (void)playerDidAppearInScrollView:(IRPlayerController *)videoPlayer {
    if (!self.player.stopWhileNotVisible && !videoPlayer.isFullScreen) {
        self.floatControlView.hidden = YES;
        self.portraitControlView.hidden = NO;
    }
}

- (void)playerDidDisappearInScrollView:(IRPlayerController *)videoPlayer {
    if (!self.player.stopWhileNotVisible && !videoPlayer.isFullScreen) {
        self.floatControlView.hidden = NO;
        self.portraitControlView.hidden = YES;
    }
}

- (void)videoPlayer:(IRPlayerController *)videoPlayer floatViewShow:(BOOL)show {
    self.floatControlView.hidden = !show;
    self.portraitControlView.hidden = show;
}

#pragma mark - Private Method

- (void)sliderValueChangingValue:(CGFloat)value isForward:(BOOL)forward {
    if (self.horizontalPanShowControlView) {
        /// 显示控制层
        [self showControlViewWithAnimated:NO];
        [self cancelAutoFadeOutControlView];
    }
    
    self.fastProgressView.value = value;
    self.fastView.hidden = NO;
    self.fastView.alpha = 1;
    if (forward) {
        self.fastImageView.image = IRPlayer_Image(@"IRPlayer_fast_forward");
    } else {
        self.fastImageView.image = IRPlayer_Image(@"IRPlayer_fast_backward");
    }
    NSString *draggedTime = [IRUtilities convertTimeSecond:self.player.totalTime*value];
    NSString *totalTime = [IRUtilities convertTimeSecond:self.player.totalTime];
    self.fastTimeLabel.text = [NSString stringWithFormat:@"%@ / %@",draggedTime,totalTime];
    /// Update slider
    [self.portraitControlView sliderValueChanged:value currentTimeString:draggedTime];
    [self.landScapeControlView sliderValueChanged:value currentTimeString:draggedTime];

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideFastView) object:nil];
    [self performSelector:@selector(hideFastView) withObject:nil afterDelay:0.1];
    
    if (self.fastViewAnimated) {
        [UIView animateWithDuration:0.4 animations:^{
            self.fastView.transform = CGAffineTransformMakeTranslation(forward?8:-8, 0);
        }];
    }
}

- (void)hideFastView {
    [UIView animateWithDuration:0.4 animations:^{
        self.fastView.transform = CGAffineTransformIdentity;
        self.fastView.alpha = 0;
    } completion:^(BOOL finished) {
        self.fastView.hidden = YES;
    }];
}

- (void)failBtnClick:(UIButton *)sender {
//    [self.player.currentPlayerManager reloadPlayer];
}

#pragma mark - setter

- (void)setPlayer:(IRPlayerController *)player {
    _player = player;
    self.landScapeControlView.player = player;
    self.portraitControlView.player = player;
    
//    [player.currentPlayerManager.view insertSubview:self.bgImgView atIndex:0];
    [player.currentPlayerManager.view.superview insertSubview:self.bgImgView atIndex:0];
    [self.bgImgView addSubview:self.effectView];
//    [player.currentPlayerManager.view insertSubview:self.coverImageView atIndex:1];
    [player.currentPlayerManager.view.superview insertSubview:self.coverImageView atIndex:1];
    
    self.coverImageView.frame = player.currentPlayerManager.view.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bgImgView.frame = player.currentPlayerManager.view.bounds;
    self.bgImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.effectView.frame = self.bgImgView.bounds;
    self.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setSeekToPlay:(BOOL)seekToPlay {
    _seekToPlay = seekToPlay;
    self.portraitControlView.seekToPlay = seekToPlay;
    self.landScapeControlView.seekToPlay = seekToPlay;
}

- (void)setEffectViewShow:(BOOL)effectViewShow {
    _effectViewShow = effectViewShow;
    if (effectViewShow) {
        self.bgImgView.hidden = NO;
    } else {
        self.bgImgView.hidden = YES;
    }
}

#pragma mark - getter

- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] init];
        _bgImgView.userInteractionEnabled = YES;
    }
    return _bgImgView;
}

- (UIView *)effectView {
    if (!_effectView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        } else {
            UIToolbar *effectView = [[UIToolbar alloc] init];
            effectView.barStyle = UIBarStyleBlackTranslucent;
            _effectView = effectView;
        }
    }
    return _effectView;
}

- (IRPortraitControlView *)portraitControlView {
    if (!_portraitControlView) {
        @weakify(self)
        _portraitControlView = [[IRPortraitControlView alloc] init];
        _portraitControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
            @strongify(self)
            [self cancelAutoFadeOutControlView];
        };
        _portraitControlView.sliderValueChanged = ^(CGFloat value) {
            @strongify(self)
            [self autoFadeOutControlView];
        };
    }
    return _portraitControlView;
}

- (IRLandScapeControlView *)landScapeControlView {
    if (!_landScapeControlView) {
        @weakify(self)
        _landScapeControlView = [[IRLandScapeControlView alloc] init];
        _landScapeControlView.sliderValueChanging = ^(CGFloat value, BOOL forward) {
            @strongify(self)
            [self cancelAutoFadeOutControlView];
        };
        _landScapeControlView.sliderValueChanged = ^(CGFloat value) {
            @strongify(self)
            [self autoFadeOutControlView];
        };
    }
    return _landScapeControlView;
}

- (IRSpeedLoadingView *)activity {
    if (!_activity) {
        _activity = [[IRSpeedLoadingView alloc] init];
    }
    return _activity;
}

- (UIView *)fastView {
    if (!_fastView) {
        _fastView = [[UIView alloc] init];
        _fastView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _fastView.layer.cornerRadius = 4;
        _fastView.layer.masksToBounds = YES;
        _fastView.hidden = YES;
    }
    return _fastView;
}

- (UIImageView *)fastImageView {
    if (!_fastImageView) {
        _fastImageView = [[UIImageView alloc] init];
    }
    return _fastImageView;
}

- (UILabel *)fastTimeLabel {
    if (!_fastTimeLabel) {
        _fastTimeLabel = [[UILabel alloc] init];
        _fastTimeLabel.textColor = [UIColor whiteColor];
        _fastTimeLabel.textAlignment = NSTextAlignmentCenter;
        _fastTimeLabel.font = [UIFont systemFontOfSize:14.0];
        _fastTimeLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _fastTimeLabel;
}

- (IRSliderView *)fastProgressView {
    if (!_fastProgressView) {
        _fastProgressView = [[IRSliderView alloc] init];
        _fastProgressView.maximumTrackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
        _fastProgressView.minimumTrackTintColor = [UIColor whiteColor];
        _fastProgressView.sliderHeight = 2;
        _fastProgressView.isHideSliderBlock = NO;
    }
    return _fastProgressView;
}

- (UIButton *)failBtn {
    if (!_failBtn) {
        _failBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_failBtn setTitle:@"加载失败,点击重试" forState:UIControlStateNormal];
        [_failBtn addTarget:self action:@selector(failBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_failBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _failBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        _failBtn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        _failBtn.hidden = YES;
    }
    return _failBtn;
}

- (IRSliderView *)bottomPgrogress {
    if (!_bottomPgrogress) {
        _bottomPgrogress = [[IRSliderView alloc] init];
        _bottomPgrogress.maximumTrackTintColor = [UIColor clearColor];
        _bottomPgrogress.minimumTrackTintColor = [UIColor whiteColor];
        _bottomPgrogress.bufferTrackTintColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        _bottomPgrogress.sliderHeight = 1;
        _bottomPgrogress.isHideSliderBlock = NO;
    }
    return _bottomPgrogress;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _coverImageView;
}

- (IRSmallFloatControlView *)floatControlView {
    if (!_floatControlView) {
        _floatControlView = [[IRSmallFloatControlView alloc] init];
        @weakify(self)
        _floatControlView.closeClickCallback = ^{
            @strongify(self)
            if (self.player.containerType == IRPlayerContainerTypeCell) {
                [self.player stopCurrentPlayingCell];
            } else if (self.player.containerType == IRPlayerContainerTypeView) {
                [self.player stopCurrentPlayingView];
            }
            [self resetControlView];
        };
    }
    return _floatControlView;
}

- (IRVolumeBrightnessView *)volumeBrightnessView {
    if (!_volumeBrightnessView) {
        _volumeBrightnessView = [[IRVolumeBrightnessView alloc] init];
        _volumeBrightnessView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
        _volumeBrightnessView.hidden = YES;
    }
    return _volumeBrightnessView;
}

- (void)setBackBtnClickCallback:(void (^)(void))backBtnClickCallback {
    _backBtnClickCallback = [backBtnClickCallback copy];
    self.landScapeControlView.backBtnClickCallback = _backBtnClickCallback;
}

@end
