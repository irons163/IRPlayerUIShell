#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIImageView+IRCache.h"
#import "UIScrollView+IRPlayer.h"
#import "UIView+IRFrame.h"
#import "IRGestureController+Private.h"
#import "IRGestureController.h"
#import "IRPlayerController.h"
#import "IRPlayerMediaControl.h"
#import "IRPlayerMediaPlayback.h"
#import "IRKVOController.h"
#import "IRMetamacros.h"
#import "IRNetworkSpeedMonitor.h"
#import "IROrientationObserver.h"
#import "IRPlayerControllerNotification.h"
#import "IRPlayerLogManager.h"
#import "IRReachabilityManager.h"
#import "IRScope.h"
#import "IRUtilities.h"
#import "IRFloatView.h"
#import "IRLandScapeControlView.h"
#import "IRLoadingView.h"
#import "IRPlayerControlView.h"
#import "IRPlayerView.h"
#import "IRPortraitControlView.h"
#import "IRSliderView.h"
#import "IRSmallFloatControlView.h"
#import "IRSpeedLoadingView.h"
#import "IRVolumeBrightnessView.h"
#import "IRPlayerUIShell.h"

FOUNDATION_EXPORT double IRPlayerUIShellVersionNumber;
FOUNDATION_EXPORT const unsigned char IRPlayerUIShellVersionString[];

