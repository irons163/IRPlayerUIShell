//
//  IRPlayerWithMediaPlayback.m
//  demo
//
//  Created by Phil on 2021/9/11.
//  Copyright © 2021 irons. All rights reserved.
//

#import "IRPlayerWithMediaPlayback.h"
#import <objc/runtime.h>

@interface IRPlayerWithMediaPlayback()

//@property (nonatomic, readonly) IRPlayerLoadState loadState;

@end

@implementation IRPlayerWithMediaPlayback
//@dynamic loadState;
@synthesize playState = _playState;
@synthesize loadState = _loadState;
@synthesize playerPrepareToPlay = _playerPrepareToPlay;
@synthesize playerReadyToPlay = _playerReadyToPlay;
@synthesize assetURL = _assetURL;

//- (UIView *)getView {
//    return nil;
//}

- (void)setAssetURL:(NSURL *)assetURL {
    _assetURL = assetURL;
    [self replaceVideoWithURL:_assetURL];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    [self seekToTime:time completeHandler:completionHandler];
}

- (IRPlayerPlaybackState)playState {
    switch (self.state) {
        case IRPlayerStateNone:
            return IRPlayerPlayStateUnknown;
            break;
        case IRPlayerStatePlaying:
            return IRPlayerPlayStatePlaying;
            break;
        default:
            break;
    }
    
    return IRPlayerPlayStateUnknown;
}

- (IRPlayerLoadState)loadState {
    switch (self.state) {
        case IRPlayerStateBuffering:
            return IRPlayerLoadStatePrepare;
            break;
        case IRPlayerStateReadyToPlay:
            return IRPlayerLoadStatePlayable;
            break;
        default:
            break;
    }
    
    return IRPlayerLoadStateUnknown;
}

- (IRPlayerScalingMode)scalingMode {
    switch (self.viewGravityMode) {
        case IRGravityModeResize:
            return IRPlayerScalingModeFill;
        case IRGravityModeResizeAspect:
            return IRPlayerScalingModeAspectFit;
        case IRGravityModeResizeAspectFill:
            return IRPlayerScalingModeAspectFill;
        default:
            break;
    }
    
    return IRPlayerScalingModeNone;
}

- (void)setScalingMode:(IRPlayerScalingMode)scalingMode {
    switch (scalingMode) {
        case IRPlayerScalingModeFill:
            self.viewGravityMode = IRGravityModeResize;
            break;
        case IRPlayerScalingModeAspectFit:
            self.viewGravityMode =  IRGravityModeResizeAspect;
            break;
        case IRGravityModeResizeAspectFill:
            self.viewGravityMode =  IRGravityModeResizeAspectFill;
            break;
        default:
            break;
    }
    
    self.viewGravityMode = IRGravityModeResize;
}

//- (void)setPlayerPrepareToPlay:(void (^)(id<IRPlayerMediaPlayback> asset, NSURL *assetURL))playerPrepareToPlay {
//    objc_setAssociatedObject(self, @selector(playerPrepareToPlay), playerPrepareToPlay, OBJC_ASSOCIATION_COPY);
//}
//
//- (void)setPlayerReadyToPlay:(void (^)(id<IRPlayerMediaPlayback> asset, NSURL *assetURL))playerReadyToPlay {
//    objc_setAssociatedObject(self, @selector(playerReadyToPlay), playerReadyToPlay, OBJC_ASSOCIATION_COPY);
//}

@end
