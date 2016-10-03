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
//#import "RCHPlacementsResult.h"
#import "RCHAPIResponseParser.h"
#import "RCHPlacement.h"
#import "RCHRecommendedProduct.h"
#import "RCHRange.h"
#import "RCHCategory.h"
#import "RCHRecsForPlacementsResponseParser.h"
#import "RCHErrors.h"
#import "RCHRecsUsingStrategyResponseParser.h"
#import "RCHStrategyResult.h"
#import "RCHUserProfileResponseParser.h"
#import "RCHUserProfileResult.h"
#import "RCHUserProfileElement.h"
#import "RCHUserPrefResponseParser.h"
#import "RCHUserPrefResult.h"
#import "RCHUserPreference.h"
#import "RCHRecommendedPlacement.h"
#import "RCHPersonalizeResult.h"
#import "RCHPersonalizeResponseParser.h"
#import "RCHPersonalizedPlacement.h"
#import "RCHCreative.h"
#import "RCHAutocompleteResponseParser.h"
#import "RCHSearchResponseParser.h"
#import "RCHSearchResult.h"
#import "RCHSearchFacet.h"
#import "RCHSearchProduct.h"
#import "RCHSearchLink.h"

@interface RCHAPIResponseParserTest : XCTestCase

@end

@implementation RCHAPIResponseParserTest

- (void)setUp
{
    [super setUp];
}

#pragma mark - Placements

- (void)testParseRecsForPlacements
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"recs_for_placements" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHRecsForPlacementsResponseParser *parser = [[RCHRecsForPlacementsResponseParser alloc] init];

    RCHPlacementsResult *result = [parser parseResponse:JSONObject error:nil];

    expect(result.rawResponse).to.equal(JSONObject);

    expect(result).notTo.beNil();
    expect(result.status).to.equal(@"ok");
    expect(result.viewGUID).to.equal(@"f3a16fcb-1193-460e-4a36-255366b5cf38");
    expect(result.placements).to.haveCount(1);

    RCHRecommendedPlacement *placement = result.placements[0];

    expect(placement.htmlElementId).to.equal(@"add_to_cart_page_0");
    expect(placement.placementType).to.equal(RCHPlacementPageTypeAddToCart);
    expect(placement.strategyMessage).to.equal(@"Best Sellers");
    expect(placement.strategyName).to.equal(RCHStrategyDefault);
    expect(placement.placement).to.equal(@"add_to_cart_page.prod1");
    expect(placement.recommendedProducts).to.haveCount(4);

    RCHRecommendedProduct *product = placement.recommendedProducts[0];
    expect(product.clickURL).to.equal(@"http://recs.richrelevance.com/rrserver/apiclick?a=showcaseparent&cak=615389034415e91d&ct=http%3A%2F%2Flabs.richrelevance.com%2Fstorre%2Fcatalog%2Fproduct%2Fview%2Fsku%2F24100292&vg=f3a16fcb-1193-460e-4a36-255366b5cf38&stid=13&pti=13&pa=4892&pos=0&p=24100292&channelId=615389034415e91d&s=13DF9FE0-20D2-4951-AF45-4DDB105E7406&u=RZTestUser");
    expect(product.regionPriceDescription).to.equal(@"");
    expect(product.rating).to.equal(@(4.238999843597412));
    expect(product.numReviews).to.equal(@0);
    expect(product.priceRangeCents.min).to.equal(@2900);
    expect(product.priceRangeCents.max).to.equal(@2900);
    expect(product.categoryIDs[0]).to.equal(@"Electronics");
    expect(product.regionalProductSku).to.equal(@"24100292");
    expect(product.imageURL).to.equal(@"http://labs.richrelevance.com/storre/media/catalog/product/c/a/canon-pixma-mg2220-all-in-one-inkjet-multifunction-printerscannercopier-a3c09644838bab3c901601a1603534b1.jpg");
    expect(product.name).to.equal(@"Canon PIXMA MG2220 All-in-One Inkjet Multifunction Printer/Scanner/Copier");
    expect(product.genre).to.equal(@"Electronics");
    expect(product.isRecommendable).to.beTruthy();
    expect(product.priceCents).to.equal(@2900);
    expect(product.attributes).notTo.beNil();
    expect(product.attributes[@"MktplcInd"]).notTo.beNil();
    expect(product.productID).to.equal(@"24100292");
    expect(product.brand).to.equal(@"Canon");
    expect(product.categories).to.haveCount(4);

    RCHCategory *category = product.categories[0];
    expect(category.name).to.equal(@"Electronics");
    expect(category.categoryID).to.equal(@"Electronics");
    expect(category.hasChildren).to.beFalsy();
}

- (void)testParseRecsForPlacements_APIError
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"recs_for_placements_error" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHRecsForPlacementsResponseParser *parser = [[RCHRecsForPlacementsResponseParser alloc] init];

    NSError *error = nil;
    [parser parseResponse:JSONObject error:&error];
    expect(error).notTo.beNil();
    expect(error.domain).to.equal(kRCHSDKErrorDomain);
    expect(error.code).to.equal(RCHSDKErrorCodeAPIError);
    expect(error.localizedDescription).to.equal(@"Something went horribly wrong!");
}

- (void)testParseRecsForPlacements_BadResponse
{
    RCHRecsForPlacementsResponseParser *parser = [[RCHRecsForPlacementsResponseParser alloc] init];

    NSError *error = nil;
    [parser parseResponse:nil error:&error];
    expect(error).notTo.beNil();
    expect(error.domain).to.equal(kRCHSDKErrorDomain);
    expect(error.code).to.equal(RCHSDKErrorCodeCannotParseResponse);

    [parser parseResponse:@[] error:&error];
    expect(error).notTo.beNil();
    expect(error.domain).to.equal(kRCHSDKErrorDomain);
    expect(error.code).to.equal(RCHSDKErrorCodeCannotParseResponse);
}

#pragma mark - Strategy

- (void)testParseRecsUsingStrategy
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"recs_using_strategy" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHRecsUsingStrategyResponseParser *parser = [[RCHRecsUsingStrategyResponseParser alloc] init];

    RCHStrategyResult *result = [parser parseResponse:JSONObject error:nil];

    expect(result.rawResponse).to.equal(JSONObject);

    expect(result).notTo.beNil();
    expect(result.message).to.equal(@"Site-wide Best Sellers");
    expect(result.strategyName).to.equal(RCHStrategySiteWideBestSellers);
    expect(result.recommendedProducts).to.haveCount(5);

    RCHRecommendedProduct *product = result.recommendedProducts[0];
    expect(product.clickURL).to.equal(@"http://recs.richrelevance.com/rrserver/apiclick?a=showcaseparent&cak=615389034415e91d&ct=http%3A%2F%2Flabs.richrelevance.com%2Fstorre%2Fcatalog%2Fproduct%2Fview%2Fsku%2F24100292&vg=f3a16fcb-1193-460e-4a36-255366b5cf38&stid=13&pti=13&pa=4892&pos=0&p=24100292&channelId=615389034415e91d&s=13DF9FE0-20D2-4951-AF45-4DDB105E7406&u=RZTestUser");
    expect(product.regionPriceDescription).to.equal(@"");
    expect(product.rating).to.equal(@(4.238999843597412));
    expect(product.numReviews).to.equal(@0);
    expect(product.priceRangeCents.min).to.equal(@2900);
    expect(product.priceRangeCents.max).to.equal(@2900);
    expect(product.categoryIDs[0]).to.equal(@"Electronics");
    expect(product.regionalProductSku).to.equal(@"24100292");
    expect(product.imageURL).to.equal(@"http://labs.richrelevance.com/storre/media/catalog/product/c/a/canon-pixma-mg2220-all-in-one-inkjet-multifunction-printerscannercopier-a3c09644838bab3c901601a1603534b1.jpg");
    expect(product.name).to.equal(@"Canon PIXMA MG2220 All-in-One Inkjet Multifunction Printer/Scanner/Copier");
    expect(product.genre).to.equal(@"Electronics");
    expect(product.isRecommendable).to.beTruthy();
    expect(product.priceCents).to.equal(@2900);
    expect(product.attributes).notTo.beNil();
    expect(product.attributes[@"MktplcInd"]).notTo.beNil();
    expect(product.productID).to.equal(@"24100292");
    expect(product.brand).to.equal(@"Canon");
    expect(product.categories).to.haveCount(4);

    RCHCategory *category = product.categories[0];
    expect(category.name).to.equal(@"Electronics");
    expect(category.categoryID).to.equal(@"Electronics");
    expect(category.hasChildren).to.beFalsy();
}

#pragma mark - User Profile

- (void)testParseUserProfile
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"user_profile" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHUserProfileResponseParser *parser = [[RCHUserProfileResponseParser alloc] init];

    RCHUserProfileResult *result = [parser parseResponse:JSONObject error:nil];

    expect(result.rawResponse).to.equal(JSONObject);
    expect(result).notTo.beNil();
    expect(result.userID).to.equal(@"RZTestUser");
    expect(result.mostRecentRRUserGUID).to.equal(@"e886b297-8ef4-43bc-2313-52536fc162c6");
    expect(result.timeOfFirstEvent).to.equal([NSDate dateWithTimeIntervalSince1970:1432757395552.0 / 1000.0]);

    // VIEWED ITEMS

    NSArray *viewedItems = result.viewedItems;
    expect(viewedItems).to.haveCountOf(1);
    RCHUserProfileElementItem *viewedItem = viewedItems[0];
    expect(viewedItem.itemID).to.equal(@"10291452");

    // CLICKED ITEMS

    NSArray *clickedItems = result.clickedItems;
    expect(clickedItems).to.haveCountOf(2);
    RCHUserProfileElementItem *clickedItem = clickedItems[0];
    expect(clickedItem.itemID).to.equal(@"click2");

    // ORDERS

    NSArray *orders = result.orders;
    expect(orders).to.haveCount(1);
    RCHUserProfileOrder *order = orders[0];
    expect(order.sessionID).to.equal(@"8C9F19A4-7E7D-DC12-1AD6-63BC99DE4633");
    expect(order.channel).to.equal(@"bccfa17d092268c0");
    expect(order.orderID).to.equal(@"10001");
    expect(order.timestamp).to.equal([NSDate dateWithTimeIntervalSince1970:1433791582850.0 / 1000.0]);
    expect(order.items).to.haveCountOf(1);
    RCHUserProfileElementItem *item = order.items[0];
    expect(item.itemID).to.equal(@"10291452");
    expect(item.quantity).to.equal(@1);
    expect(item.priceInCents).to.equal(@5999);

    // VIEWED CATEGORIES

    NSArray *viewedCategories = result.viewedCategories;
    expect(viewedCategories).to.haveCountOf(2);
    RCHUserProfileViewedCategory *viewedCategory = viewedCategories[0];
    expect(viewedCategory.categoryID).to.equal(@"viewCategory2");

    // VIEWED BRANDS

    NSArray *viewedBrands = result.viewedBrands;
    expect(viewedBrands).to.haveCountOf(2);
    RCHUserProfileViewedBrand *viewedBrand = viewedBrands[0];
    expect(viewedBrand.brand).to.equal(@"viewBrand2");

    // ADDED TO CART ITEMS

    NSArray *cartItems = result.addedToCartItems;
    expect(cartItems).to.haveCountOf(15);
    RCHUserProfileAddedToCartItem *cartItem = cartItems[0];
    expect(cartItem.items).to.haveCountOf(2);

    // SEARCHED TERMS

    NSArray *searchedTerms = result.searchedTerms;
    expect(searchedTerms).to.haveCountOf(3);
    RCHUserProfileSearchTerm *term = searchedTerms[0];
    expect(term.searchTerm).to.equal(@"nuts");

    // USER ATTR.

    NSArray *userAttributes = result.userAttributes;
    expect(userAttributes).to.haveCountOf(4);
    RCHUserProfileUserAttributes *userAttribute = userAttributes[0];
    expect(userAttribute.values).notTo.beNil();

    // REFERRER

    NSArray *referrers = result.referrerURLs;
    expect(referrers).to.haveCountOf(2);
    RCHUserProfileReferrer *referrer = referrers[0];
    expect(referrer.URL).to.equal(@"ref2");

    // SEGMENTS

    NSArray *segments = result.userSegments;
    expect(segments).to.haveCountOf(2);
    RCHUserProfileUserSegments *segment = segments[0];
    expect(segment.segments).to.contain(@"1");

    // VERB NOUNTS

    NSArray *verbNouns = result.verbNouns;
    expect(verbNouns).to.haveCountOf(5);
    RCHUserProfileVerbNoun *verbNoun = verbNouns[0];
    expect(verbNoun.verb).notTo.beNil();
    expect(verbNoun.noun).to.equal(@"st1");

    // COUNTED EVENTS

    NSArray *countedEvents = result.countedEvents;
    expect(countedEvents).to.haveCountOf(2);
    RCHUserProfileCountedEvent *countedEvent = countedEvents[0];
    expect(countedEvent.value).to.equal(@"e1");
    expect(countedEvent.count).to.equal(@3);
    expect(countedEvent.mostRecentTime).to.equal([NSDate dateWithTimeIntervalSince1970:1419150628318 / 1000.0]);

    // BATCH ATTR

    expect(result.batchAttributes).notTo.beNil();
    expect(result.batchAttributes[@"someField"]).to.equal(@"someValue");
}

- (void)testParseUserPrefs
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"user_pref" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHUserPrefResponseParser *parser = [[RCHUserPrefResponseParser alloc] init];

    RCHUserPrefResult *result = [parser parseResponse:JSONObject error:nil];
    expect(result).notTo.beNil();
    expect(result.userID).to.equal(@"RZTestUser");

    RCHUserPreference *brandPref = result.brand;
    expect(brandPref).notTo.beNil();
    expect(brandPref.like).to.haveCountOf(1);
    expect(brandPref.like).to.contain(@"apple");
}

- (void)testPersonalize
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"personalize" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHPersonalizeResponseParser *parser = [[RCHPersonalizeResponseParser alloc] init];

    RCHPersonalizeResult *result = [parser parseResponse:JSONObject error:nil];

    expect(result.rawResponse).to.equal(JSONObject);

    expect(result).notTo.beNil();
    expect(result.status).to.equal(@"OK");
    expect(result.placements).to.haveCount(1);
    expect(result.request).notTo.beNil();

    RCHPersonalizedPlacement *placement = result.placements[0];

    expect(placement.placementType).to.equal(RCHPlacementPageTypeHome);
    expect(placement.placement).to.equal(@"home_page.omnichannel");
    expect(placement.creatives).to.haveCount(1);

    RCHCreative *creative = placement.creatives[0];
    expect(creative.trackingURL).to.equal(@"http://qa.richrelevance.com/rrserver/emailTracking?a=showcaseparent&vg=808d4f9c-aeb3-4630-938b-2b53be72a86b&cpi=NONE&pgt=9&pa=omnichannel&pt=home_page.omnichannel&pcam=766611&pcre=12367");
    expect(creative.campaign).to.equal(@"mobile: shoes");
    expect(creative.rawValues).notTo.beNil();
}

- (void)testAutocomplete
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"find_autocomplete" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHAutocompleteResponseParser *parser = [[RCHAutocompleteResponseParser alloc] init];

    NSArray *result = [parser parseResponse:JSONObject error:nil];
    expect(result).notTo.beNil();
    expect(result).to.haveCount(4);

    RCHAutocompleteSuggestion *suggestion = result[0];
    expect(suggestion.text).to.equal(@"maxi dress");
    expect(suggestion.suggestionID).to.equal(@"maxi dress");
    expect(suggestion.type).to.equal(@"TOPTRENDS");
    expect(suggestion.popularity).to.equal(221);
}

- (void)testSearch
{
    NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"find_search" withExtension:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
    id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

    RCHSearchResponseParser *parser = [[RCHSearchResponseParser alloc] init];

    RCHSearchResult *result = [parser parseResponse:JSONObject error:nil];
    expect(result).notTo.beNil();
    expect(result.request).notTo.beNil();
    expect(result.searchTrackingURL).notTo.beNil();
    expect(result.links).to.haveCount(3);
    expect(result.links[@"directlink"]).to.haveCount(1);
    expect(result.links[@"banner"]).to.haveCount(1);
    expect(result.links[@"sponsored"]).to.haveCount(1);
    expect(result.products).to.haveCount(2);

    if (result.products.count == 0) { return; }
    RCHSearchProduct *product = result.products[0];
    expect(product.productID).to.equal(@"10308694");
    expect(product.name).to.equal(@"T-Gel Original Shampoo, 8.5oz");
    expect(product.linkID).to.equal(@"");
    expect(product.salePriceCents).to.equal(@797);
    expect(product.priceCents).to.equal(@798);
    expect(product.clickURL).to.equal(@"http://localhost:8101/rrserver/api/v1/service/track/click/showcaseparent?a=showcaseparent&vg=80015896-f4fe-44c5-41ab-6654e0877e89&pti=2&pa=sort&hpi=0&stn=PersonalizedProductSearchAndBrowse&stid=184&rti=2&sgs=&u=u1234&mvtId=0&mvtTs=1458177239699&uguid=8005b4f0-f4fe-44c5-c846-f553982b6b8f&channelId=WEB&s=s1234&pg=-1&page=0&query=t&lang=en&p=10308694&ind=0&ct=http://labs.richrelevance.com/storre/catalog/product/view/sku/10308694");
    expect(product.imageURL).to.equal(@"http://labs.richrelevance.com/storre/media/catalog/product/t/-/t-gel-original-shampoo-8.5oz-1e2df9930cf89d1614debdbaa3feaf38.jpg");

    NSArray<RCHSearchFacet *> *brand = result.facets[@"brand_facet"];
    if (brand.count == 0) { return; }
    RCHSearchFacet *facet = brand[0];
    expect(facet.title).to.equal(@"Generic");
    expect(facet.filter).to.equal(@"{!tag=brand_facet}brand_facet:\"Generic\"");
    expect(facet.count).to.equal(126);

    NSArray<RCHSearchLink *> *direct = result.links[@"sponsored"];
    if (direct.count == 0) { return; }
    RCHSearchLink *link = direct[0];
    expect(link.title).to.equal(@"sponsored-title");
    expect(link.subtitle).to.equal(@"sponsored-subtitle");
    expect(link.linkID).to.equal(@"sponsored-id");
    expect(link.URL).to.equal(@"sponsored-url");
    expect(link.imageURL).to.equal(@"sponsored-image-url");
}

@end
