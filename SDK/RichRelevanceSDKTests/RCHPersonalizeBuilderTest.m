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
#import "RCHPersonalizeBuilder.h"
#import "RCHAPIConstants.h"
#import "RCHPersonalizeResponseParser.h"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHPersonalizeBuilderTest : XCTestCase

@property (strong, nonatomic) RCHPersonalizeBuilder *builder;

@end

@implementation RCHPersonalizeBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHPersonalizeBuilder alloc] init];
}

- (void)testInit
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestPersonalizePath);
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoParserClass]).to.equal([RCHPersonalizeResponseParser class]);
}

#pragma mark - Parameters

- (void)testSetCartValue
{
    expect([self.builder setCartValue:100].requestParams[kRCHAPIRequestParamPersonalizeCartValue]).to.equal(@100);
}

- (void)testSetSpoofString:(NSString *)spoofString;
{
    expect([self.builder setSpoofString:@"spoof"].requestParams[kRCHAPIRequestParamPersonalizeSpoof]).to.equal(@"spoof");
}

- (void)testSetEmailCampaignID:(NSString *)emailCampaignID;
{
    expect([self.builder setEmailCampaignID:@"campaignName"].requestParams[kRCHAPIRequestParamPersonalizeEmailCampaignID]).to.equal(@"campaignName");
}

- (void)testSetExternalCategoryIDs:(NSArray *)externalCategoryIDs;
{
    expect([self.builder setExternalCategoryIDs:@[ @"c1", @"c2" ]].requestParams[kRCHAPIRequestParamPersonalizeExternalCategoryIDs]).to.equal(@"c1|c2");
}

- (void)testSetCategoryName:(NSString *)categoryName;
{
    expect([self.builder setCategoryName:@"categoryName"].requestParams[kRCHAPIRequestParamPersonalizeCategoryName]).to.equal(@"categoryName");
}

- (void)testSetRecProductCount:(NSInteger)count;
{
    expect([self.builder setRecProductCount:10].requestParams[kRCHAPIRequestParamPersonalizeRecProductsCount]).to.equal(@10);
}

- (void)testSetCatalogFeedCustomAttributes
{
    NSArray *attributes = @[ @"A", @"B", @3 ];
    expect([self.builder setCatalogFeedCustomAttributes:attributes].requestParams[kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute]).to.equal(attributes);
}

@end
