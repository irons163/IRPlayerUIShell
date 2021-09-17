//
//  UIScrollView+IRPlayer.h
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/23.
//  Copyright © 2020 irons. All rights reserved.
//
//
//  UIScrollView+ZFPlayer.h
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

NS_ASSUME_NONNULL_BEGIN

/*
 * The scroll direction of scrollView.
 */
typedef NS_ENUM(NSUInteger, IRPlayerScrollDirection) {
    IRPlayerScrollDirectionNone,
    IRPlayerScrollDirectionUp,         // Scroll up
    IRPlayerScrollDirectionDown,       // Scroll Down
    IRPlayerScrollDirectionLeft,       // Scroll left
    IRPlayerScrollDirectionRight       // Scroll right
};

/*
 * The scrollView direction.
 */
typedef NS_ENUM(NSInteger, IRPlayerScrollViewDirection) {
    IRPlayerScrollViewDirectionVertical,
    IRPlayerScrollViewDirectionHorizontal
};

/*
 * The player container type
 */
typedef NS_ENUM(NSInteger, IRPlayerContainerType) {
    IRPlayerContainerTypeCell,
    IRPlayerContainerTypeView
};

@interface UIScrollView (IRPlayer)

/// When the IRPlayerScrollViewDirection is IRPlayerScrollViewDirectionVertical,the property has value.
@property (nonatomic, readonly) CGFloat ir_lastOffsetY;

/// When the IRPlayerScrollViewDirection is IRPlayerScrollViewDirectionHorizontal,the property has value.
@property (nonatomic, readonly) CGFloat ir_lastOffsetX;

/// The indexPath is playing.
@property (nonatomic, nullable) NSIndexPath *ir_playingIndexPath;

/// The indexPath that should play, the one that lights up.
@property (nonatomic, nullable) NSIndexPath *ir_shouldPlayIndexPath;

/// WWANA networks play automatically,default NO.
@property (nonatomic, getter=ir_isWWANAutoPlay) BOOL ir_WWANAutoPlay;

/// The player should auto player,default is YES.
@property (nonatomic) BOOL ir_shouldAutoPlay;

/// The view tag that the player display in scrollView.
@property (nonatomic) NSInteger ir_containerViewTag;

/// The scrollView scroll direction, default is IRPlayerScrollViewDirectionVertical.
@property (nonatomic) IRPlayerScrollViewDirection ir_scrollViewDirection;

/// The scroll direction of scrollView while scrolling.
/// When the IRPlayerScrollViewDirection is IRPlayerScrollViewDirectionVertical，this value can only be IRPlayerScrollDirectionUp or IRPlayerScrollDirectionDown.
/// When the IRPlayerScrollViewDirection is IRPlayerScrollViewDirectionVertical，this value can only be IRPlayerScrollDirectionLeft or IRPlayerScrollDirectionRight.
@property (nonatomic, readonly) IRPlayerScrollDirection ir_scrollDirection;

/// The video contrainerView type.
@property (nonatomic, assign) IRPlayerContainerType ir_containerType;

/// The video contrainerView in normal model.
@property (nonatomic, strong) UIView *ir_containerView;

/// The currently playing cell stop playing when the cell has out off the screen，defalut is YES.
@property (nonatomic, assign) BOOL ir_stopWhileNotVisible;

/// Has stopped playing
@property (nonatomic, assign) BOOL ir_stopPlay;

/// The block invoked When the player did stop scroll.
@property (nonatomic, copy, nullable) void(^ir_scrollViewDidStopScrollCallback)(NSIndexPath *indexPath);

/// The block invoked When the player did  scroll.
@property (nonatomic, copy, nullable) void(^ir_scrollViewDidScrollCallback)(NSIndexPath *indexPath);

/// The block invoked When the player should play.
@property (nonatomic, copy, nullable) void(^ir_shouldPlayIndexPathCallback)(NSIndexPath *indexPath);

/// Filter the cell that should be played when the scroll is stopped (to play when the scroll is stopped).
- (void)ir_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// Filter the cell that should be played while scrolling (you can use this to filter the highlighted cell).
- (void)ir_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler;

/// Get the cell according to indexPath.
- (UIView *)ir_getCellForIndexPath:(NSIndexPath *)indexPath;

/// Scroll to indexPath with animations.
- (void)ir_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler;

/// add in 3.2.4 version.
/// Scroll to indexPath with animations.
- (void)ir_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler;

/// add in 3.2.8 version.
/// Scroll to indexPath with animations duration.
- (void)ir_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler;

///------------------------------------
/// The following method must be implemented in UIScrollViewDelegate.
///------------------------------------

- (void)ir_scrollViewDidEndDecelerating;

- (void)ir_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate;

- (void)ir_scrollViewDidScrollToTop;

- (void)ir_scrollViewDidScroll;

- (void)ir_scrollViewWillBeginDragging;

///------------------------------------
/// end
///------------------------------------


@end

@interface UIScrollView (IRPlayerCannotCalled)

/// The block invoked When the player appearing.
@property (nonatomic, copy, nullable) void(^ir_playerAppearingInScrollView)(NSIndexPath *indexPath, CGFloat playerApperaPercent);

/// The block invoked When the player disappearing.
@property (nonatomic, copy, nullable) void(^ir_playerDisappearingInScrollView)(NSIndexPath *indexPath, CGFloat playerDisapperaPercent);

/// The block invoked When the player will appeared.
@property (nonatomic, copy, nullable) void(^ir_playerWillAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did appeared.
@property (nonatomic, copy, nullable) void(^ir_playerDidAppearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player will disappear.
@property (nonatomic, copy, nullable) void(^ir_playerWillDisappearInScrollView)(NSIndexPath *indexPath);

/// The block invoked When the player did disappeared.
@property (nonatomic, copy, nullable) void(^ir_playerDidDisappearInScrollView)(NSIndexPath *indexPath);

/// The current player scroll slides off the screen percent.
/// the property used when the `stopWhileNotVisible` is YES, stop the current playing player.
/// the property used when the `stopWhileNotVisible` is NO, the current playing player add to small container view.
/// 0.0~1.0, defalut is 0.5.
/// 0.0 is the player will disappear.
/// 1.0 is the player did disappear.
@property (nonatomic) CGFloat ir_playerDisapperaPercent;

/// The current player scroll to the screen percent to play the video.
/// 0.0~1.0, defalut is 0.0.
/// 0.0 is the player will appear.
/// 1.0 is the player did appear.
@property (nonatomic) CGFloat ir_playerApperaPercent;

/// The current player controller is disappear, not dealloc
@property (nonatomic) BOOL ir_viewControllerDisappear;

@end

NS_ASSUME_NONNULL_END
