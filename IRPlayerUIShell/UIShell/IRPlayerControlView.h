//
//  IRPlayerControlView.h
//  IRPlayerUIShell
//
//  Created by irons on 2020/1/18.
//  Copyright © 2020年 irons. All rights reserved.
//
//
//  ZFPlayerControlView.h
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

#import <UIKit/UIKit.h>
#import "IRPortraitControlView.h"
#import "IRLandScapeControlView.h"
#import "IRSpeedLoadingView.h"
#import "IRSmallFloatControlView.h"
#import "IRPlayerMediaControl.h"

@interface IRPlayerControlView : UIView <IRPlayerMediaControl>

@property (nonatomic, strong, readonly) IRPortraitControlView *portraitControlView;

@property (nonatomic, strong, readonly) IRLandScapeControlView *landScapeControlView;

@property (nonatomic, strong, readonly) IRSpeedLoadingView *activity;

@property (nonatomic, strong, readonly) UIView *fastView;

@property (nonatomic, strong, readonly) IRSliderView *fastProgressView;

@property (nonatomic, strong, readonly) UILabel *fastTimeLabel;

@property (nonatomic, strong, readonly) UIImageView *fastImageView;

@property (nonatomic, strong, readonly) UIButton *failBtn;

@property (nonatomic, strong, readonly) IRSliderView *bottomPgrogress;

@property (nonatomic, strong, readonly) UIImageView *coverImageView;

/// Blur bg view
@property (nonatomic, strong, readonly) UIImageView *bgImgView;

/// Blur effect view
@property (nonatomic, strong, readonly) UIView *effectView;

/// Float contorl view.
@property (nonatomic, strong, readonly) IRSmallFloatControlView *floatControlView;

/// Show animation with fastView. Default is NO.
@property (nonatomic, assign) BOOL fastViewAnimated;

/// Make outside area of  video player to blur. Default is YES.
@property (nonatomic, assign) BOOL effectViewShow;

@property (nonatomic, assign) BOOL fullScreenOnly;

/// If state is pause, then auto play after seek. Defaul is YES.
@property (nonatomic, assign) BOOL seekToPlay;

@property (nonatomic, copy) void(^backBtnClickCallback)(void);

/// controlView is show or hidden
@property (nonatomic, readonly) BOOL controlViewAppeared;

@property (nonatomic, copy) void(^controlViewAppearedCallback)(BOOL appeared);

/// The time for auto hidden for control view. Default is 2.5s.
@property (nonatomic, assign) NSTimeInterval autoHiddenTimeInterval;

/// The fade animation time for control view. Default is 0.25s.
@property (nonatomic, assign) NSTimeInterval autoFadeTimeInterval;

/// When the pan gesture that is controlling video progress, show the controlView. Default is YES.
@property (nonatomic, assign) BOOL horizontalPanShowControlView;

/// When player is preparing, show the controlView. Default is NO.
@property (nonatomic, assign) BOOL prepareShowControlView;

/// When player is preparing, show the loading view. Default is NO.
@property (nonatomic, assign) BOOL prepareShowLoading;

/// Disable custom pan gestures. Default is NO.
@property (nonatomic, assign) BOOL customDisablePanMovingDirection;

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl fullScreenMode:(IRFullScreenMode)fullScreenMode;

- (void)showTitle:(NSString *)title coverURLString:(NSString *)coverUrl placeholderImage:(UIImage *)placeholder fullScreenMode:(IRFullScreenMode)fullScreenMode;

- (void)showTitle:(NSString *)title coverImage:(UIImage *)image fullScreenMode:(IRFullScreenMode)fullScreenMode;

- (void)resetControlView;

@end
