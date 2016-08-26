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
#import "RCHUserProfileBuilder.h"
#import "RCHAPIConstants.h"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHUserProfileRequestBuilderTest : XCTestCase

@property (strong, nonatomic) RCHUserProfileBuilder *builder;

@end

@implementation RCHUserProfileRequestBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHUserProfileBuilder alloc] init];
}

- (void)testPath
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestUserProfilePath);
}

- (void)testRequiresOAuth
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoRequiresOAuth]).to.equal(@YES);
}

- (void)testAddFieldType
{
    [self.builder addFieldType:0];
    expect(self.builder.requestParams[kRCHAPIRequestParamUserProfileFields]).to.beNil();

    [self.builder addFieldType:RCHUserProfileFieldTypeOrders];
    [self.builder addFieldType:RCHUserProfileFieldTypeVerbNouns];
    [self.builder addFieldType:RCHUserProfileFieldTypeClickedItems];

    expect(self.builder.requestParams[kRCHAPIRequestParamUserProfileFields]).to.equal(@"orders,verbNouns,clickedItems");
}

@end
