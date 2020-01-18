//
//  IRPlayerViewController.m
//  IRPlayerUIShell
//
//  Created by irons on 2019/11/2.
//  Copyright © 2019年 irons. All rights reserved.
//

#import "IRPlayerViewController.h"
#import <OpenGLES/gltypes.h>
#import <UIKit/UIKit.h>
#import "NSLayoutConstraint+Multiplier.h"
//#import "IRRTSPSettingsViewController.h"
//#import "IRStreamConnectionRequestFactory.h"

@interface IRPlayerViewController()

@property (nonatomic, strong) IRPlayerImp * player;
@property (nonatomic, strong) IRPlayerImp * player2;
@property (nonatomic, strong) IRPlayerImp * player3;
@property (nonatomic, strong) IRPlayerImp * player4;

@end

@implementation IRPlayerViewController {
    UIImageView *imageView;
    NSMutableArray *m_aryStreamInfo;
    NSMutableArray *m_aryDevices;
}

@synthesize m_LoadingActivity;

-(void)dealloc{
//    [self stopAllStreams:YES];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
//    m_aryDevices = [NSMutableArray arrayWithArray:[IRStreamConnectionRequestFactory createStreamConnectionRequest]];
    m_intCurrentCh = 0;
    
    static NSURL * normalVideo = nil;
    static NSURL * vrVideo = nil;
    static NSURL * fisheyeVideo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        normalVideo = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"i-see-fire" ofType:@"mp4"]];
        vrVideo = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"google-help-vr" ofType:@"mp4"]];
        fisheyeVideo = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fisheye-demo" ofType:@"mp4"]];
    });
    
    self.player = [IRPlayerImp player];
    [self.player registerPlayerNotificationTarget:self
                                      stateAction:@selector(stateAction:)
                                   progressAction:@selector(progressAction:)
                                   playableAction:@selector(playableAction:)
                                      errorAction:@selector(errorAction:)];
    [self.player setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player.decoder = [IRPlayerDecoder FFmpegDecoder];
    [self.player replaceVideoWithURL:normalVideo];
    
    self.player2 = [IRPlayerImp player];
    [self.player2 registerPlayerNotificationTarget:self
                                       stateAction:@selector(player2stateAction:)
                                    progressAction:@selector(player2progressAction:)
                                    playableAction:@selector(player2playableAction:)
                                       errorAction:@selector(player2errorAction:)];
    [self.player2 setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player2.decoder = [IRPlayerDecoder FFmpegDecoder];
    [self.player2 replaceVideoWithURL:normalVideo];
    
    self.player3 = [IRPlayerImp player];
    [self.player3 registerPlayerNotificationTarget:self
                                       stateAction:@selector(player3stateAction:)
                                    progressAction:@selector(player3progressAction:)
                                    playableAction:@selector(player3playableAction:)
                                       errorAction:@selector(player3errorAction:)];
    [self.player3 setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player3.decoder = [IRPlayerDecoder FFmpegDecoder];
    [self.player3 replaceVideoWithURL:normalVideo];
    
    self.player4 = [IRPlayerImp player];
    [self.player4 registerPlayerNotificationTarget:self
                                       stateAction:@selector(player4stateAction:)
                                    progressAction:@selector(player4progressAction:)
                                    playableAction:@selector(player4playableAction:)
                                       errorAction:@selector(player4errorAction:)];
    [self.player4 setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.player4.decoder = [IRPlayerDecoder FFmpegDecoder];
    [self.player4 replaceVideoWithURL:normalVideo];
    
    [self initVideoView];
//    [self startStreamConnectionByDeviceIndex:0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
}

-(void) initVideoView
{
    [self addVideoViewToBlock];
    
    m_aryVideoView = [[NSMutableArray alloc] initWithCapacity:0];
    [m_aryVideoView addObject:m_firstView];
    [m_aryVideoView addObject:m_secondView];
    [m_aryVideoView addObject:m_thirdView];
    [m_aryVideoView addObject:m_fourthView];
    
    [self setBlockShowOrHide:NO];
    [self resizeViewBlock];
}

//show or hide video view block (usually when change display mode
-(void) setBlockShowOrHide:(BOOL)_blnFromViewDidLoad
{
    for (NSInteger index=0; index < [m_aryVideoView count]; index++)
    {
        BOOL blnHide = NO;
        
        if(_displayMode == IRPlayerDisplayerSingleMode && index != m_intCurrentCh)
        {
            blnHide = YES;
        }
        
        UIView *tmpView = [m_aryVideoView objectAtIndex:index];
        [tmpView setHidden:blnHide];
    }
}

//add videoViewSingle to each block
-(void) addVideoViewToBlock
{
    for (NSInteger i = 0 ; i < 4; i++) {
        [self addVideoViewToBlockByCh:i];
    }
}

//add videoViewSingle to block by position
-(void) addVideoViewToBlockByCh:(NSInteger) _ch
{
    if(_ch == 0)
    {
        m_firstVideoView = [[IRViewWraper alloc] init];
        m_firstVideoView.m_player = self.player;
        //        m_firstVideoView.m_videoView.tag = 1;
        m_firstVideoView.doubleTapEnable = YES;
        [m_firstView addSubview:m_firstVideoView];
        
        m_firstVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_firstVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_firstView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
    }
    else if(_ch == 1)
    {
        m_secondVideoView = [[IRViewWraper alloc] init];
        m_secondVideoView.m_player = self.player2;
        //        m_secondVideoView.m_videoView.tag = 2;
        m_secondVideoView.doubleTapEnable = YES;
        [m_secondView addSubview:m_secondVideoView];
        
        m_secondVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_secondVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_secondView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
        
    }
    else if(_ch == 2)
    {
        m_thirdVideoView = [[IRViewWraper alloc] init];
        m_thirdVideoView.m_player = self.player3;
        //        m_thirdVideoView.m_videoView.tag = 3;
        m_thirdVideoView.doubleTapEnable = YES;
        [m_thirdView addSubview:m_thirdVideoView];
        
        m_thirdVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_thirdVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_thirdView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
        
    }
    else if(_ch == 3)
    {
        m_fourthVideoView = [[IRViewWraper alloc] init];
        m_fourthVideoView.m_player = self.player4;
        //        m_fourthVideoView.m_videoView.tag = 4;
        m_fourthVideoView.doubleTapEnable = YES;
        [m_fourthView addSubview:m_fourthVideoView];
        
        m_fourthVideoView.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:m_fourthVideoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:m_fourthView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
    }
}

//resize view block (usually when change display mode, rotate screen)
-(void) resizeViewBlock
{
    if(_displayMode == IRPlayerDisplayerSingleMode)
    {
        switch (m_intCurrentCh) {
            case 0:
                m_firstViewConstraint = [m_firstViewConstraint updateMultiplier:1.0f];
                break;
            case 1:
                m_secondViewConstraint = [m_secondViewConstraint updateMultiplier:1.0f];
                break;
            case 2:
                m_thirdViewConstraint = [m_thirdViewConstraint updateMultiplier:1.0f];
                break;
            case 3:
                m_fourthViewConstraint = [m_fourthViewConstraint updateMultiplier:1.0f];
                break;
            default:
                break;
        }
    }
    else
    {
        m_firstViewConstraint = [m_firstViewConstraint updateMultiplier:0.5f];
        m_secondViewConstraint = [m_secondViewConstraint updateMultiplier:0.5f];
        m_thirdViewConstraint = [m_thirdViewConstraint updateMultiplier:0.5f];
        m_fourthViewConstraint = [m_fourthViewConstraint updateMultiplier:0.5f];
    }
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    IRRTSPSettingsViewController *vc = [segue destinationViewController];
//    vc.delegate = self;
//}

-(void)unwindForSegue:(UIStoryboardSegue *)unwindSegue towardsViewController:(UIViewController *)subsequentVC{
    
}

- (void)dealWithNotification:(NSNotification *)notification Player:(IRPlayerImp *)player {
    IRState * state = [IRState stateFromUserInfo:notification.userInfo];
    
    NSString * text;
    switch (state.current) {
        case IRPlayerStateNone:
            text = @"None";
            break;
        case IRPlayerStateBuffering:
            text = @"Buffering...";
            break;
        case IRPlayerStateReadyToPlay:
            text = @"Prepare";
            //            self.totalTimeLabel.text = [self timeStringFromSeconds:self.player.duration];
            [player play];
            break;
        case IRPlayerStatePlaying:
            text = @"Playing";
            break;
        case IRPlayerStateSuspend:
            text = @"Suspend";
            break;
        case IRPlayerStateFinished:
            text = @"Finished";
            break;
        case IRPlayerStateFailed:
            text = @"Error";
            break;
    }
    //    self.stateLabel.text = text;
}

//-(void)updatedSettings:(DeviceClass *)device{
//    m_aryDevices = [NSMutableArray arrayWithArray:[IRStreamConnectionRequestFactory createStreamConnectionRequest]];
//
//    [self startStreamConnectionByDeviceIndex:0];
//}

- (void)stateAction:(NSNotification *)notification
{
    [self dealWithNotification:notification Player:self.player];
}

- (void)progressAction:(NSNotification *)notification
{
    //    IRProgress * progress = [IRProgress progressFromUserInfo:notification.userInfo];
    //    if (!self.progressSilderTouching) {
    //        self.progressSilder.value = progress.percent;
    //    }
    //    self.currentTimeLabel.text = [self timeStringFromSeconds:progress.current];
}

- (void)playableAction:(NSNotification *)notification
{
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)errorAction:(NSNotification *)notification
{
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

- (NSString *)timeStringFromSeconds:(CGFloat)seconds
{
    return [NSString stringWithFormat:@"%ld:%.2ld", (long)seconds / 60, (long)seconds % 60];
}

- (void)player2stateAction:(NSNotification *)notification
{
    [self dealWithNotification:notification Player:self.player2];
}

- (void)player2progressAction:(NSNotification *)notification
{
}

- (void)player2playableAction:(NSNotification *)notification
{
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)player2errorAction:(NSNotification *)notification
{
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

- (void)player3stateAction:(NSNotification *)notification
{
    [self dealWithNotification:notification Player:self.player3];
}

- (void)player3progressAction:(NSNotification *)notification
{
}

- (void)player3playableAction:(NSNotification *)notification
{
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)player3errorAction:(NSNotification *)notification
{
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

- (void)player4stateAction:(NSNotification *)notification
{
    [self dealWithNotification:notification Player:self.player4];
}

- (void)player4progressAction:(NSNotification *)notification
{
}

- (void)player4playableAction:(NSNotification *)notification
{
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)player4errorAction:(NSNotification *)notification
{
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

@end

