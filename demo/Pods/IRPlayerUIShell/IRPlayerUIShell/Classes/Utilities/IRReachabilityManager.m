//
//  IRReachabilityManager.m
//  IRPlayerUIShell
//
//  Created by irons on 2020/2/23.
//  Copyright © 2020 irons. All rights reserved.
//
//
//  ZFReachabilityManager.m
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

#import "IRReachabilityManager.h"
#if !TARGET_OS_WATCH
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

NSString * const IRReachabilityDidChangeNotification = @"com.IRPlayer.reachability.change";
NSString * const IRReachabilityNotificationStatusItem = @"IRNetworkingReachabilityNotificationStatusItem";

typedef void (^IRReachabilityStatusBlock)(IRReachabilityStatus status);

NSString * IRStringFromNetworkReachabilityStatus(IRReachabilityStatus status) {
    switch (status) {
        case IRReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"IRPlayer", nil);
        case IRReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"IRPlayer", nil);
        case IRReachabilityStatusReachableVia2G:
            return NSLocalizedStringFromTable(@"Reachable via 2G", @"IRPlayer", nil);
        case IRReachabilityStatusReachableVia3G:
            return NSLocalizedStringFromTable(@"Reachable via 3G", @"IRPlayer", nil);
        case IRReachabilityStatusReachableVia4G:
            return NSLocalizedStringFromTable(@"Reachable via 4G", @"IRPlayer", nil);
        case IRReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"IRPlayer", nil);
    }
}

static IRReachabilityStatus IRReachabilityStatusForFlags(SCNetworkReachabilityFlags flags) {
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));
    
    IRReachabilityStatus status = IRReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = IRReachabilityStatusNotReachable;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentRadioAccessTechnology = info.currentRadioAccessTechnology;
        if (currentRadioAccessTechnology) {
            if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
                status = IRReachabilityStatusReachableVia4G;
            } else if ([currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] || [currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS]) {
                status = IRReachabilityStatusReachableVia2G;
            } else {
                status = IRReachabilityStatusReachableVia3G;
            }
        }
    }
#endif
    else {
        status = IRReachabilityStatusReachableViaWiFi;
    }
    return status;
    
}

/**
 * Queue a status change notification for the main thread.
 *
 * This is done to ensure that the notifications are received in the same order
 * as they are sent. If notifications are sent directly, it is possible that
 * a queued notification (for an earlier status condition) is processed after
 * the later update, resulting in the listener being left in the wrong state.
 */
static void IRPostReachabilityStatusChange(SCNetworkReachabilityFlags flags, IRReachabilityStatusBlock block) {
    IRReachabilityStatus status = IRReachabilityStatusForFlags(flags);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) block(status);
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ IRReachabilityNotificationStatusItem: @(status) };
        [notificationCenter postNotificationName:IRReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static void AFNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info) {
    IRPostReachabilityStatusChange(flags, (__bridge IRReachabilityStatusBlock)info);
}


static const void * IRReachabilityRetainCallback(const void *info) {
    return Block_copy(info);
}

static void IRReachabilityReleaseCallback(const void *info) {
    if (info) {
        Block_release(info);
    }
}

@interface IRReachabilityManager ()

@property (readonly, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) IRReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) IRReachabilityStatusBlock networkReachabilityStatusBlock;

@end

@implementation IRReachabilityManager

+ (instancetype)sharedManager {
    static IRReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [self manager];
    });
    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);
    IRReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return manager;
}

+ (instancetype)managerForAddress:(const void *)address {
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);
    IRReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    CFRelease(reachability);
    return manager;
}

+ (instancetype)manager {
#if (defined(__IPHONE_OS_VERSION_MIN_REQUIRED) && __IPHONE_OS_VERSION_MIN_REQUIRED >= 90000) || (defined(__MAC_OS_X_VERSION_MIN_REQUIRED) && __MAC_OS_X_VERSION_MIN_REQUIRED >= 101100)
    struct sockaddr_in6 address;
    bzero(&address, sizeof(address));
    address.sin6_len = sizeof(address);
    address.sin6_family = AF_INET6;
#else
    struct sockaddr_in address;
    bzero(&address, sizeof(address));
    address.sin_len = sizeof(address);
    address.sin_family = AF_INET;
#endif
    return [self managerForAddress:&address];
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability {
    self = [super init];
    if (!self) {
        return nil;
    }
    _networkReachability = CFRetain(reachability);
    self.networkReachabilityStatus = IRReachabilityStatusUnknown;
    
    return self;
}

- (instancetype)init NS_UNAVAILABLE
{
    return nil;
}

- (void)dealloc {
    [self stopMonitoring];
    if (_networkReachability != NULL) {
        CFRelease(_networkReachability);
    }
}

#pragma mark -

- (BOOL)isReachable {
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN {
    return (self.networkReachabilityStatus == IRReachabilityStatusReachableVia2G ||self.networkReachabilityStatus == IRReachabilityStatusReachableVia3G || self.networkReachabilityStatus == IRReachabilityStatusReachableVia4G);
}

- (BOOL)isReachableViaWiFi {
    return self.networkReachabilityStatus == IRReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring {
    [self stopMonitoring];
    if (!self.networkReachability) {
        return;
    }
    
    __weak __typeof(self)weakSelf = self;
    IRReachabilityStatusBlock callback = ^(IRReachabilityStatus status) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }
    };
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, IRReachabilityRetainCallback, IRReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, AFNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),^{
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(self.networkReachability, &flags)) {
            IRPostReachabilityStatusChange(flags, callback);
        }
    });
}

- (void)stopMonitoring {
    if (!self.networkReachability) {
        return;
    }
    
    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString {
    return IRStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(IRReachabilityStatus status))block {
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }
    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
#endif
