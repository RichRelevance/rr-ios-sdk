//
//  Copyright (c) 2016 Rich Relevance Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "RCHNetworkReachabilityManager.h"

#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

NSString *const RCHNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
NSString *const RCHNetworkingReachabilityNotificationStatusItem = @"RCHNetworkingReachabilityNotificationStatusItem";

typedef void (^RCHNetworkReachabilityStatusBlock)(RCHNetworkReachabilityStatus status);

typedef NS_ENUM(NSUInteger, RCHNetworkReachabilityAssociation) {
    RCHNetworkReachabilityForAddress = 1,
    RCHNetworkReachabilityForAddressPair = 2,
    RCHNetworkReachabilityForName = 3,
};

NSString *RCHStringFromNetworkReachabilityStatus(RCHNetworkReachabilityStatus status)
{
    switch (status) {
        case RCHNetworkReachabilityStatusNotReachable:
            return NSLocalizedStringFromTable(@"Not Reachable", @"RCHNetworking", nil);
        case RCHNetworkReachabilityStatusReachableViaWWAN:
            return NSLocalizedStringFromTable(@"Reachable via WWAN", @"RCHNetworking", nil);
        case RCHNetworkReachabilityStatusReachableViaWiFi:
            return NSLocalizedStringFromTable(@"Reachable via WiFi", @"RCHNetworking", nil);
        case RCHNetworkReachabilityStatusUnknown:
        default:
            return NSLocalizedStringFromTable(@"Unknown", @"RCHNetworking", nil);
    }
}

static RCHNetworkReachabilityStatus RCHNetworkReachabilityStatusForFlags(SCNetworkReachabilityFlags flags)
{
    BOOL isReachable = ((flags & kSCNetworkReachabilityFlagsReachable) != 0);
    BOOL needsConnection = ((flags & kSCNetworkReachabilityFlagsConnectionRequired) != 0);
    BOOL canConnectionAutomatically = (((flags & kSCNetworkReachabilityFlagsConnectionOnDemand) != 0) || ((flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0));
    BOOL canConnectWithoutUserInteraction = (canConnectionAutomatically && (flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0);
    BOOL isNetworkReachable = (isReachable && (!needsConnection || canConnectWithoutUserInteraction));

    RCHNetworkReachabilityStatus status = RCHNetworkReachabilityStatusUnknown;
    if (isNetworkReachable == NO) {
        status = RCHNetworkReachabilityStatusNotReachable;
    }
#if TARGET_OS_IPHONE
    else if ((flags & kSCNetworkReachabilityFlagsIsWWAN) != 0) {
        status = RCHNetworkReachabilityStatusReachableViaWWAN;
    }
#endif
    else {
        status = RCHNetworkReachabilityStatusReachableViaWiFi;
    }

    return status;
}

static void RCHNetworkReachabilityCallback(SCNetworkReachabilityRef __unused target, SCNetworkReachabilityFlags flags, void *info)
{
    RCHNetworkReachabilityStatus status = RCHNetworkReachabilityStatusForFlags(flags);
    RCHNetworkReachabilityStatusBlock block = (__bridge RCHNetworkReachabilityStatusBlock)info;
    if (block) {
        block(status);
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        NSDictionary *userInfo = @{ RCHNetworkingReachabilityNotificationStatusItem : @(status) };
        [notificationCenter postNotificationName:RCHNetworkingReachabilityDidChangeNotification object:nil userInfo:userInfo];
    });
}

static const void *RCHNetworkReachabilityRetainCallback(const void *info)
{
    return Block_copy(info);
}

static void RCHNetworkReachabilityReleaseCallback(const void *info)
{
    if (info) {
        Block_release(info);
    }
}

@interface RCHNetworkReachabilityManager ()
@property (readwrite, nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (readwrite, nonatomic, assign) RCHNetworkReachabilityAssociation networkReachabilityAssociation;
@property (readwrite, nonatomic, assign) RCHNetworkReachabilityStatus networkReachabilityStatus;
@property (readwrite, nonatomic, copy) RCHNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@implementation RCHNetworkReachabilityManager

+ (instancetype)sharedManager
{
    static RCHNetworkReachabilityManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        struct sockaddr_in address;
        bzero(&address, sizeof(address));
        address.sin_len = sizeof(address);
        address.sin_family = AF_INET;

        _sharedManager = [self managerForAddress:&address];
    });

    return _sharedManager;
}

+ (instancetype)managerForDomain:(NSString *)domain
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, [domain UTF8String]);

    RCHNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = RCHNetworkReachabilityForName;

    return manager;
}

+ (instancetype)managerForAddress:(const void *)address
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)address);

    RCHNetworkReachabilityManager *manager = [[self alloc] initWithReachability:reachability];
    manager.networkReachabilityAssociation = RCHNetworkReachabilityForAddress;

    return manager;
}

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.networkReachability = reachability;
    self.networkReachabilityStatus = RCHNetworkReachabilityStatusUnknown;

    return self;
}

- (void)dealloc
{
    [self stopMonitoring];

    if (_networkReachability) {
        CFRelease(_networkReachability);
        _networkReachability = NULL;
    }
}

#pragma mark -

- (BOOL)isReachable
{
    return [self isReachableViaWWAN] || [self isReachableViaWiFi];
}

- (BOOL)isReachableViaWWAN
{
    return self.networkReachabilityStatus == RCHNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)isReachableViaWiFi
{
    return self.networkReachabilityStatus == RCHNetworkReachabilityStatusReachableViaWiFi;
}

#pragma mark -

- (void)startMonitoring
{
    [self stopMonitoring];

    if (!self.networkReachability) {
        return;
    }

    __weak __typeof(self) weakSelf = self;
    RCHNetworkReachabilityStatusBlock callback = ^(RCHNetworkReachabilityStatus status) {
        __strong __typeof(weakSelf) strongSelf = weakSelf;

        strongSelf.networkReachabilityStatus = status;
        if (strongSelf.networkReachabilityStatusBlock) {
            strongSelf.networkReachabilityStatusBlock(status);
        }

    };

    SCNetworkReachabilityContext context = {0, (__bridge void *)callback, RCHNetworkReachabilityRetainCallback, RCHNetworkReachabilityReleaseCallback, NULL};
    SCNetworkReachabilitySetCallback(self.networkReachability, RCHNetworkReachabilityCallback, &context);
    SCNetworkReachabilityScheduleWithRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);

    switch (self.networkReachabilityAssociation) {
        case RCHNetworkReachabilityForName:
            break;
        case RCHNetworkReachabilityForAddress:
        case RCHNetworkReachabilityForAddressPair:
        default: {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                SCNetworkReachabilityFlags flags;
                SCNetworkReachabilityGetFlags(self.networkReachability, &flags);
                RCHNetworkReachabilityStatus status = RCHNetworkReachabilityStatusForFlags(flags);
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(status);

                    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
                    [notificationCenter postNotificationName:RCHNetworkingReachabilityDidChangeNotification object:nil userInfo:@{ RCHNetworkingReachabilityNotificationStatusItem : @(status) }];

                });
            });
        } break;
    }
}

- (void)stopMonitoring
{
    if (!self.networkReachability) {
        return;
    }

    SCNetworkReachabilityUnscheduleFromRunLoop(self.networkReachability, CFRunLoopGetMain(), kCFRunLoopCommonModes);
}

#pragma mark -

- (NSString *)localizedNetworkReachabilityStatusString
{
    return RCHStringFromNetworkReachabilityStatus(self.networkReachabilityStatus);
}

#pragma mark -

- (void)setReachabilityStatusChangeBlock:(void (^)(RCHNetworkReachabilityStatus status))block
{
    self.networkReachabilityStatusBlock = block;
}

#pragma mark - NSKeyValueObserving

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"reachable"] || [key isEqualToString:@"reachableViaWWAN"] || [key isEqualToString:@"reachableViaWiFi"]) {
        return [NSSet setWithObject:@"networkReachabilityStatus"];
    }

    return [super keyPathsForValuesAffectingValueForKey:key];
}

@end
