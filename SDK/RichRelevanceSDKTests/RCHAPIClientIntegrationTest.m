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
#import "RCHAPIClientConfig.h"
#import "RCHAPIClient.h"
#import "RCHAPIConstants.h"
#import "RCHErrors.h"
#import "RCHSDK.h"
#import "RCHPlacementRecsBuilder.h"
#import "RCHPlacement.h"
#import "RCHPlacementsResult.h"
#import "RCHRecommendedProduct.h"
#import "RCHStrategyRecsBuilder.h"
#import "RCHStrategyResult.h"
#import "RCHUserProfileBuilder.h"
#import "RCHUserProfileResult.h"
#import "RCHUserPrefBuilder.h"
#import "RCHUserPrefResult.h"
#import "RCHRecommendedPlacement.h"
#import "RCHPersonalizeBuilder.h"
#import "RCHPersonalizeResult.h"
#import "RCHCreative.h"
#import "RCHPersonalizedPlacement.h"
#import "RCHGetProductsBuilder.h"
#import "RCHGetProductsResult.h"
#import "RCHAutocompleteSuggestion.h"

@interface RCHAPIClient (UnderTest)

@property (strong, nonatomic) NSMutableArray *failedClickTrackURLs;
@property (strong, nonatomic) NSString *opaqueRCSToken;

@end

@interface RCHAPIClientConfig (UnderTest)

@property (assign, readwrite, nonatomic) BOOL useHTTPS;

@end

@interface RCHAPIClientIntegrationTest : XCTestCase

@property (strong, nonatomic) RCHAPIClient *client;
@property (strong, nonatomic) RCHAPIClientConfig *config;

@end

@implementation RCHAPIClientIntegrationTest

- (void)setUp
{
    [super setUp];

    NSString *userID = @"RZTestUser";
    NSString *sessionID = [[NSUUID UUID] UUIDString];

    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"showcaseparent"
                                                               APIClientKey:@"bccfa17d092268c0"
                                                                   endpoint:RCHEndpointProduction
                                                                   useHTTPS:NO];
    config.APIClientSecret = @"r5j50mlag06593401nd4kt734i";
    config.userID = userID;
    config.sessionID = sessionID;
    self.config = config;
    self.client = [[RCHAPIClient alloc] init];
    [self.client configure:config];
    [[RCHSDK defaultClient] configure:config];
    [[RCHSDK defaultClient].failedClickTrackURLs removeAllObjects];
}

- (void)testBasic
{
    __block BOOL done = NO;
    NSDictionary *params = @{ kRCHAPIBuilderParamRequestInfo : @{kRCHAPIBuilderParamRequestInfoPath : @"rrserver/api/rrPlatform/recsForPlacements"} };
    [self.client sendRequest:params success:^(id responseObject) {
        expect(responseObject).to.beKindOf([NSDictionary class]);

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

/* This test is intermittently failing
- (void)testBasic_OAuth
{
    [Expecta setAsynchronousTestTimeout:120.0];

    self.config.useHTTPS = YES;

    __block BOOL done = NO;
    NSDictionary *params = @{ kRCHAPIBuilderParamRequestInfo :
                                  @{
                                     kRCHAPIBuilderParamRequestInfoPath : kRCHAPIRequestUserProfilePath,
                                     kRCHAPIBuilderParamRequestInfoRequiresOAuth : @YES
                                  },
                              kRCHAPIBuilderParamRequestParameters :
                                  @{
                                     @"field" : @"all"
                                  }
    };
    [self.client sendRequest:params success:^(id responseObject) {
        expect(responseObject).to.beKindOf([NSDictionary class]);

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}
*/
- (void)testRecsWithStrategy
{
    RCHStrategyRecsBuilder *builder = [RCHSDK builderForRecsWithStrategy:RCHStrategySiteWideBestSellers];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        expect(responseObject).to.beKindOf([RCHStrategyResult class]);

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testPersonalizedRecsForPlacements
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeAddToCart name:@"prod1"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithPlacement:placement];

    __block BOOL done = NO;
    __block RCHRecommendedProduct *product;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        [self validatePlacementRecsResponse:responseObject];

        RCHPlacementsResult *result = responseObject;
        RCHRecommendedPlacement *placement = result.placements[0];
        product = placement.recommendedProducts[0];

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();

    [product trackProductView];
    expect([RCHSDK defaultClient].failedClickTrackURLs).will.haveCountOf(0);
}

- (void)testRecsForPlacementsWithSearchTerm
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeAddToCart name:@"prod1"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithSearchTerm:@"Apple" placement:placement];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        [self validatePlacementRecsResponse:responseObject];
        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)validatePlacementRecsResponse:(id)responseObject
{
    expect(responseObject).to.beKindOf([RCHPlacementsResult class]);

    RCHPlacementsResult *result = responseObject;
    expect(result.status).to.equal(@"ok");
    expect(result.placements.count > 0).to.beTruthy();

    RCHRecommendedPlacement *placement = result.placements[0];
    expect(placement.recommendedProducts.count > 0).to.beTruthy();

    RCHRecommendedProduct *product = placement.recommendedProducts[0];
    expect(product.categories.count > 0).to.beTruthy();
    expect(product.name).notTo.beNil();
    expect(product.clickURL).notTo.beNil();
    expect(product.imageURL).notTo.beNil();
    expect(product.rating).notTo.beNil();
}

- (void)testUserProfileGetFields
{
    [Expecta setAsynchronousTestTimeout:120.0];
    self.config.useHTTPS = YES;

    RCHUserProfileBuilder *builder = [RCHSDK builderForUserProfileFieldType:RCHUserProfileFieldTypeAll];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        expect(responseObject).to.beKindOf([RCHUserProfileResult class]);

        RCHUserProfileResult *result = (RCHUserProfileResult *)responseObject;
        expect(result.userID).to.equal(self.config.userID);

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testUserPrefFetch
{
    RCHUserPrefBuilder *builder = [RCHSDK builderForUserPrefFieldType:RCHUserPrefFieldTypeBrand];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        expect(responseObject).to.beKindOf([RCHUserPrefResult class]);
        expect([responseObject userID]).notTo.beNil();

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testUserPrefTrack
{
    RCHUserPrefBuilder *builder = [RCHSDK builderForTrackingPreferences:@[ @"Google", @"Apple", @"Microsoft", @"Facebook", @"HP" ] targetType:RCHUserPrefFieldTypeBrand actionType:RCHUserPrefActionTypeLike];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testPersonalizeWithPlacements
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeHome name:@"omnichannel"];
    RCHPersonalizeBuilder *builder = [RCHSDK builderForPersonalizeWithPlacement:placement];

    __block BOOL done = NO;
    __block RCHCreative *creative;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).to.beKindOf([RCHPersonalizeResult class]);

        RCHPersonalizeResult *result = responseObject;
        RCHPersonalizedPlacement *placement = result.placements[0];
        creative = placement.creatives[0];

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testGetProducts
{
    RCHGetProductsBuilder *builder = [RCHSDK builderForGetProducts:@[ @"24100292" ]];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).to.beKindOf([RCHGetProductsResult class]);

        RCHGetProductsResult *result = responseObject;
        expect(result.products).to.haveCountOf(1);

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

@end

@interface RCHServiceAPIClientIntegrationTest : XCTestCase

@property (strong, nonatomic) RCHAPIClient *client;
@property (strong, nonatomic) RCHAPIClientConfig *config;

@end

@implementation RCHServiceAPIClientIntegrationTest

- (void)setUp
{
    [super setUp];

    NSString *userID = @"RZTestUser";
    NSString *sessionID = [[NSUUID UUID] UUIDString];

    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"showcaseparent"
                                                               APIClientKey:@"199c81c05e473265"
                                                                   endpoint:RCHEndpointProduction
                                                                   useHTTPS:NO];
    config.APIClientSecret = @"r5j50mlag06593401nd4kt734i";
    config.userID = userID;
    config.sessionID = sessionID;
    self.config = config;
    self.client = [[RCHAPIClient alloc] init];
    [self.client configure:config];
    [[RCHSDK defaultClient] configure:config];
    [[RCHSDK defaultClient].failedClickTrackURLs removeAllObjects];
}

- (void)testAutocomplete
{
    RCHAutocompleteBuilder *builder = [RCHSDK builderForAutocompleteWithQuery:@"sh"];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).to.beKindOf([NSArray class]);

        expect(responseObject).to.haveCountOf(9);

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testSearch
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeSearch name:@"find"];
    RCHSearchBuilder *builder = [RCHSDK builderForSearchPlacement:placement withQuery:@"sh"];

    __block BOOL done = NO;
    [self.client sendRequest:[builder build] success:^(id responseObject) {
        expect(responseObject).to.beKindOf([RCHSearchResult class]);

        RCHSearchResult *result = responseObject;
        expect(result.products).to.haveCountOf(20);
        expect(result.status).to.equal(@"OK");

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"API call should not fail");
    }];
    
    expect(done).will.beTruthy();
}

@end
