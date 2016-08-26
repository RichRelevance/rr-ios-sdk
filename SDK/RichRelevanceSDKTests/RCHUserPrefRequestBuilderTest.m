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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "RCHRequestBuilder.h"
#import "RCHUserPrefBuilder.h"
#import "RCHAPIConstants.h"
#import "RCHSDK.h"
#import "RCHAPIClient.h"
#import "RCHAPIClientConfig.h"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHUserPrefRequestBuilderTest : XCTestCase

@property (strong, nonatomic) RCHUserPrefBuilder *builder;

@end

@implementation RCHUserPrefRequestBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHUserPrefBuilder alloc] init];
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey"];
    config.userID = @"user";
    config.sessionID = @"session";
    [[RCHSDK defaultClient] configure:config];
}

- (void)testPath
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestUserPrefPath);
}

- (void)testSetViewGUID
{
    expect([self.builder setViewGUID:@"ab"].requestParams[kRCHAPIRequestParamUserPrefViewGUID]).to.equal(@"ab");
    [self assertUpdateMode];
}

- (void)testSetPreferences
{
    expect([self.builder setPreferences:@[ @"a", @"b" ]].requestParams[kRCHAPIRequestParamUserPrefPreference]).to.equal(@"a|b");
    [self assertUpdateMode];
}

- (void)testSetTargetType
{
    expect([self.builder setTargetType:0].requestParams[kRCHAPIRequestParamUserPrefTargetType]).to.beNil();
    expect([self.builder setTargetType:RCHUserPrefFieldTypeBrand].requestParams[kRCHAPIRequestParamUserPrefTargetType]).to.equal(@"brand");
    [self assertUpdateMode];
}

- (void)testSetActionType
{
    expect([self.builder setActionType:0].requestParams[kRCHAPIRequestParamUserPrefActionType]).to.beNil();
    expect([self.builder setActionType:RCHUserPrefActionTypeLike].requestParams[kRCHAPIRequestParamUserPrefActionType]).to.equal(@"like");
    [self assertUpdateMode];
}

- (void)testAddFetchPreference
{
    expect([self.builder addFetchPreference:0].requestParams[kRCHAPIRequestParamUserPrefFields]).to.beNil();
    expect([self.builder addFetchPreference:RCHUserPrefFieldTypeBrand].requestParams[kRCHAPIRequestParamUserPrefFields]).to.equal(@"pref_brand");
    expect([self.builder addFetchPreference:RCHUserPrefFieldTypeStore].requestParams[kRCHAPIRequestParamUserPrefFields]).to.equal(@"pref_brand|pref_store");
    [self assertFetchMode];
}

- (void)assertFetchMode
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoUserAndSessionStyle]).to.equal(@(RCHAPIClientUserAndSessionParamStyleNone));
    NSString *path = [NSString stringWithFormat:@"%@/user", kRCHAPIRequestUserPrefPath];
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(path);
}

- (void)assertUpdateMode
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoUserAndSessionStyle]).to.equal(@(RCHAPIClientUserAndSessionParamStyleShort));
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestUserPrefPath);
}

@end
