//
//  UIView+IRFrame.m
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/24.
//  Copyright © 2020 irons. All rights reserved.
//
//
//  UIView+ZFFrame.m
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

#import "UIView+IRFrame.h"

@implementation UIView (IRFrame)

- (CGFloat)ir_x {
    return self.frame.origin.x;
}

- (void)setIr_x:(CGFloat)ir_x {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = ir_x;
    self.frame        = newFrame;
}

- (CGFloat)ir_y {
    return self.frame.origin.y;
}

- (void)setIr_y:(CGFloat)ir_y {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = ir_y;
    self.frame        = newFrame;
}

- (CGFloat)ir_width {
    return CGRectGetWidth(self.bounds);
}

- (void)setIr_width:(CGFloat)ir_width {
    CGRect newFrame     = self.frame;
    newFrame.size.width = ir_width;
    self.frame          = newFrame;
}

- (CGFloat)ir_height {
    return CGRectGetHeight(self.bounds);
}

- (void)setIr_height:(CGFloat)ir_height {
    CGRect newFrame      = self.frame;
    newFrame.size.height = ir_height;
    self.frame           = newFrame;
}

- (CGFloat)ir_top {
    return self.frame.origin.y;
}

- (void)setIr_top:(CGFloat)ir_top {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = ir_top;
    self.frame        = newFrame;
}

- (CGFloat)ir_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setIr_bottom:(CGFloat)ir_bottom {
    CGRect newFrame   = self.frame;
    newFrame.origin.y = ir_bottom - self.frame.size.height;
    self.frame        = newFrame;
}

- (CGFloat)ir_left {
    return self.frame.origin.x;
}

- (void)setIr_left:(CGFloat)ir_left {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = ir_left;
    self.frame        = newFrame;
}

- (CGFloat)ir_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setIr_right:(CGFloat)ir_right {
    CGRect newFrame   = self.frame;
    newFrame.origin.x = ir_right - self.frame.size.width;
    self.frame        = newFrame;
}

- (CGFloat)ir_centerX {
    return self.center.x;
}

- (void)setIr_centerX:(CGFloat)ir_centerX {
    CGPoint newCenter = self.center;
    newCenter.x       = ir_centerX;
    self.center       = newCenter;
}

- (CGFloat)ir_centerY {
    return self.center.y;
}

- (void)setIr_centerY:(CGFloat)ir_centerY {
    CGPoint newCenter = self.center;
    newCenter.y       = ir_centerY;
    self.center       = newCenter;
}

- (CGPoint)ir_origin {
    return self.frame.origin;
}

- (void)setIr_origin:(CGPoint)ir_origin {
    CGRect newFrame = self.frame;
    newFrame.origin = ir_origin;
    self.frame      = newFrame;
}

- (CGSize)ir_size {
    return self.frame.size;
}

- (void)setIr_size:(CGSize)ir_size {
    CGRect newFrame = self.frame;
    newFrame.size   = ir_size;
    self.frame      = newFrame;
}

@end
