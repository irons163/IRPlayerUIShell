//
//  IRViewWraper.h
//  IRPlayerUIShell
//
//  Created by irons on 2019/10/24.
//  Copyright © 2019年 irons. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IRPlayer/IRPlayer.h>

//@import CoreMotion;

//@class deviceClass;

NS_ASSUME_NONNULL_BEGIN

@interface IRViewWraper : UIView<UIAlertViewDelegate>
{
    BOOL m_blnStopStreaming;
    BOOL m_blnSelected;
    IRMediaParameter* parameter;
    UIImageView *imageView;
    CALayer* borderLayer;
    dispatch_queue_t streamingQueue;
}
@property (weak, nonatomic) IRPlayerImp *m_player;

@property (retain, nonatomic) IBOutlet UIView *m_titleBackground;
@property (retain, nonatomic) IBOutlet UILabel *m_lblTitle;
@property (retain, nonatomic) IBOutlet UIView *m_relayTimerBackground;
@property (retain, nonatomic) IBOutlet UILabel *m_RelayTimerTitle;
@property (retain, nonatomic) IBOutlet UIView *m_videoView;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *m_LoadingActivity;
//@property (retain, nonatomic) RTSPReceiver *m_RTSPStreamer;
@property (retain, nonatomic) UIImageView *m_TmpShow;
@property (retain, nonatomic) IBOutlet UILabel *m_InfoLabel;
@property (nonatomic) double tagTime;
@property (nonatomic) BOOL doubleTapEnable;

-(void) setViewIsSelected:(BOOL) _blnSelected;
-(void) setShowBorder:(BOOL) _showBorder;
-(void) checkAuthorityAndSetOrientation:(UIInterfaceOrientation) _currentOrientation;

-(void)updateTimeLabelByTime:(double)time;

-(NSInteger) stopStreaming:(BOOL)_blnStopForever;

-(void) setOnOffReceiveData:(BOOL) _blnOn;
-(void) setZoomToNormal;

@end

NS_ASSUME_NONNULL_END
