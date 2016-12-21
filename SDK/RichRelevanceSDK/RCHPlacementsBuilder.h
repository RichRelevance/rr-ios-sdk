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

#import "RCHRequestBuilder.h"

/*!
 A request placement object represents a two-part placement entity. Intended for use when making placement requests.
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHRequestPlacement : NSObject

@property (assign, nonatomic) RCHPlacementPageType pageType;
@property (copy, nonatomic) NSString *name;

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Create a new instance of a request placement.
 *
 *  @param pageType The page type, one of RCHPlacementPageType
 *  @param name     The page name, a free-form configured value.
 */
- (instancetype)initWithPageType:(RCHPlacementPageType)pageType name:(NSString *)name NS_DESIGNATED_INITIALIZER;

/*!
 *  Create a new instance of a request placement in listening mode. Listening mode allows to track events (such as clicks, views and purchases) without returning personalization.
 *
 *  @param pageType The page type, one of RCHPlacementPageType
 */
- (instancetype)initWithListeningPageType:(RCHPlacementPageType)pageType;

/*!
 *  The string representation of this request placement, ready for API consumption.
 */
- (NSString *)stringRepresentation;

@end

/*!
 A request product object encapsulates information about a product for purchase tracking.
 */
@interface RCHRequestProduct : NSObject

@property (copy, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *priceCents;
@property (strong, nonatomic) NSNumber *priceDollars;

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Create a new request product instance.
 *
 *  @param identifier The Product ID
 *  @param quantity   The purchase quantity
 *  @param priceCents The purchase price in cents
 */
- (instancetype)initWithIdentifier:(NSString *)identifier quantity:(NSNumber *)quantity priceCents:(NSNumber *)priceCents;

/*!
 *  Create a new request product instance.
 *
 *  @param identifier The Product ID
 *  @param quantity   The purchase quantity
 *  @param priceDollars The purchase price in dollars
 */
- (instancetype)initWithIdentifier:(NSString *)identifier quantity:(NSNumber *)quantity priceDollars:(NSNumber *)priceDollars;

@end

@interface RCHPlacementsBuilder : RCHRequestBuilder

///-------------------------------
/// @name Request Parameters
///-------------------------------

/*!
 *  Adds a placement to the request. A placement is specified as a compound object instance of type RCHRequestPlacement.
 *
 *  - All placements must be for the same page type.
 *  - The first placement is assumed to be the “best” placement and will receive the best recommendation strategy.
 *  - When multiple placements are requested in the same call, each will receive a unique strategy and unique products.
 *
 *  @param placement The placement object.
 */
- (instancetype)addPlacement:(RCHRequestPlacement *)placement;

/*!
 *  The brand featured on the page. Used to set the seed for brand-seeded strategies like Brand Top Sellers.
 *
 *  @param featuredPageBrand The featured page brand.
 */
- (instancetype)setFeaturedPageBrand:(NSString *)featuredPageBrand;

/*!
 *  If set to YES, omits the HTML returned in the Relevance Cloud server response. If NO, the response includes the HTML for the placement, which is set in the layout, in the html field. Default = NO.
 *
 *  @param excludeHTML Pass YES to exclude HTML from the response. Default value is YES.
 */
- (instancetype)setExcludeHTML:(BOOL)excludeHTML;

/*!
 * If set to NO, omits category data in the response. If YES, categoryIds and categories are returned in the response.
 *
 *  @param includeCategoryData Pass NO to omit category data from response. Default value is YES.
 */
- (instancetype)setIncludeCategoryData:(BOOL)includeCategoryData;

/*!
 *  Key/value pairs describing the attribute context of the current user.
 *
 *  @param userAttributes An NSDictionary of key/value pairs that represent the current user. Values can be of type NSString or NSNumber for single values, or, NSArray for multi-value attributes.
 */
- (instancetype)setUserAttributes:(NSDictionary<NSString *, NSObject *> *)userAttributes;

/*!
 *  Shopper’s referrer prior to viewing this page. Used for reporting and merchandising. Highly recommended.
 *
 *  @param shopperReferrer The shopper referrer.
 */
- (instancetype)setShopperReferrer:(NSString *)shopperReferrer;

/*!
 *  Category hints can be added to any page type. Several category hints can be added on a single page. Each category hint added qualifies the page for merchandising rules that are associated to the category.
 *
 *  @param categoryHintIDs A list of NSString instances that represent category hint IDs
 */
- (instancetype)setCategoryHintIDs:(NSArray<NSString *> *)categoryHintIDs;

/*!
 *  To supply user segments. Should be passed in to have a segment targeted campaign work correctly.
 *
 *  @param userSegments Key/value pairs representing user segment information, segment ID -> segment name
 */
- (instancetype)setUserSegments:(NSDictionary<NSString *, NSString *> *)userSegments;

/*!
 *  Region ID. Must be consistent with the ID used in the product region feed.
 *
 *  @param regionID A region ID
 */
- (instancetype)setRegionID:(NSString *)regionID;

/*!
 *  List the product IDs of the product detail pages user viewed in the current session, including timestamps for each view.
 *
 *  @param viewdProducts An NSDictionary whose keys are Product IDs as instances of NSString and whose values are either single NSDate timestamps or an NSArray of multiple NSDate timestamps.
 */
- (instancetype)setViewedProducts:(NSDictionary<NSString *, NSObject *> *)viewdProducts;

/*!
 *  List the product IDs of the products user purchased in the current session, including timestamps for each view.
 *
 *  @param purchasedProducts An NSDictionary whose keys are Product IDs as instances of NSString and whose values are either single NSDate timestamps or an NSArray of multiple NSDate timestamps.
 */
- (instancetype)setPurchasedProducts:(NSDictionary<NSString *, NSObject *> *)purchasedProducts;

@end

NS_ASSUME_NONNULL_END
