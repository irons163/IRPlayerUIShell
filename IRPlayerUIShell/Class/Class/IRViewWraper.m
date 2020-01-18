//
//  IRViewWraper.m
//  IRPlayerUIShell
//
//  Created by irons on 2019/10/24.
//  Copyright © 2019年 irons. All rights reserved.
//

#import "IRViewWraper.h"
//#import "deviceClass.h"
//#import "dataDefine.h"
//#import "DeviceDBhandler.h"
//#import "VideoViewController.h"
#import "AppDelegate.h"
#ifdef EnVMS
#import "UIColor+Helper.h"
#endif

#define LOGIN_IPCAM_CALLBACK    0X0001
#define GET_RTSPINFO_CALLBACK   0X0010
#define GET_AUDIOOUT_CALLBACK   0X0100
#define GET_FISHEYE_CENTER_CALLBACK 0X1000

#define MinZoomScale 1.0
#define RangeY 20.0

#define Login_Failed_via_UID 18
#define Login_Failed_via_Direct_Access 19
#define Login_Failed_via_IP 20

#define ERROR_DEVICE_NOT_ONLINE -3

typedef NS_ENUM(NSUInteger, DemoType) {
    DemoType_AVPlayer_Normal = 0,
    DemoType_AVPlayer_VR,
    DemoType_AVPlayer_VR_Box,
    DemoType_FFmpeg_Normal,
    DemoType_FFmpeg_Normal_Hardware,
    DemoType_FFmpeg_Fisheye_Hardware,
    DemoType_FFmpeg_Fisheye_Hardware_Modes_Selection,
};

@interface IRViewWraper(PrivateMethod)

//@property (nonatomic, strong) IRPlayerImp * player;
@property (nonatomic, assign) DemoType demoType;

-(void) startTwoWayAudio:(BOOL)_blnToDevice;
-(void) stopTwoWayAudio:(BOOL)_blnToDevice;
-(void) parseInfoFile:(NSString *) _data;
-(void) setCameratitle:(NSString *) _title;
-(void) reconnectToDevice;
-(void) showAuthorityAlert;
-(void) startRecorcingAction;
-(void) adjustRecordingIconPos;
-(NSInteger) startStreaming;
-(void) showHideLoading:(BOOL)_connected MicSupport:(BOOL)_micSupport SpeakerSupport:(BOOL)_speakerSupport;
-(void) showRecordingExceptionMessageWithType:(NSInteger) _iExceptionType;
-(void) parseJSONCommand:(NSDictionary *) _jsonDictionary;
-(CGSize)imageSizeAfterAspectFit:(UIView*)view originImageSize:(CGSize)originImageSize;
-(void) showReconnectFailByType:(NSInteger) _iType;
-(void) showStreamingFailByType:(NSInteger) _iType;
#pragma mark - Wide Functions
-(BOOL)resetUnit;
-(void)stopMotionDetection;
-(float)convertToNewDegree:(float)degree withInitDegree:(float)initDegree;
@end

@implementation IRViewWraper

-(void)initStreamingQueue{
    if(!streamingQueue)
        streamingQueue = dispatch_queue_create("streaming.queue", DISPATCH_QUEUE_SERIAL);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initStreamingQueue];
        
//        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed:@"IRViewWraper" owner:self options:nil];
//        UIView *m_loadVew = [nibObjects objectAtIndex:0];
//        [m_loadVew setFrame:frame];
//
//        [self addSubview:m_loadVew];//add xib file into subview
        
        self.m_videoView = [[UIView alloc] init];
        [self addSubview:self.m_videoView];
        
        NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.m_videoView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
        NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.m_videoView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:self.m_videoView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:self.m_videoView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        top.active = YES;
        bottom.active = YES;
        left.active = YES;
        right.active = YES;
        self.m_videoView.translatesAutoresizingMaskIntoConstraints = NO;
        
        borderLayer = [[CALayer alloc] init];
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        borderLayer.frame = self.layer.bounds;
        [CATransaction commit];
        
        [self.layer addSublayer:borderLayer];
    }
    return self;
}

- (void)setM_player:(IRPlayerImp *)m_player {
    _m_player = m_player;
    
    //    self.m_player.view.frame = self.frame;
    
    //        ((KxMovieGLView*)self.m_videoView).delegate = self;
    
    imageView = [[UIImageView alloc] initWithFrame:self.m_player.view.frame];
    [self.m_player.view addSubview:imageView];
    [self.m_videoView insertSubview:self.m_player.view atIndex:0];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    top.active = YES;
    bottom.active = YES;
    left.active = YES;
    right.active = YES;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    top = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    bottom = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    left = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    right = [NSLayoutConstraint constraintWithItem:self.m_player.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.m_videoView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    top.active = YES;
    bottom.active = YES;
    left.active = YES;
    right.active = YES;
    self.m_player.view.translatesAutoresizingMaskIntoConstraints = NO;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue
                     forKey:kCATransactionDisableActions];
    borderLayer.frame = self.layer.bounds;
    [CATransaction commit];
}

-(void) setViewIsSelected:(BOOL) _blnSelected
{
    if(self.layer)
    {
        if(_blnSelected)
        {
            [borderLayer setBorderWidth:3.0f];
            [borderLayer setBorderColor:[[UIColor colorWithRed:27.0f/255.0f green:72.0f/255.0f blue:156.0f/255.0f alpha:1.0f] CGColor]];
            m_blnSelected = YES;
        }
        else
        {
            [CATransaction begin];
            [CATransaction setValue:(id)kCFBooleanTrue
                             forKey:kCATransactionDisableActions];
            [borderLayer setBorderWidth:0.0f];
            [CATransaction commit];
            m_blnSelected = NO;
        }
    }
    
//    ((KxMovieGLView*)self.m_videoView).singleTapEnable = m_blnSelected;
}

-(void) setShowBorder:(BOOL) _showBorder
{
    if(self.layer)
    {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue
                         forKey:kCATransactionDisableActions];
        if(_showBorder){
            [borderLayer setHidden:NO];
        }else{
            [borderLayer setHidden:YES];
        }
        
        [CATransaction commit];
    }
}

-(void)updateTimeLabelByTime:(double)time
{
    if (time <= 0) {
        self.m_relayTimerBackground.hidden = YES;
    }else{
#if (defined Relay_Limit) || (defined DEV)
        self.m_relayTimerBackground.hidden = NO;
#endif
        NSTimeInterval aTimer = time - [[NSDate date] timeIntervalSince1970];
        int minute = (int)(aTimer/60);
        int second = aTimer - minute*60;
        
        NSString* timeString = [NSString stringWithFormat:@"%02d:%02d",minute,second];
        self.m_RelayTimerTitle.text = [NSString stringWithFormat:@"RelayTimeOut %@",timeString];
    }
}

-(BOOL) doSnapShot
{
    BOOL blnRtn = YES;
//    [((KxMovieGLView*)self.m_videoView) doSnapShot];
    
    return blnRtn;
}

//set zoom in back to X1
-(void) setZoomToNormal
{
    [self stopMotionDetection];
//    [((KxMovieGLView*)self.m_videoView) updateViewPort:1.0f];
}

-(void) startShow
{
    [self.m_LoadingActivity startAnimating];
    
    [self stopMotionDetection];
}

//-(NSArray<IRGLRenderMode*>*) getRenderModes
//{
//    return [self.player renderModes];
//}
//
//-(IRGLRenderMode*) getCurrentRenderMode
//{
//    return [self.player renderMode];
//}
//
//-(void) setCurrentRenderMode:(IRGLRenderMode*)renderMode
//{
//    [self.player selectRenderMode:renderMode];
//    [self resetUnit];
//}

-(void)setDoubleTapEnable:(BOOL)doubleTapEnbale{
    _doubleTapEnable = doubleTapEnbale;
    
//    ((KxMovieGLView*)self.m_videoView).doubleTapEnable = _doubleTapEnable;
}

@end


@implementation IRViewWraper(PrivateMethod)

-(void) setCameratitle:(NSString *) _title
{
    [self.m_lblTitle setText:_title];
    [self.m_lblTitle setTextColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f]];
    [self.m_lblTitle setFont:[UIFont fontWithName:@"Helvetica" size:12.0f]];
    [self.m_lblTitle setHidden:NO];
}

@end

