//
//  UIScrollView+IRPlayer.m
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/23.
//  Copyright © 2020 irons. All rights reserved.
//
//
//  UIScrollView+ZFPlayer.m
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

#import "UIScrollView+IRPlayer.h"
#import <objc/runtime.h>
#import "IRReachabilityManager.h"
//#import "IRPlayer.h"
#import "IRKVOController.h"
#import "IRScope.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

@interface UIScrollView ()

@property (nonatomic) CGFloat ir_lastOffsetY;
@property (nonatomic) CGFloat ir_lastOffsetX;
@property (nonatomic) IRPlayerScrollDirection ir_scrollDirection;

@end

@implementation UIScrollView (IRPlayer)

#pragma mark - private method

- (void)_scrollViewDidStopScroll {
    @weakify(self)
    [self ir_filterShouldPlayCellWhileScrolled:^(NSIndexPath * _Nonnull indexPath) {
        @strongify(self)
        if (self.ir_scrollViewDidStopScrollCallback) self.ir_scrollViewDidStopScrollCallback(indexPath);
    }];
}

- (void)_scrollViewBeginDragging {
    if (self.ir_scrollViewDirection == IRPlayerScrollViewDirectionVertical) {
        self.ir_lastOffsetY = self.contentOffset.y;
    } else {
        self.ir_lastOffsetX = self.contentOffset.x;
    }
}

/**
  The percentage of scrolling processed in vertical scrolling.
 */
- (void)_scrollViewScrollingDirectionVertical {
    CGFloat offsetY = self.contentOffset.y;
    self.ir_scrollDirection = (offsetY - self.ir_lastOffsetY > 0) ? IRPlayerScrollDirectionUp : IRPlayerScrollDirectionDown;
    self.ir_lastOffsetY = offsetY;
    if (self.ir_stopPlay) return;
    
    UIView *playerView;
    if (self.ir_containerType == IRPlayerContainerTypeCell) {
        // Avoid being paused the first time you play it.
        if (self.contentOffset.y < 0) return;
        if (!self.ir_playingIndexPath) return;
        
        UIView *cell = [self ir_getCellForIndexPath:self.ir_playingIndexPath];
        if (!cell) {
            if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(self.ir_playingIndexPath);
            return;
        }
        playerView = [cell viewWithTag:self.ir_containerViewTag];
    } else if (self.ir_containerType == IRPlayerContainerTypeView) {
        if (!self.ir_containerView) return;
        playerView = self.ir_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    /// playerView top to scrollView top space.
    CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
    /// playerView bottom to scrollView bottom space.
    CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
    /// The height of the content area.
    CGFloat contentInsetHeight = CGRectGetMaxY(self.frame) - CGRectGetMinY(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.ir_scrollDirection == IRPlayerScrollDirectionUp) { /// Scroll up
        /// Player is disappearing.
        if (topSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -topSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.ir_playerDisappearingInScrollView) self.ir_playerDisappearingInScrollView(self.ir_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Top area
        if (topSpacing <= 0 && topSpacing > -CGRectGetHeight(rect)/2) {
            /// When the player will disappear.
            if (self.ir_playerWillDisappearInScrollView) self.ir_playerWillDisappearInScrollView(self.ir_playingIndexPath);
        } else if (topSpacing <= -CGRectGetHeight(rect)) {
            /// When the player did disappeared.
            if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(self.ir_playingIndexPath);
        } else if (topSpacing > 0 && topSpacing <= contentInsetHeight) {
            /// Player is appearing.
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(topSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.ir_playerAppearingInScrollView) self.ir_playerAppearingInScrollView(self.ir_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (topSpacing <= contentInsetHeight && topSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                /// When the player will appear.
                if (self.ir_playerWillAppearInScrollView) self.ir_playerWillAppearInScrollView(self.ir_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.ir_playerDidAppearInScrollView) self.ir_playerDidAppearInScrollView(self.ir_playingIndexPath);
            }
        }
        
    } else if (self.ir_scrollDirection == IRPlayerScrollDirectionDown) { /// Scroll Down
        /// Player is disappearing.
        if (bottomSpacing <= 0 && CGRectGetHeight(rect) != 0) {
            playerDisapperaPercent = -bottomSpacing/CGRectGetHeight(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.ir_playerDisappearingInScrollView) self.ir_playerDisappearingInScrollView(self.ir_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Bottom area
        if (bottomSpacing <= 0 && bottomSpacing > -CGRectGetHeight(rect)/2) {
            /// When the player will disappear.
            if (self.ir_playerWillDisappearInScrollView) self.ir_playerWillDisappearInScrollView(self.ir_playingIndexPath);
        } else if (bottomSpacing <= -CGRectGetHeight(rect)) {
            /// When the player did disappeared.
            if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(self.ir_playingIndexPath);
        } else if (bottomSpacing > 0 && bottomSpacing <= contentInsetHeight) {
            /// Player is appearing.
            if (CGRectGetHeight(rect) != 0) {
                playerApperaPercent = -(bottomSpacing-contentInsetHeight)/CGRectGetHeight(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.ir_playerAppearingInScrollView) self.ir_playerAppearingInScrollView(self.ir_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (bottomSpacing <= contentInsetHeight && bottomSpacing > contentInsetHeight-CGRectGetHeight(rect)/2) {
                /// When the player will appear.
                if (self.ir_playerWillAppearInScrollView) self.ir_playerWillAppearInScrollView(self.ir_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.ir_playerDidAppearInScrollView) self.ir_playerDidAppearInScrollView(self.ir_playingIndexPath);
            }
        }
    }
}

/**
 The percentage of scrolling processed in horizontal scrolling.
 */
- (void)_scrollViewScrollingDirectionHorizontal {
    CGFloat offsetX = self.contentOffset.x;
    self.ir_scrollDirection = (offsetX - self.ir_lastOffsetX > 0) ? IRPlayerScrollDirectionLeft : IRPlayerScrollDirectionRight;
    self.ir_lastOffsetX = offsetX;
    if (self.ir_stopPlay) return;
    
    UIView *playerView;
    if (self.ir_containerType == IRPlayerContainerTypeCell) {
        // Avoid being paused the first time you play it.
        if (self.contentOffset.x < 0) return;
        if (!self.ir_playingIndexPath) return;
        
        UIView *cell = [self ir_getCellForIndexPath:self.ir_playingIndexPath];
        if (!cell) {
            if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(self.ir_playingIndexPath);
            return;
        }
       playerView = [cell viewWithTag:self.ir_containerViewTag];
    } else if (self.ir_containerType == IRPlayerContainerTypeView) {
        if (!self.ir_containerView) return;
        playerView = self.ir_containerView;
    }
    
    CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
    CGRect rect = [self convertRect:rect1 toView:self.superview];
    /// playerView left to scrollView left space.
    CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
    /// playerView bottom to scrollView right space.
    CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
    /// The height of the content area.
    CGFloat contentInsetWidth = CGRectGetMaxX(self.frame) - CGRectGetMinX(self.frame);
    
    CGFloat playerDisapperaPercent = 0;
    CGFloat playerApperaPercent = 0;
    
    if (self.ir_scrollDirection == IRPlayerScrollDirectionLeft) { /// Scroll left
        /// Player is disappearing.
        if (leftSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -leftSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.ir_playerDisappearingInScrollView) self.ir_playerDisappearingInScrollView(self.ir_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Top area
        if (leftSpacing <= 0 && leftSpacing > -CGRectGetWidth(rect)/2) {
            /// When the player will disappear.
            if (self.ir_playerWillDisappearInScrollView) self.ir_playerWillDisappearInScrollView(self.ir_playingIndexPath);
        } else if (leftSpacing <= -CGRectGetWidth(rect)) {
            /// When the player did disappeared.
            if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(self.ir_playingIndexPath);
        } else if (leftSpacing > 0 && leftSpacing <= contentInsetWidth) {
            /// Player is appearing.
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(leftSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.ir_playerAppearingInScrollView) self.ir_playerAppearingInScrollView(self.ir_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (leftSpacing <= contentInsetWidth && leftSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                /// When the player will appear.
                if (self.ir_playerWillAppearInScrollView) self.ir_playerWillAppearInScrollView(self.ir_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.ir_playerDidAppearInScrollView) self.ir_playerDidAppearInScrollView(self.ir_playingIndexPath);
            }
        }
        
    } else if (self.ir_scrollDirection == IRPlayerScrollDirectionRight) { /// Scroll right
        /// Player is disappearing.
        if (rightSpacing <= 0 && CGRectGetWidth(rect) != 0) {
            playerDisapperaPercent = -rightSpacing/CGRectGetWidth(rect);
            if (playerDisapperaPercent > 1.0) playerDisapperaPercent = 1.0;
            if (self.ir_playerDisappearingInScrollView) self.ir_playerDisappearingInScrollView(self.ir_playingIndexPath, playerDisapperaPercent);
        }
        
        /// Bottom area
        if (rightSpacing <= 0 && rightSpacing > -CGRectGetWidth(rect)/2) {
            /// When the player will disappear.
            if (self.ir_playerWillDisappearInScrollView) self.ir_playerWillDisappearInScrollView(self.ir_playingIndexPath);
        } else if (rightSpacing <= -CGRectGetWidth(rect)) {
            /// When the player did disappeared.
            if (self.ir_playerDidDisappearInScrollView) self.ir_playerDidDisappearInScrollView(self.ir_playingIndexPath);
        } else if (rightSpacing > 0 && rightSpacing <= contentInsetWidth) {
            /// Player is appearing.
            if (CGRectGetWidth(rect) != 0) {
                playerApperaPercent = -(rightSpacing-contentInsetWidth)/CGRectGetWidth(rect);
                if (playerApperaPercent > 1.0) playerApperaPercent = 1.0;
                if (self.ir_playerAppearingInScrollView) self.ir_playerAppearingInScrollView(self.ir_playingIndexPath, playerApperaPercent);
            }
            /// In visable area
            if (rightSpacing <= contentInsetWidth && rightSpacing > contentInsetWidth-CGRectGetWidth(rect)/2) {
                /// When the player will appear.
                if (self.ir_playerWillAppearInScrollView) self.ir_playerWillAppearInScrollView(self.ir_playingIndexPath);
            } else {
                /// When the player did appeared.
                if (self.ir_playerDidAppearInScrollView) self.ir_playerDidAppearInScrollView(self.ir_playingIndexPath);
            }
        }
    }
}

/**
 Find the playing cell while the scrollDirection is vertical.
 */
- (void)_findCorrectCellWhenScrollViewDirectionVertical:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.ir_shouldAutoPlay) return;
    if (self.ir_containerType == IRPlayerContainerTypeView) return;

    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        // First visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if (self.contentOffset.y <= 0 && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.lastObject;
        if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        // First visible cell indexPath
        indexPath = sortedIndexPaths.firstObject;
        if (self.contentOffset.y <= 0 && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = sortedIndexPaths.lastObject;
        if (self.contentOffset.y + self.frame.size.height >= self.contentSize.height && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.ir_scrollDirection == IRPlayerScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    /// Mid line.
    CGFloat scrollViewMidY = CGRectGetHeight(self.frame)/2;
    /// The final playing indexPath.
    __block NSIndexPath *finalIndexPath = nil;
    /// The final distance from the center line.
    __block CGFloat finalSpace = 0;
    @weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
        if (!playerView) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        /// playerView top to scrollView top space.
        CGFloat topSpacing = CGRectGetMinY(rect) - CGRectGetMinY(self.frame) - CGRectGetMinY(playerView.frame);
        /// playerView bottom to scrollView bottom space.
        CGFloat bottomSpacing = CGRectGetMaxY(self.frame) - CGRectGetMaxY(rect) + CGRectGetMinY(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidY - CGRectGetMidY(rect));
        NSIndexPath *indexPath = [self ir_getIndexPathForCell:cell];
        
        /// Play when the video playback section is visible.
        if ((topSpacing >= -(1 - self.ir_playerApperaPercent) * CGRectGetHeight(rect)) && (bottomSpacing >= -(1 - self.ir_playerApperaPercent) * CGRectGetHeight(rect))) {
            /// If you have a cell that is playing, stop the traversal.
            if (self.ir_playingIndexPath) {
                indexPath = self.ir_playingIndexPath;
                finalIndexPath = indexPath;
                *stop = YES;
                return;
            }
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    /// if find the playing indexPath.
    if (finalIndexPath) {
        if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
        if (handler) handler(finalIndexPath);
        self.ir_shouldPlayIndexPath = finalIndexPath;
    }
}

/**
 Find the playing cell while the scrollDirection is horizontal.
 */
- (void)_findCorrectCellWhenScrollViewDirectionHorizontal:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.ir_shouldAutoPlay) return;
    if (self.ir_containerType == IRPlayerContainerTypeView) return;
    
    NSArray *visiableCells = nil;
    NSIndexPath *indexPath = nil;
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        visiableCells = [tableView visibleCells];
        // First visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.firstObject;
        if (self.contentOffset.x <= 0 && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = tableView.indexPathsForVisibleRows.lastObject;
        if (self.contentOffset.x + self.frame.size.width >= self.contentSize.width && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        visiableCells = [collectionView visibleCells];
        NSArray *sortedIndexPaths = [collectionView.indexPathsForVisibleItems sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        
        visiableCells = [visiableCells sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSIndexPath *path1 = (NSIndexPath *)[collectionView indexPathForCell:obj1];
            NSIndexPath *path2 = (NSIndexPath *)[collectionView indexPathForCell:obj2];
            return [path1 compare:path2];
        }];
        
        // First visible cell indexPath
        indexPath = sortedIndexPaths.firstObject;
        if (self.contentOffset.x <= 0 && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
        
        // Last visible cell indexPath
        indexPath = sortedIndexPaths.lastObject;
        if (self.contentOffset.x + self.frame.size.width >= self.contentSize.width && (!self.ir_playingIndexPath || [indexPath compare:self.ir_playingIndexPath] == NSOrderedSame)) {
            UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
            UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
            if (playerView) {
                if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
                if (handler) handler(indexPath);
                self.ir_shouldPlayIndexPath = indexPath;
                return;
            }
        }
    }
    
    NSArray *cells = nil;
    if (self.ir_scrollDirection == IRPlayerScrollDirectionUp) {
        cells = visiableCells;
    } else {
        cells = [visiableCells reverseObjectEnumerator].allObjects;
    }
    
    /// Mid line.
    CGFloat scrollViewMidX = CGRectGetWidth(self.frame)/2;
    /// The final playing indexPath.
    __block NSIndexPath *finalIndexPath = nil;
    /// The final distance from the center line.
    __block CGFloat finalSpace = 0;
    @weakify(self)
    [cells enumerateObjectsUsingBlock:^(UIView *cell, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self)
        UIView *playerView = [cell viewWithTag:self.ir_containerViewTag];
        if (!playerView) return;
        CGRect rect1 = [playerView convertRect:playerView.frame toView:self];
        CGRect rect = [self convertRect:rect1 toView:self.superview];
        /// playerView left to scrollView top space.
        CGFloat leftSpacing = CGRectGetMinX(rect) - CGRectGetMinX(self.frame) - CGRectGetMinX(playerView.frame);
        /// playerView right to scrollView top space.
        CGFloat rightSpacing = CGRectGetMaxX(self.frame) - CGRectGetMaxX(rect) + CGRectGetMinX(playerView.frame);
        CGFloat centerSpacing = ABS(scrollViewMidX - CGRectGetMidX(rect));
        NSIndexPath *indexPath = [self ir_getIndexPathForCell:cell];
        
        /// Play when the video playback section is visible.
        if ((leftSpacing >= -(1 - self.ir_playerApperaPercent) * CGRectGetWidth(rect)) && (rightSpacing >= -(1 - self.ir_playerApperaPercent) * CGRectGetWidth(rect))) {
            /// If you have a cell that is playing, stop the traversal.
            if (self.ir_playingIndexPath) {
                indexPath = self.ir_playingIndexPath;
                finalIndexPath = indexPath;
                *stop = YES;
                return;
            }
            if (!finalIndexPath || centerSpacing < finalSpace) {
                finalIndexPath = indexPath;
                finalSpace = centerSpacing;
            }
        }
    }];
    /// if find the playing indexPath.
    if (finalIndexPath) {
        if (self.ir_scrollViewDidScrollCallback) self.ir_scrollViewDidScrollCallback(indexPath);
        if (handler) handler(finalIndexPath);
        self.ir_shouldPlayIndexPath = finalIndexPath;
    }
}

- (BOOL)isTableView {
    return [self isKindOfClass:[UITableView class]];
}

- (BOOL)isCollectionView {
    return [self isKindOfClass:[UICollectionView class]];
}

#pragma mark - public method

- (void)ir_filterShouldPlayCellWhileScrolling:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (self.ir_scrollViewDirection == IRPlayerScrollViewDirectionVertical) {
        [self _findCorrectCellWhenScrollViewDirectionVertical:handler];
    } else {
        [self _findCorrectCellWhenScrollViewDirectionHorizontal:handler];
    }
}

- (void)ir_filterShouldPlayCellWhileScrolled:(void (^ __nullable)(NSIndexPath *indexPath))handler {
    if (!self.ir_shouldAutoPlay) return;
    @weakify(self)
    [self ir_filterShouldPlayCellWhileScrolling:^(NSIndexPath *indexPath) {
        @strongify(self)
        /// 如果当前控制器已经消失，直接return
        if (self.ir_viewControllerDisappear) return;
        if ([IRReachabilityManager sharedManager].isReachableViaWWAN && !self.ir_WWANAutoPlay) {
            /// 移动网络
            self.ir_shouldPlayIndexPath = indexPath;
            return;
        }
        if (handler) handler(indexPath);
        self.ir_playingIndexPath = indexPath;
    }];
}

- (UIView *)ir_getCellForIndexPath:(NSIndexPath *)indexPath {
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        return cell;
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        return cell;
    }
    return nil;
}

- (NSIndexPath *)ir_getIndexPathForCell:(UIView *)cell {
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        NSIndexPath *indexPath = [tableView indexPathForCell:(UITableViewCell *)cell];
        return indexPath;
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        NSIndexPath *indexPath = [collectionView indexPathForCell:(UICollectionViewCell *)cell];
        return indexPath;
    }
    return nil;
}

- (void)ir_scrollToRowAtIndexPath:(NSIndexPath *)indexPath completionHandler:(void (^ __nullable)(void))completionHandler {
    [self ir_scrollToRowAtIndexPath:indexPath animated:YES completionHandler:completionHandler];
}

- (void)ir_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated completionHandler:(void (^ __nullable)(void))completionHandler {
    [self ir_scrollToRowAtIndexPath:indexPath animateWithDuration:animated ? 0.4 : 0.0 completionHandler:completionHandler];
}

/// Scroll to indexPath with animations duration.
- (void)ir_scrollToRowAtIndexPath:(NSIndexPath *)indexPath animateWithDuration:(NSTimeInterval)duration completionHandler:(void (^ __nullable)(void))completionHandler {
    BOOL animated = duration > 0.0;
    if ([self isTableView]) {
        UITableView *tableView = (UITableView *)self;
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
    } else if ([self isCollectionView]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (completionHandler) completionHandler();
    });
}

- (void)ir_scrollViewDidEndDecelerating {
    BOOL scrollToScrollStop = !self.tracking && !self.dragging && !self.decelerating;
    if (scrollToScrollStop) {
        [self _scrollViewDidStopScroll];
    }
}

- (void)ir_scrollViewDidEndDraggingWillDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        BOOL dragToDragStop = self.tracking && !self.dragging && !self.decelerating;
        if (dragToDragStop) {
            [self _scrollViewDidStopScroll];
        }
    }
}

- (void)ir_scrollViewDidScrollToTop {
    [self _scrollViewDidStopScroll];
}

- (void)ir_scrollViewDidScroll {
    if (self.ir_scrollViewDirection == IRPlayerScrollViewDirectionVertical) {
        [self _scrollViewScrollingDirectionVertical];
    } else {
        [self _scrollViewScrollingDirectionHorizontal];
    }
}

- (void)ir_scrollViewWillBeginDragging {
    [self _scrollViewBeginDragging];
}

#pragma mark - getter

- (NSIndexPath *)ir_playingIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSIndexPath *)ir_shouldPlayIndexPath {
    return objc_getAssociatedObject(self, _cmd);
}

- (NSInteger)ir_containerViewTag {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (IRPlayerScrollDirection)ir_scrollDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)ir_stopWhileNotVisible {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)ir_isWWANAutoPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (BOOL)ir_shouldAutoPlay {
    NSNumber *number = objc_getAssociatedObject(self, _cmd);
    if (number) return number.boolValue;
    self.ir_shouldAutoPlay = YES;
    return YES;
}

- (IRPlayerScrollViewDirection)ir_scrollViewDirection {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (BOOL)ir_stopPlay {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (IRPlayerContainerType)ir_containerType {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (UIView *)ir_containerView {
    return objc_getAssociatedObject(self, _cmd);
}

- (CGFloat)ir_lastOffsetY {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)ir_lastOffsetX {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (void (^)(NSIndexPath * _Nonnull))ir_scrollViewDidStopScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))ir_scrollViewDidScrollCallback {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull))ir_shouldPlayIndexPathCallback {
    return objc_getAssociatedObject(self, _cmd);
}

#pragma mark - setter

- (void)setIr_playingIndexPath:(NSIndexPath *)ir_playingIndexPath {
    objc_setAssociatedObject(self, @selector(ir_playingIndexPath), ir_playingIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (ir_playingIndexPath) self.ir_shouldPlayIndexPath = ir_playingIndexPath;
}

- (void)setIr_shouldPlayIndexPath:(NSIndexPath *)ir_shouldPlayIndexPath {
    if (self.ir_shouldPlayIndexPathCallback) self.ir_shouldPlayIndexPathCallback(ir_shouldPlayIndexPath);
    objc_setAssociatedObject(self, @selector(ir_shouldPlayIndexPath), ir_shouldPlayIndexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_containerViewTag:(NSInteger)ir_containerViewTag {
    objc_setAssociatedObject(self, @selector(ir_containerViewTag), @(ir_containerViewTag), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_scrollDirection:(IRPlayerScrollDirection)ir_scrollDirection {
    objc_setAssociatedObject(self, @selector(ir_scrollDirection), @(ir_scrollDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_stopWhileNotVisible:(BOOL)ir_stopWhileNotVisible {
    objc_setAssociatedObject(self, @selector(ir_stopWhileNotVisible), @(ir_stopWhileNotVisible), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_WWANAutoPlay:(BOOL)ir_WWANAutoPlay {
    objc_setAssociatedObject(self, @selector(ir_isWWANAutoPlay), @(ir_WWANAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_scrollViewDirection:(IRPlayerScrollViewDirection)ir_scrollViewDirection {
    objc_setAssociatedObject(self, @selector(ir_scrollViewDirection), @(ir_scrollViewDirection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_stopPlay:(BOOL)ir_stopPlay {
    objc_setAssociatedObject(self, @selector(ir_stopPlay), @(ir_stopPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_containerType:(IRPlayerContainerType)ir_containerType {
    objc_setAssociatedObject(self, @selector(ir_containerType), @(ir_containerType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_containerView:(UIView *)ir_containerView {
    objc_setAssociatedObject(self, @selector(ir_containerView), ir_containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_shouldAutoPlay:(BOOL)ir_shouldAutoPlay {
    objc_setAssociatedObject(self, @selector(ir_shouldAutoPlay), @(ir_shouldAutoPlay), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_lastOffsetY:(CGFloat)ir_lastOffsetY {
    objc_setAssociatedObject(self, @selector(ir_lastOffsetY), @(ir_lastOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_lastOffsetX:(CGFloat)ir_lastOffsetX {
    objc_setAssociatedObject(self, @selector(ir_lastOffsetX), @(ir_lastOffsetX), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setIr_scrollViewDidStopScrollCallback:(void (^)(NSIndexPath * _Nonnull))ir_scrollViewDidStopScrollCallback {
    objc_setAssociatedObject(self, @selector(ir_scrollViewDidStopScrollCallback), ir_scrollViewDidStopScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_scrollViewDidScrollCallback:(void (^)(NSIndexPath * _Nonnull))ir_scrollViewDidScrollCallback {
    objc_setAssociatedObject(self, @selector(ir_scrollViewDidScrollCallback), ir_scrollViewDidScrollCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_shouldPlayIndexPathCallback:(void (^)(NSIndexPath * _Nonnull))ir_shouldPlayIndexPathCallback {
    objc_setAssociatedObject(self, @selector(ir_shouldPlayIndexPathCallback), ir_shouldPlayIndexPathCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

@implementation UIScrollView (IRPlayerCannotCalled)

#pragma mark - getter

- (void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerDisappearingInScrollView {
    return objc_getAssociatedObject(self, _cmd);
}

- (void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerAppearingInScrollView {
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

- (CGFloat)ir_playerApperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (CGFloat)ir_playerDisapperaPercent {
    return [objc_getAssociatedObject(self, _cmd) floatValue];
}

- (BOOL)ir_viewControllerDisappear {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

#pragma mark - setter

- (void)setIr_playerDisappearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerDisappearingInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerDisappearingInScrollView), ir_playerDisappearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerAppearingInScrollView:(void (^)(NSIndexPath * _Nonnull, CGFloat))ir_playerAppearingInScrollView {
    objc_setAssociatedObject(self, @selector(ir_playerAppearingInScrollView), ir_playerAppearingInScrollView, OBJC_ASSOCIATION_COPY_NONATOMIC);
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

- (void)setIr_playerApperaPercent:(CGFloat)ir_playerApperaPercent {
    objc_setAssociatedObject(self, @selector(ir_playerApperaPercent), @(ir_playerApperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_playerDisapperaPercent:(CGFloat)ir_playerDisapperaPercent {
    objc_setAssociatedObject(self, @selector(ir_playerDisapperaPercent), @(ir_playerDisapperaPercent), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)setIr_viewControllerDisappear:(BOOL)ir_viewControllerDisappear {
    objc_setAssociatedObject(self, @selector(ir_viewControllerDisappear), @(ir_viewControllerDisappear), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

#pragma clang diagnostic pop
