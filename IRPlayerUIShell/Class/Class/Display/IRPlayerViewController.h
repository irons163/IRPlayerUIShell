//
//  IRPlayerViewController.h
//  IRPlayerUIShell
//
//  Created by irons on 2019/11/2.
//  Copyright © 2019年 irons. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRViewWraper.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, IRPlayerDisplayerMode) {
    IRPlayerDisplayerSingleMode,
    IRPlayerDisplayerQuadMode
};

@interface IRPlayerViewController : UIViewController {
    NSInteger m_intCurrentCh;
    NSMutableArray *m_aryVideoView;
    
    __weak IBOutlet NSLayoutConstraint *m_firstViewConstraint;
    __weak IBOutlet NSLayoutConstraint *m_secondViewConstraint;
    __weak IBOutlet NSLayoutConstraint *m_thirdViewConstraint;
    __weak IBOutlet NSLayoutConstraint *m_fourthViewConstraint;
    __weak IBOutlet UIView *m_firstView;
    __weak IBOutlet UIView *m_secondView;
    __weak IBOutlet UIView *m_thirdView;
    __weak IBOutlet UIView *m_fourthView;
    IRViewWraper *m_firstVideoView;
    IRViewWraper *m_secondVideoView;
    IRViewWraper *m_thirdVideoView;
    IRViewWraper *m_fourthVideoView;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *m_LoadingActivity;
@property (weak, nonatomic) IBOutlet IRPlayerImp *m_videoView;
@property (weak, nonatomic) IBOutlet UILabel *m_InfoLabel;
@property (nonatomic) IRPlayerDisplayerMode displayMode;

@end

NS_ASSUME_NONNULL_END
