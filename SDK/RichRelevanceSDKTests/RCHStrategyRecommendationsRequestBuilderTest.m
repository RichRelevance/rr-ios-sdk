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
#import "RCHStrategyRecsBuilder.h"
#import "RCHAPIConstants.h"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHStrategyRecommendationsRequestBuilderTest : XCTestCase

@property (strong, nonatomic) RCHStrategyRecsBuilder *builder;

@end

@implementation RCHStrategyRecommendationsRequestBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHStrategyRecsBuilder alloc] init];
}

- (void)testSetStrategy
{
    expect([self.builder setStrategy:RCHStrategyNewArrivals].requestParams[kRCHAPIRequestParamRecommendationsStrategyName]).to.equal(@"NewArrivals");
}

- (void)testSetSeed
{
    expect([self.builder setSeed:@"1234"].requestParams[kRCHAPIRequestParamRecommendationsStrategySeed]).to.equal(@"1234");
}

- (void)testSetResultCount
{
    expect([self.builder setResultCount:5].requestParams[kRCHAPIRequestParamRecommendationsCategoryResultCount]).to.equal(@5);
}

- (void)testSetCatalogFeedCustomAttributes
{
    NSArray *attributes = @[ @"A", @"B", @3 ];
    expect([self.builder setCatalogFeedCustomAttributes:attributes].requestParams[kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute]).to.equal(attributes);
}

- (void)testSetEmailCampaignID
{
    expect([self.builder setEmailCampaignID:@"1234"].requestParams[kRCHAPIRequestParamRecommendationsEmailCampaignId]).to.equal(@"1234");
}

- (void)testSetRequestID
{
    expect([self.builder setRequestID:@"ABC"].requestParams[kRCHAPIRequestParamRecommendationsStrategyRequestID]).to.equal(@"ABC");
}

- (void)testSetIncludeCategoryData:(BOOL)includeCategoryData
{
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeCategoryData]).to.beNil();
    [self.builder setIncludeCategoryData:NO];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeCategoryData]).to.equal(@NO);
}

- (void)testSetUserAttributes
{
    NSDictionary *dict = @{
        @"hair_color" : @[ @"red", @"blonde" ],
        @"age" : @30,
        @"gender" : @"female"
    };
    [self.builder setUserAttributes:dict];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsUserAttribute]).to.equal(@"age:30|gender:female|hair_color:red;blonde");
}

- (void)testSetExcludeProductsFromRecommendations
{
    NSArray *products = @[ @"A", @"B", @3 ];
    expect([self.builder setExcludeProductsFromRecommendations:products].requestParams[kRCHAPIRequestParamRecommendationsStrategyBlockedProductIds]).to.equal(products);
}

- (void)testSetRegionID
{
    expect([self.builder setRegionID:@"ABC"].requestParams[kRCHAPIRequestParamRecommendationsStrategyRegionID]).to.equal(@"ABC");
}

@end
