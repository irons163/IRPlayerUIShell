//
//  IRLandScapeControlView.h
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/24.
//  Copyright © 2020 irons. All rights reserved.
//
//
//  ZFLandScapeControlView.h
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
#import "IRSliderView.h"
#import "IRPlayerController.h"

NS_ASSUME_NONNULL_BEGIN

@interface IRLandScapeControlView : UIView

@property (nonatomic, strong, readonly) UIView *topToolView;

@property (nonatomic, strong, readonly) UIButton *backBtn;

@property (nonatomic, strong, readonly) UILabel *titleLabel;

@property (nonatomic, strong, readonly) UIView *bottomToolView;

@property (nonatomic, strong, readonly) UIButton *playOrPauseBtn;

@property (nonatomic, strong, readonly) UILabel *currentTimeLabel;

@property (nonatomic, strong, readonly) IRSliderView *slider;

@property (nonatomic, strong, readonly) UILabel *totalTimeLabel;

@property (nonatomic, strong, readonly) UIButton *lockBtn;

@property (nonatomic, weak) IRPlayerController *player;

@property (nonatomic, copy, nullable) void(^sliderValueChanging)(CGFloat value,BOOL forward);

@property (nonatomic, copy, nullable) void(^sliderValueChanged)(CGFloat value);

@property (nonatomic, copy) void(^backBtnClickCallback)(void);

/// If state is pause, then auto play after seek. Defaul is YES.
@property (nonatomic, assign) BOOL seekToPlay;

- (void)resetControlView;

- (void)showControlView;

- (void)hideControlView;

/// Set play time
- (void)videoPlayer:(IRPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

/// Set buffer time
- (void)videoPlayer:(IRPlayerController *)videoPlayer bufferTime:(NSTimeInterval)bufferTime;

- (BOOL)shouldResponseGestureWithPoint:(CGPoint)point withGestureType:(IRGestureType)type touch:(nonnull UITouch *)touch;

/// Video size changed
- (void)videoPlayer:(IRPlayerController *)videoPlayer presentationSizeChanged:(CGSize)size;

- (void)showTitle:(NSString *_Nullable)title fullScreenMode:(IRFullScreenMode)fullScreenMode;

- (void)playOrPause;

- (void)playBtnSelectedState:(BOOL)selected;

- (void)sliderValueChanged:(CGFloat)value currentTimeString:(NSString *)timeString;

- (void)sliderChangeEnded;

@end

NS_ASSUME_NONNULL_END
