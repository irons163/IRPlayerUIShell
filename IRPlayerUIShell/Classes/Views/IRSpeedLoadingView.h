//
//  IRSpeedLoadingView.h
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/24.
//  Copyright © 2020 irons. All rights reserved.
//
//
//  ZFSpeedLoadingView.h
//  Pods-ZFPlayer_Example
//
//  Created by 紫枫 on 2018/6/27.
//

#import <UIKit/UIKit.h>
#import "IRLoadingView.h"

@interface IRSpeedLoadingView : UIView

@property (nonatomic, strong) IRLoadingView *loadingView;

@property (nonatomic, strong) UILabel *speedTextLabel;

/**
 *  Starts animation of the spinner.
 */
- (void)startAnimating;

/**
 *  Stops animation of the spinnner.
 */
- (void)stopAnimating;

@end
