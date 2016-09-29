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
#import "RCHSDK.h"
#import "RCHAPIConstants.h"
#import "RCHPlacementRecsBuilder.h"
#import "RCHStrategyRecsBuilder.h"
#import "RCHUserProfileBuilder.h"
#import "RCHUserPrefBuilder.h"
#import "RCHPersonalizeBuilder.h"
#import "RCHGetProductsBuilder.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface RichRelevanceSDKTests : XCTestCase

@end

@implementation RichRelevanceSDKTests

- (void)setUp
{
    [super setUp];
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey"];
    config.userID = @"user";
    config.sessionID = @"session";
    [[RCHSDK defaultClient] configure:config];
}

- (void)testCanary
{
    expect(YES).to.beTruthy;
}

- (void)testDefaultAPIClient
{
    expect([RCHSDK defaultClient]);
}

#pragma mark - Factory

- (void)testBuilderForRecommendationsWithStrategy
{
    RCHStrategyRecsBuilder *builder = [RCHSDK builderForRecsWithStrategy:RCHStrategyNewArrivals];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamRecommendationsStrategyName]).to.equal(@"NewArrivals");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestRecsUsingStrategyPath);

    // Don't crash
    [RCHSDK builderForRecsWithStrategy:0];
}

- (void)testBuilderForRecommendationsWithCategoryID
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"vertical"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithCategoryID:@"Fruit" placement:placement];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamRecommendationsCategoryID]).to.equal(@"Fruit");
    expect(dict[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(@"cart_page.vertical");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestRecsForPlacementsPath);

    // Don't crash
    [RCHSDK builderForRecsWithCategoryID:nil placement:nil];
}

- (void)testBuilderForRecommendationsWithSearchTerm
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"vertical"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithSearchTerm:@"Shoes" placement:placement];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamRecommendationsSearchTerm]).to.equal(@"Shoes");
    expect(dict[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(@"cart_page.vertical");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestRecsForPlacementsPath);

    // Don't crash
    [RCHSDK builderForRecsWithSearchTerm:nil placement:nil];
}

- (void)testBuilderForRecommendationsWithPlacement
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"vertical"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithPlacement:placement];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(@"cart_page.vertical");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestRecsForPlacementsPath);

    // Don't crash
    [RCHSDK builderForRecsWithPlacement:nil];
}

- (void)testBuilderForTrackingProductViewWithPlacement
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"vertical"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForTrackingProductViewWithPlacement:placement productID:@"1"];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestRecsForPlacementsPath);
    expect(dict[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(@"cart_page.vertical");
    expect(dict[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1");

    // Don't crash
    [RCHSDK builderForTrackingProductViewWithPlacement:nil productID:nil];
}

- (void)testBuilderForTrackingPurchaseWithPlacement
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"vertical"];
    RCHRequestProduct *product = [[RCHRequestProduct alloc] initWithIdentifier:@"1" quantity:@2 priceCents:@3];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForTrackingPurchaseWithPlacement:placement
                                                                               orderID:@"2"
                                                                               product:product];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestRecsForPlacementsPath);
    expect(dict[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(@"cart_page.vertical");
    expect(dict[kRCHAPIRequestParamRecommendationsOrderID]).to.equal(@"2");
    expect(dict[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1");
    expect(dict[kRCHAPIRequestParamRecommendationsItemQuantities]).to.equal(@"2");
    expect(dict[kRCHAPIRequestParamRecommendationsProductPricesCents]).to.equal(@"3");

    // Don't crash
    [RCHSDK builderForTrackingPurchaseWithPlacement:nil
                                            orderID:nil
                                            product:nil];
}

- (void)testBuilderForUserProfile
{
    RCHUserProfileBuilder *builder = [RCHSDK builderForUserProfileFieldType:RCHUserProfileFieldTypeAll];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamUserProfileFields]).to.equal(@"all");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestUserProfilePath);

    // Don't crash
    [RCHSDK builderForUserProfileFieldType:RCHUserProfileFieldTypeAll];
}

- (void)testBuilderForUserPrefFieldType
{
    RCHUserPrefBuilder *builder = [RCHSDK builderForUserPrefFieldType:RCHUserPrefFieldTypeBrand];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamUserPrefFields]).to.equal(@"pref_brand");
    NSString *path = [NSString stringWithFormat:@"%@/user", kRCHAPIRequestUserPrefPath];
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(path);
}

- (void)testBuilderForTrackingPreference
{
    RCHUserPrefBuilder *builder = [RCHSDK builderForTrackingPreferences:@[ @"product" ] targetType:RCHUserPrefFieldTypeBrand actionType:RCHUserPrefActionTypeLike];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamUserPrefTargetType]).to.equal(@"brand");
    expect(dict[kRCHAPIRequestParamUserPrefActionType]).to.equal(@"like");
    expect(dict[kRCHAPIRequestParamUserPrefPreference]).to.equal(@"product");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestUserPrefPath);

    // Don't crash
    [RCHSDK builderForTrackingPreferences:nil targetType:RCHUserPrefFieldTypeBrand actionType:RCHUserPrefActionTypeLike];
    [RCHSDK builderForTrackingPreferences:@[] targetType:RCHUserPrefFieldTypeBrand actionType:RCHUserPrefActionTypeLike];
}

- (void)testBuilderForPersonalizeWithPlacement
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"vertical"];
    RCHPersonalizeBuilder *builder = [RCHSDK builderForPersonalizeWithPlacement:placement];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(@"cart_page.vertical");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestPersonalizePath);

    // Don't crash
    [RCHSDK builderForRecsWithPlacement:nil];
}

- (void)testBuilderForGetProducts
{
    RCHGetProductsBuilder *builder = [RCHSDK builderForGetProducts:@[ @"1", @"2" ]];
    NSDictionary *dict = [builder build][kRCHAPIBuilderParamRequestParameters];
    NSDictionary *info = [builder build][kRCHAPIBuilderParamRequestInfo];

    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1|2");
    expect(info[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestGetProductsPath);

    // Don't crash
    [RCHSDK builderForRecsWithPlacement:nil];
}

@end

#pragma clang diagnostic pop
