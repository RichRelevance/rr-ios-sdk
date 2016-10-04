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

#import "RCHUserPrefBuilder.h"
#import "RCHAPIConstants.h"
#import "RCHSDK.h"
#import "RCHLog.h"
#import "RCHAPIClientConfig.h"
#import "RCHAPIClient.h"
#import "RCHCommonIncludes.h"
#import "RCHUserPrefResponseParser.h"

typedef NS_ENUM(NSInteger, RCHUserPrefRequestMode) {
    RCHUserPrefRequestModeNotSet = 0,
    RCHUserPrefRequestModeUpdate,
    RCHUserPrefRequestModeFetch
};

@interface RCHUserPrefBuilder ()

@property (assign, nonatomic) RCHUserPrefRequestMode requestMode;

@end

@implementation RCHUserPrefBuilder

- (instancetype)init
{
    self = [super initWithAPIPath:kRCHAPIRequestUserPrefPath];
    if (self) {
        self.requestMode = RCHUserPrefRequestModeUpdate;
        [self setUserAndSessionParamStyle:RCHAPIClientUserAndSessionParamStyleShort];
        [self setResponseParserClass:[RCHUserPrefResponseParser class]];
    }
    return self;
}

- (instancetype)setMode:(RCHUserPrefRequestMode)mode
{
    self.requestMode = mode;

    switch (mode) {
        case RCHUserPrefRequestModeNotSet:
            [RCHLog logError:@"%@:%@ requires a valid RCHUserPrefRequestMode mode", NSStringFromClass([self class]), NSStringFromSelector(_cmd)];
            break;
        case RCHUserPrefRequestModeUpdate: {
            [self setUserAndSessionParamStyle:RCHAPIClientUserAndSessionParamStyleShort];
            break;
        }
        case RCHUserPrefRequestModeFetch: {
            NSString *userID = [RCHSDK defaultClient].clientConfig.userID;
            if (userID != nil) {
                NSString *newPath = [kRCHAPIRequestUserPrefPath stringByAppendingPathComponent:userID];
                [self setAPIPath:newPath];
            }
            [self setUserAndSessionParamStyle:RCHAPIClientUserAndSessionParamStyleNone];
            break;
        }
        default:
            break;
    }

    return self;
}

- (instancetype)setViewGUID:(NSString *)viewGUID
{
    [self setMode:RCHUserPrefRequestModeUpdate];
    return [self setValue:viewGUID forKey:kRCHAPIRequestParamUserPrefViewGUID];
}

- (instancetype)setPreferences:(NSArray *)prefs
{
    [self setMode:RCHUserPrefRequestModeUpdate];
    return [self setArrayValue:prefs forKey:kRCHAPIRequestParamUserPrefPreference];
}

- (instancetype)setTargetType:(RCHUserPrefFieldType)targetType
{
    [self setMode:RCHUserPrefRequestModeUpdate];

    if (targetType != RCHUserPrefFieldTypeNotSet) {
        [self setValue:[RCHEnumMappings stringFromUserPrefTargetType:targetType] forKey:kRCHAPIRequestParamUserPrefTargetType];
    }

    return self;
}

- (instancetype)setActionType:(RCHUserPrefActionType)actionType
{
    [self setMode:RCHUserPrefRequestModeUpdate];

    if (actionType != RCHUserPrefActionTypeNotSet) {
        [self setValue:[RCHEnumMappings stringFromUserPrefActionType:actionType] forKey:kRCHAPIRequestParamUserPrefActionType];
    }

    return self;
}

- (instancetype)addFetchPreference:(RCHUserPrefFieldType)preference
{
    [self setMode:RCHUserPrefRequestModeFetch];

    if (preference != RCHUserPrefFieldTypeNotSet) {
        [self addValue:[RCHEnumMappings stringFromUserPrefFieldType:preference] toArrayForKey:kRCHAPIRequestParamUserPrefFields];
    }

    return self;
}

@end
