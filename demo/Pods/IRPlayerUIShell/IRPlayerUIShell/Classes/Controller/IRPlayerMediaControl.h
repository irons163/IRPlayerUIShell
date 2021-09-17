//
//  IRPlayerMediaControl.h
//  IRPlayerUIShell
//
//  Created by irons on 2020/1/18.
//  Copyright © 2020年 irons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRPlayerMediaPlayback.h"
#import "IROrientationObserver.h"
#import "IRGestureController.h"
//#import "IRPlayerController.h"
#import "IRReachabilityManager.h"

@class IRPlayerController;

NS_ASSUME_NONNULL_BEGIN

@protocol IRPlayerMediaControl <NSObject>

/// Current playerController
@property (nonatomic, weak) IRPlayerController *player;

@required

@optional

#pragma mark - Playback state

/// When the player prepare to play the video.
- (void)videoPlayer:(IRPlayerController *)videoPlayer prepareToPlay:(NSURL *)assetURL;

/// When th player playback state changed.
- (void)videoPlayer:(IRPlayerController *)videoPlayer playStateChanged:(IRPlayerPlaybackState)state;

/// When th player loading state changed.
- (void)videoPlayer:(IRPlayerController *)videoPlayer loadStateChanged:(IRPlayerLoadState)state;

#pragma mark - progress

/**
 When the playback changed.
 
 @param videoPlayer the player.
 @param currentTime the current play time.
 @param totalTime the video total time.
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer
        currentTime:(NSTimeInterval)currentTime
          totalTime:(NSTimeInterval)totalTime;

/**
 When buffer progress changed.
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer
         bufferTime:(NSTimeInterval)bufferTime;

/**
 When you are dragging to change the video progress.
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer
       draggingTime:(NSTimeInterval)seekTime
          totalTime:(NSTimeInterval)totalTime;

/**
 When play end.
 */
- (void)videoPlayerPlayEnd:(IRPlayerController *)videoPlayer;

/**
 When play failed.
 */
- (void)videoPlayerPlayFailed:(IRPlayerController *)videoPlayer error:(id)error;

#pragma mark - lock screen

/**
 When set `videoPlayer.lockedScreen`.
 */
- (void)lockedVideoPlayer:(IRPlayerController *)videoPlayer lockedScreen:(BOOL)locked;

#pragma mark - Screen rotation

/**
 When the fullScreen maode will changed.
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer orientationWillChange:(IROrientationObserver *)observer;

/**
 When the fullScreen maode is changing(animating).
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer orientationIsChanging:(IROrientationObserver *)observer;

/**
 When the fullScreen maode did changed.
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer orientationDidChanged:(IROrientationObserver *)observer;

#pragma mark - The network changed

/**
 When the network changed
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer reachabilityChanged:(IRReachabilityStatus)status;

#pragma mark - The video size changed

/**
 When the video size changed
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size;

#pragma mark - Gesture

/**
 When the gesture condition
 */
- (BOOL)gestureTriggerCondition:(IRGestureController *)gestureControl
                    gestureType:(IRGestureType)gestureType
              gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
                          touch:(UITouch *)touch;

/**
 When the gesture single tapped
 */
- (void)gestureSingleTapped:(IRGestureController *)gestureControl;

/**
 When the gesture double tapped
 */
- (void)gestureDoubleTapped:(IRGestureController *)gestureControl;

/**
 When the gesture begin panGesture
 */
- (void)gestureBeganPan:(IRGestureController *)gestureControl
           panDirection:(IRPanDirection)direction
            panLocation:(IRPanLocation)location;

/**
 When the gesture paning
 */
- (void)gestureChangedPan:(IRGestureController *)gestureControl
             panDirection:(IRPanDirection)direction
              panLocation:(IRPanLocation)location
             withVelocity:(CGPoint)velocity;

/**
 When the end panGesture
 */
- (void)gestureEndedPan:(IRGestureController *)gestureControl
           panDirection:(IRPanDirection)direction
            panLocation:(IRPanLocation)location;

/**
 When the pinchGesture changed
 */
- (void)gesturePinched:(IRGestureController *)gestureControl
                 scale:(float)scale;

#pragma mark - scrollview

/**
 When the player will appear in scrollView.
 */
- (void)playerWillAppearInScrollView:(IRPlayerController *)videoPlayer;

/**
 When the player did appear in scrollView.
 */
- (void)playerDidAppearInScrollView:(IRPlayerController *)videoPlayer;

/**
 When the player will disappear in scrollView.
 */
- (void)playerWillDisappearInScrollView:(IRPlayerController *)videoPlayer;

/**
 When the player did disappear in scrollView.
 */
- (void)playerDidDisappearInScrollView:(IRPlayerController *)videoPlayer;

/**
 When the player appearing in scrollView.
 */
- (void)playerAppearingInScrollView:(IRPlayerController *)videoPlayer playerApperaPercent:(CGFloat)playerApperaPercent;

/**
 When the player disappearing in scrollView.
 */
- (void)playerDisappearingInScrollView:(IRPlayerController *)videoPlayer playerDisapperaPercent:(CGFloat)playerDisapperaPercent;

/**
 When the small float view show.
 */
- (void)videoPlayer:(IRPlayerController *)videoPlayer floatViewShow:(BOOL)show;

@end

NS_ASSUME_NONNULL_END
