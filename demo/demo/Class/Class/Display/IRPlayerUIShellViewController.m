//
//  IRPlayerUIShellViewController.m
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/24.
//  Copyright © 2020 irons. All rights reserved.
//

#import "IRPlayerUIShellViewController.h"
#import <IRPlayer/IRPlayer.h>
#import <IRPlayerUIShell/IRPlayerUIShell.h>
#import <IRPlayer/IRScope.h>
#import "IRPlayerWithMediaPlayback.h"

static NSString *kVideoCover = @"https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240";

@interface IRPlayerUIShellViewController ()
@property (nonatomic, strong) IRPlayerWithMediaPlayback * playerImp;
@property (nonatomic, strong) IRPlayerController *player;
@property (nonatomic, strong) UIImageView *containerView;
@property (nonatomic, strong) IRPlayerControlView *controlView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *changeBtn;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) NSArray <NSURL *>*assetURLs;

@end

@implementation IRPlayerUIShellViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    static NSURL * normalVideo = nil;
    static NSURL * vrVideo = nil;
    static NSURL * fisheyeVideo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        normalVideo = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"i-see-fire" ofType:@"mp4"]];
        vrVideo = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"google-help-vr" ofType:@"mp4"]];
        fisheyeVideo = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"fisheye-demo" ofType:@"mp4"]];
    });
    
    self.playerImp = [IRPlayerWithMediaPlayback player];
    [self.playerImp setViewTapAction:^(IRPlayerImp * _Nonnull player, IRPLFView * _Nonnull view) {
        NSLog(@"player display view did click!");
    }];
    self.playerImp.decoder = [IRPlayerDecoder FFmpegDecoder];
    [self.playerImp replaceVideoWithURL:normalVideo];
    
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.playBtn];
    [self.view addSubview:self.changeBtn];
    [self.view addSubview:self.nextBtn];

    self.player = [IRPlayerController playerWithPlayerManager:self.playerImp containerView:self.containerView];
    self.player.controlView = self.controlView;
    /// 设置退到后台继续播放
    self.player.pauseWhenAppResignActive = NO;
//    self.player.forceDeviceOrientation = YES;
    
    [self.playerImp registerPlayerNotificationTarget:self
       stateAction:@selector(stateAction:)
    progressAction:@selector(progressAction:)
    playableAction:@selector(playableAction:)
       errorAction:@selector(errorAction:)];
    
    @weakify(self)
    self.player.orientationWillChange = ^(IRPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController.navigationBar setNeedsLayout];
            [self.navigationController.navigationBar layoutIfNeeded];
            [self.navigationController.navigationBar setNeedsDisplay];
            [self.navigationController.navigationBar updateConstraints];
        });
    };
    
    self.player.orientationIsChanging = ^(IRPlayerController * _Nonnull player, BOOL isFullScreen) {

    };
    
    self.player.orientationDidChanged = ^(IRPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self setupUI];
    };
    
    /// 播放完成
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        [self.player.currentPlayerManager pause];
        [self.player.currentPlayerManager play];
        
        [self.player playTheNext];
        if (!self.player.isLastAssetURL) {
            NSString *title = [NSString stringWithFormat:@"title:%zd",self.player.currentPlayIndex];
            [self.controlView showTitle:title coverURLString:kVideoCover fullScreenMode:IRFullScreenModeLandscape];
        } else {
            [self.player stop];
        }
    };
    
    self.player.assetURLs = self.assetURLs;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.player.viewControllerDisappear = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.player.viewControllerDisappear = YES;
}

- (void)setupUI {
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w*9/16;
    self.containerView.frame = CGRectMake(x, y, w, h);
    
    w = 44;
    h = w;
    x = (CGRectGetWidth(self.containerView.frame)-w)/2;
    y = (CGRectGetHeight(self.containerView.frame)-h)/2;
    self.playBtn.frame = CGRectMake(x, y, w, h);
    
    w = 100;
    h = 30;
    x = (CGRectGetWidth(self.view.frame)-w)/2;
    y = CGRectGetMaxY(self.containerView.frame)+50;
    self.changeBtn.frame = CGRectMake(x, y, w, h);
    
    w = 100;
    h = 30;
    x = (CGRectGetWidth(self.view.frame)-w)/2;
    y = CGRectGetMaxY(self.changeBtn.frame)+50;
    self.nextBtn.frame = CGRectMake(x, y, w, h);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    [self setupUI];
}

- (void)changeVideo:(UIButton *)sender {
    NSString *URLString = @"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4";
    self.player.assetURL = [NSURL URLWithString:URLString];
    [self.controlView showTitle:@"Apple" coverURLString:kVideoCover fullScreenMode:IRFullScreenModeAutomatic];
}

- (void)playClick:(UIButton *)sender {
    [self.player playTheIndex:0];
    [self.controlView showTitle:@"Video Title" coverURLString:kVideoCover fullScreenMode:IRFullScreenModeAutomatic];
}

- (void)nextClick:(UIButton *)sender {
    if (!self.player.isLastAssetURL) {
        [self.player playTheNext];
        NSString *title = [NSString stringWithFormat:@"Video index:%zd",self.player.currentPlayIndex];
        [self.controlView showTitle:title coverURLString:kVideoCover fullScreenMode:IRFullScreenModeAutomatic];
    } else {
        NSLog(@"Last Video");
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)shouldAutorotate {
    return self.player.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (IRPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [IRPlayerControlView new];
        _controlView.fastViewAnimated = YES;
        _controlView.autoHiddenTimeInterval = 5;
        _controlView.autoFadeTimeInterval = 0.5;
        _controlView.prepareShowLoading = YES;
        _controlView.prepareShowControlView = YES;
    }
    return _controlView;
}

- (UIImageView *)containerView {
    if (!_containerView) {
        _containerView = [UIImageView new];
        [_containerView setImageWithURLString:kVideoCover placeholder:[IRUtilities imageWithColor:[UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1] size:CGSizeMake(1, 1)]];
    }
    return _containerView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:IRPlayer_Image(@"new_allPlay_44x44_") forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)changeBtn {
    if (!_changeBtn) {
        _changeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_changeBtn setTitle:@"Change video" forState:UIControlStateNormal];
        [_changeBtn addTarget:self action:@selector(changeVideo:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeBtn;
}

- (UIButton *)nextBtn {
    if (!_nextBtn) {
        _nextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_nextBtn setTitle:@"Next" forState:UIControlStateNormal];
        [_nextBtn addTarget:self action:@selector(nextClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (NSArray<NSURL *> *)assetURLs {
    if (!_assetURLs) {
            _assetURLs = @[[NSURL URLWithString:@"https://www.apple.com/105/media/us/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-tpl-cc-us-20170912_1280x720h.mp4"],
          [NSURL URLWithString:@"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"],
          [NSURL URLWithString:@"https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/peter/mac-peter-tpl-cc-us-2018_1280x720h.mp4"],
          [NSURL URLWithString:@"https://www.apple.com/105/media/us/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/grimes/mac-grimes-tpl-cc-us-2018_1280x720h.mp4"],
          [NSURL URLWithString:@"http://www.flashls.org/playlists/test_001/stream_1000k_48k_640x360.m3u8"],
          [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-video/7_517c8948b166655ad5cfb563cc7fbd8e.mp4"],
          [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/68_20df3a646ab5357464cd819ea987763a.mp4"],
          [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/118_570ed13707b2ccee1057099185b115bf.mp4"],
          [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/15_ad895ac5fb21e5e7655556abee3775f8.mp4"],
          [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/12_cc75b3fb04b8a23546d62e3f56619e85.mp4"],
          [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-smallvideo/5_6d3243c354755b781f6cc80f60756ee5.mp4"],
                           [NSURL URLWithString:@"http://tb-video.bdstatic.com/tieba-movideo/11233547_ac127ce9e993877dce0eebceaa04d6c2_593d93a619b0.mp4"]];
    }
    return _assetURLs;
}

#pragma mark - PlayerNotification
- (void)stateAction:(NSNotification *)notification {
    [self dealWithNotification:notification Player:self.playerImp];
}

- (void)progressAction:(NSNotification *)notification {
    if ([self.controlView respondsToSelector:@selector(videoPlayer:currentTime:totalTime:)]) {
        IRProgress * progress = [IRProgress progressFromUserInfo:notification.userInfo];
        [self.controlView videoPlayer:self.player currentTime:progress.current totalTime:progress.total];
    }
}

- (NSString *)timeStringFromSeconds:(CGFloat)seconds {
    return [NSString stringWithFormat:@"%ld:%.2ld", (long)seconds / 60, (long)seconds % 60];
}

- (void)playableAction:(NSNotification *)notification {
    IRPlayable * playable = [IRPlayable playableFromUserInfo:notification.userInfo];
    NSLog(@"playable time : %f", playable.current);
}

- (void)errorAction:(NSNotification *)notification {
    IRError * error = [IRError errorFromUserInfo:notification.userInfo];
    NSLog(@"player did error : %@", error.error);
}

- (void)dealWithNotification:(NSNotification *)notification Player:(IRPlayerImp *)player {
    IRState * state = [IRState stateFromUserInfo:notification.userInfo];
    
    switch (state.current) {
        case IRPlayerStateNone:
            NSLog(@"None");
            break;
        case IRPlayerStateBuffering:
            NSLog(@"Buffering...");
            
            if (self.playerImp.playerReadyToPlay) self.playerImp.playerPrepareToPlay(self.playerImp, player.contentURL);
            break;
        case IRPlayerStateReadyToPlay:
            NSLog(@"Prepare");
            
            if (self.playerImp.playerReadyToPlay) self.playerImp.playerReadyToPlay(self.playerImp, player.contentURL);
            break;
        case IRPlayerStatePlaying:
            NSLog(@"Playing");
            if ([self.controlView respondsToSelector:@selector(videoPlayer:loadStateChanged:)]) {
                [self.controlView videoPlayer:self.player loadStateChanged:IRPlayerLoadStatePlaythroughOK];
            }
            break;
        case IRPlayerStateSuspend:
            NSLog(@"Suspend");
            break;
        case IRPlayerStateFinished:
            NSLog(@"Finished");
            break;
        case IRPlayerStateFailed:
            NSLog(@"Error");
            if ([self.controlView respondsToSelector:@selector(videoPlayerPlayFailed:error:)]) {
                IRError *error = [IRError errorFromUserInfo:notification.userInfo];
                [self.controlView videoPlayerPlayFailed:self.player error:error];
            }
            break;
    }
}

@end
