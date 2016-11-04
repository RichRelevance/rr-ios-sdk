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
#import "RCHPlacementRecsBuilder.h"
#import "RCHAPIConstants.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHPlacementRecommendationsRequestBuilderTest : XCTestCase

@property (strong, nonatomic) RCHPlacementRecsBuilder *builder;

@end

@implementation RCHPlacementRecommendationsRequestBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHPlacementRecsBuilder alloc] init];
}

#pragma mark - RequestPlacement Object

- (void)testRequestPlacement_init
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"header"];
    expect(placement).notTo.beNil();

    placement = [[RCHRequestPlacement alloc] initWithPageType:0 name:@"header"];
    expect(placement).to.beNil();

    placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:nil];
    expect(placement).to.beNil();
}

- (void)testRequestPlacement_stringFromPageType
{
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeNotSet]).to.beNil();
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeHome]).to.equal(@"home_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeItem]).to.equal(@"item_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeAddToCart]).to.equal(@"add_to_cart_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeSearch]).to.equal(@"search_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypePurchaseComplete]).to.equal(@"purchase_complete_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeCategory]).to.equal(@"category_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypeCart]).to.equal(@"cart_page");
    expect([RCHEnumMappings stringFromPageType:RCHPlacementPageTypePersonal]).to.equal(@"personal_page");
}

- (void)testRequestPlacement_stringRepresentation
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"horizontal"];
    expect([placement stringRepresentation]).to.equal(@"cart_page.horizontal");
}

#pragma mark - Parameters

- (void)testAddPlacement
{
    RCHRequestPlacement *p1 = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeHome name:@"vertical"];
    RCHRequestPlacement *p2 = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeHome name:@"full"];
    RCHRequestPlacement *p3 = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeCart name:@"horizontal"];
    RCHRequestPlacement *p4 = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeHome name:@"hero_full"];
    
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder addPlacement:p1];
    [builder addPlacement:p2];
    
    NSString *expected = @"home_page.vertical|home_page.full";
    expect(builder.requestParams[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(expected);
    
    [builder addPlacement:p3];
    expect(builder.requestParams[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(expected);
    
    [builder addPlacement:p4];
    expected = [expected stringByAppendingString:@"|home_page.hero_full"];
    expect(builder.requestParams[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(expected);
}

-(void)testListeningPlacements {
    RCHRequestPlacement *p1 = [[RCHRequestPlacement alloc] initWithListeningPageType:RCHPlacementPageTypeHome];
    RCHRequestPlacement *p2 = [[RCHRequestPlacement alloc] initWithListeningPageType:RCHPlacementPageTypeHome];
    RCHRequestPlacement *p3 = [[RCHRequestPlacement alloc] initWithListeningPageType:RCHPlacementPageTypeCart];
    
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    NSString *expected = @"home_page";

    [builder addPlacement:p1];
    expect(builder.requestParams[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(expected);
    
    [builder addPlacement:p2];
    [builder addPlacement:p3];
    expect(builder.requestParams[kRCHAPIRequestParamRecommendationsPlacements]).to.equal(expected);
}
- (void)testSetAddTimestampEnabled
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSDictionary *dict = [self.builder build];
    NSString *timestampString = dict[kRCHAPIBuilderParamRequestParameters][kRCHAPIRequestParamRecommendationsTimestamp];
    expect(timestampString).notTo.beNil();

    NSTimeInterval timestampInterval = [timestampString doubleValue];
    expect((timestampInterval - now) < 10).to.beTruthy();

    [self.builder setAddTimestampEnabled:NO];
    dict = [self.builder build];
    timestampString = dict[kRCHAPIRequestParamRecommendationsTimestamp];
    expect(timestampString).to.beNil();
}

- (void)testSetFilterByIncludedBrands
{
    [self.builder setFilterByIncludedBrands:nil];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsBrandFilteredProducts]).to.beNil();
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts]).to.beNil();

    NSArray *brands = @[ @"Sony", @"EA", @"Apple" ];
    [self.builder setFilterByIncludedBrands:brands];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsBrandFilteredProducts]).to.equal([brands componentsJoinedByString:@"|"]);
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts]).to.equal(@YES);
}

- (void)testSetFilterByExcludedBrands
{
    [self.builder setFilterByExcludedBrands:nil];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsBrandFilteredProducts]).to.beNil();
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts]).to.beNil();

    NSArray *brands = @[ @"Microsoft", @"Facebook", @"Gap" ];
    [self.builder setFilterByExcludedBrands:brands];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsBrandFilteredProducts]).to.equal([brands componentsJoinedByString:@"|"]);
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts]).to.equal(@NO);
}

- (void)testSetFeaturedPageBrand
{
    [self.builder setFeaturedPageBrand:@"Apple"];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsFeaturedPageBrand]).to.equal(@"Apple");
}

- (void)testSetFilterByIncludingPriceRangeWithMinPriceCents
{
    [self.builder setFilterByIncludingPriceRange:[[RCHRange alloc] initWithMin:@10 max:@100]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsMinPriceFilter]).to.equal(@10);
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsMaxPriceFilter]).to.equal(@100);
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludePriceFilteredProducts]).to.equal(@YES);
}

- (void)testSetFilterByExcludingPriceRangeWithMinPriceCents
{
    [self.builder setFilterByExcludingPriceRange:[[RCHRange alloc] initWithMin:@10 max:@100]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsMinPriceFilter]).to.equal(@10);
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsMaxPriceFilter]).to.equal(@100);
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludePriceFilteredProducts]).to.equal(@NO);
}

- (void)testSetExcludeHTML
{
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeHtml]).to.equal(@YES);
    [self.builder setExcludeHTML:NO];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeHtml]).to.equal(@NO);
}

- (void)testSetExcludeItemAttributes
{
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeItemAttributes]).to.beNil();
    [self.builder setExcludeItemAttributes:YES];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeItemAttributes]).to.equal(@YES);
}

- (void)testSetExcludeRecItems
{
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeRecItems]).to.beNil();
    [self.builder setExcludeRecItems:YES];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeRecItems]).to.equal(@YES);
}

- (void)testSetReturnMinimalRecItemData
{
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsReturnMinimalRecItemData]).to.beNil();
    [self.builder setReturnMinimalRecItemData:YES];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsReturnMinimalRecItemData]).to.equal(@YES);
}

- (void)testSetIncludeCategoryData:(BOOL)includeCategoryData
{
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeCategoryData]).to.beNil();
    [self.builder setIncludeCategoryData:NO];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsIncludeCategoryData]).to.equal(@NO);
}

- (void)testSetExcludeProductsFromRecommendations
{
    [self.builder setExcludeProductsFromRecommendations:@[ @"1", @"2", @"3" ]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsExcludeProductsFromRecommendations]).to.equal(@"1|2|3");
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

- (void)testSetRefinements
{
    NSDictionary *dict = @{
        @"hair_color" : @[ @"red", @"blonde" ],
        @"age" : @30,
        @"gender" : @"female"
    };
    [self.builder setRefinements:dict];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsRefinementRule]).to.equal(@"age:30|gender:female|hair_color:red|hair_color:blonde");
}

- (void)testSetShopperReferre
{
    [self.builder setShopperReferrer:@"myRef"];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsShopperReferrer]).to.equal(@"myRef");
}

- (void)testSetProductIDs
{
    [self.builder setProductIDs:@[ @"1", @"A", @"B" ]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1|A|B");
}

- (void)testSetCategoryID
{
    [self.builder setCategoryID:@"1234"];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsCategoryID]).to.equal(@"1234");
}

- (void)testSetCategoryHintIDs
{
    [self.builder setCategoryHintIDs:@[ @"1", @"2", @"3" ]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsCategoryHintID]).to.equal(@"1|2|3");
}

- (void)testSetSearchTerm:(NSString *)searchTerm
{
    [self.builder setSearchTerm:@"Shoes"];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsSearchTerm]).to.equal(@"Shoes");
}

- (void)testSetOrderID
{
    [self.builder setOrderID:@"456"];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsOrderID]).to.equal(@"456");
}

- (void)testAddPurchasedProduct_priceInCents
{
    [self.builder addPurchasedProduct:[[RCHRequestProduct alloc] initWithIdentifier:@"1" quantity:@10 priceCents:@100]];
    [self.builder addPurchasedProduct:[[RCHRequestProduct alloc] initWithIdentifier:@"2" quantity:@5 priceCents:@75]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1|2");
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsItemQuantities]).to.equal(@"10|5");
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsProductPricesCents]).to.equal(@"100|75");
}

- (void)testAddPurchasedProduct_priceInDollars
{
    [self.builder addPurchasedProduct:[[RCHRequestProduct alloc] initWithIdentifier:@"1" quantity:@10 priceDollars:@100]];
    [self.builder addPurchasedProduct:[[RCHRequestProduct alloc] initWithIdentifier:@"2" quantity:@5 priceDollars:@75]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1|2");
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsItemQuantities]).to.equal(@"10|5");
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsProductPrices]).to.equal(@"100|75");
}

- (void)testSetUserSegments
{
    [self.builder setUserSegments:@{ @"101" : @"NewUser",
                                     @"2" : @"Test" }];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsUserSegments]).to.equal(@"101:NewUser|2:Test");
}

- (void)testSetRegistryID
{
    expect([self.builder setRegistryID:@"123"].requestParams[kRCHAPIRequestParamRecommendationsRegistryID]).to.equal(@"123");
}

- (void)testSetRegistryTypeID
{
    expect([self.builder setRegistryTypeID:@"123"].requestParams[kRCHAPIRequestParamRecommendationsRegistryTypeID]).to.equal(@"123");
}

- (void)testSetAlreadyAddedRegistryProductIDs
{
    expect([self.builder setAlreadyAddedRegistryProductIDs:@[ @"1", @"2", @"3" ]].requestParams[kRCHAPIRequestParamRecommendationsAlreadyAddedRegistryProductIDs]).to.equal(@"1|2|3");
}

- (void)testAddStrategy
{
    [self.builder addStrategy:RCHStrategyNewArrivals];
    [self.builder addStrategy:RCHStrategyPersonalized];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsStrategySet]).to.equal(@"NewArrivals|Personalized");
}

- (void)testSetRegionID
{
    expect([self.builder setRegionID:@"123"].requestParams[kRCHAPIRequestParamRecommendationsRegionID]).to.equal(@"123");
}

- (void)testSetViewedProducts
{
    NSDate *now = [NSDate date];
    NSDate *nowPlusOne = [NSDate dateWithTimeIntervalSince1970:now.timeIntervalSince1970 + 1.0];
    NSString *dateString = [NSString stringWithFormat:@"%0.f", [now timeIntervalSince1970] * 1000.0];
    NSString *dateStringPlusOne = [NSString stringWithFormat:@"%0.f", [nowPlusOne timeIntervalSince1970] * 1000.0];

    NSDictionary *products = @{
        @"1" : now,
        @"2" : @[ now, nowPlusOne ]
    };

    [self.builder setViewedProducts:products];
    NSString *expected = [NSString stringWithFormat:@"1:%@|2:%@;%@", dateString, dateString, dateStringPlusOne];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsViewedProducts]).to.equal(expected);
}

- (void)testSetPurchasedProducts
{
    NSDate *now = [NSDate date];
    NSDate *nowPlusOne = [NSDate dateWithTimeIntervalSince1970:now.timeIntervalSince1970 + 1.0];
    NSString *dateString = [NSString stringWithFormat:@"%0.f", [now timeIntervalSince1970] * 1000.0];
    NSString *dateStringPlusOne = [NSString stringWithFormat:@"%0.f", [nowPlusOne timeIntervalSince1970] * 1000.0];

    NSDictionary *products = @{
        @"1" : now,
        @"2" : @[ now, nowPlusOne ],
        @"3" : @{},    // should be ignored.
        @"4" : @"Test" // also ignored.
    };

    [self.builder setPurchasedProducts:products];
    NSString *expected = [NSString stringWithFormat:@"1:%@|2:%@;%@", dateString, dateString, dateStringPlusOne];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsPurchasedProducts]).to.equal(expected);
}

- (void)testSetPageCount
{
    expect([self.builder setPageCount:50].requestParams[kRCHAPIRequestParamRecommendationsPageCount]).to.equal(50);
}

- (void)testSetPageStart
{
    expect([self.builder setPageStart:5].requestParams[kRCHAPIRequestParamRecommendationsPageStart]).to.equal(5);
}

- (void)testSetPriceRanges
{
    NSArray *ranges = @[
        [[RCHRange alloc] initWithMin:@1 max:@5],
        [[RCHRange alloc] initWithMin:nil max:@5],
        [[RCHRange alloc] initWithMin:@1 max:nil]
    ];
    [self.builder setPriceRanges:ranges];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsPriceRanges]).to.equal(@"1;5");
}

- (void)testSetFilterAttributes
{
    NSDictionary *dict = @{
        @"hair_color" : @[ @"red", @"blonde" ],
        @"age" : @30,
        @"gender" : @"female"
    };
    [self.builder setFilterAttributes:dict];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsFilterAttributes]).to.equal(@"age:30|gender:female|hair_color:red;blonde");
}

@end

#pragma clang diagnostic pop
