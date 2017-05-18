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

#import "RCHPlacementsBuilder.h"
@class RCHSearchResult;

/*!
 *  A request builder for the "recsForPlacements" endpoint.
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHPlacementRecsBuilder : RCHPlacementsBuilder

///-------------------------------
/// @name Initialization
///-------------------------------

/*!
 *  Create an instance configured with the appropriate path
 *
 *  @return A newly created instance
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

///-------------------------------
/// @name Request Parameters
///-------------------------------

/*!
 *  Timestamp. For browser cache busting. Highly recommended. If excluded, you may see cached responses.
 *
 *  @param addTimestamp If YES a UNIX epoch timestamp will be added to the request payload. Default is YES.
 */
- (instancetype)setAddTimestampEnabled:(BOOL)addTimestamp;

/*!
 *  Filter by including results matching the supplied brand names.
 *
 *  @param brands A list of NSString instances that represent brand names.
 */
- (instancetype)setFilterByIncludedBrands:(NSArray<NSString *> *)brands;

/*!
 *  Filter by excluding results matching the supplied brand names.
 *
 *  @param brands A list of NSString instances that represent brand names.
 */
- (instancetype)setFilterByExcludedBrands:(NSArray<NSString *> *)brands;

/*!
 *  Filter by including items within the specified price range . The filter will match the sale price or the list price of a product
 *  if no sale price is provided. The price is given in cents, meaning if you only want to include products that are less than $100.99,
 *  the value provided should be ‘10099’.
 *
 *  @param range Price range of range in cents
 */
- (instancetype)setFilterByIncludingPriceRange:(RCHRange *)range;

/*!
 *  Filter by excluding items within the specified price range . The filter will match the sale price or the list price of a product
 *  if no sale price is provided. The price is given in cents, meaning if you only want to exclude products that are less than $100.99,
 *  the value provided should be ‘10099’.
 *
 *  @param range Price range of range in cents
 */
- (instancetype)setFilterByExcludingPriceRange:(RCHRange *)range;

/*!
 *  If set to YES, removes the item attributes from the recommended products data.
 *
 *  @param excludeItemAttributes Pass YES to exclude item attributes from the response. Default value is NO.
 */
- (instancetype)setExcludeItemAttributes:(BOOL)excludeItemAttributes;

/*!
 *  If set to YES, removes the recommended items structure completely. This is useful when having HTML is enough in the response.
 *
 *  @param excludeRecItems Pass YES to remove the entire recommended items structure from the response. Default value is NO.
 */
- (instancetype)setExcludeRecItems:(BOOL)excludeRecItems;

/*!
 *  If set to YES, reduces the information about the recommended items down to external ID and click URL.
 *
 *  @param returnMinimalRecItemData Pass YES to reduce returned data down to external ID and click URL. Default value is NO.
 */
- (instancetype)setReturnMinimalRecItemData:(BOOL)returnMinimalRecItemData;

/*!
 *  List of product IDs that should not be recommended in this response.
 *
 *  @param productIDs A list of product IDs for products that should not be recommended as part of this request/response, represented as instances of NSString.
 */
- (instancetype)setExcludeProductsFromRecommendations:(NSArray<NSString *> *)productIDs;

/*!
 *  Refinement. Triggers a refinement filter rule configured in the {rr} dashboard. Rules eliminate a set of products from recommendations based on product attributes. For more information see: Supplement: Adding Refinements (RRO-2SIGSAR)
 *
 *  @param refinements An NSDictionary of key/value pairs that represent the refinements. Values can be of type NSString or NSNumber for single values, or, NSArray for multi-value attributes.
 */
- (instancetype)setRefinements:(NSDictionary<NSString *, NSObject *> *)refinements;

/*!
 *  A single, or list of, product IDs. Part of an order definition on the purchase complete page.
 *
 *  @param productIDs An NSArray of NSString instances representing product IDs.
 */
- (instancetype)setProductIDs:(NSArray<NSString *> *)productIDs;

/*!
 *  A product added to the cart. Compatible with Add To Cart placements.
 *
 *  @param product A string with the product ID added to the cart.
 */
- (instancetype)setAddedToCartProductID:(NSString *)productID;

/*!
 *  ID of the category currently being viewed.
 *
 *  @param categoryID The category ID.
 */
- (instancetype)setCategoryID:(NSString *)categoryID;

/*!
 *  The search term the user typed in. You can also use the productId parameter to provide the product IDs of the products in the search results.
 *
 *  @param searchTerm The provided search term
 */
- (instancetype)setSearchTerm:(NSString *)searchTerm;

/*!
 *  Order ID. Part of the order definition.
 *
 *  @param orderID The provided order ID
 */
- (instancetype)setOrderID:(NSString *)orderID;

/*!
 *  Adds a product for purchase tracking.
 *
 *  @param product A populated instance of RCHRequestProduct. Only use either priceCents or priceDollars for a single request, do not mix.
 */
- (instancetype)addPurchasedProduct:(RCHRequestProduct *)product;

/*!
 *  To supply a registry ID string, used to identify a particular registry.
 *
 *  @param registryID A registry ID
 */
- (instancetype)setRegistryID:(NSString *)registryID;

/*!
 *  Registry type ID. For a list of valid registry type IDs that have been set up for your site, contact your RichRelevance team.
 *
 *  @param registryTypeID A registry type ID
 */
- (instancetype)setRegistryTypeID:(NSString *)registryTypeID;

/*!
 *  Already added registry items. A single, or list of, product IDs.
 *
 *  @param productIDs A list of Product IDs as instances of NSString
 */
- (instancetype)setAlreadyAddedRegistryProductIDs:(NSArray<NSString *> *)productIDs;

/*!
 *  A prioritized list of strategy sets that you would want to be returned based on the campaign use case. If this is not provided, our recommendation engine will run King of the Hill (KOTH) to provide best recommendations given the information provided.
 *  Be sure to add strategy values in priority order.
 *
 *  @param strategySet An RCHStrategy value to be added to the request.
 */
- (instancetype)addStrategy:(RCHStrategy)strategy;

/*!
 *  Search & Browse only. The total number of products to return in the response. This value overrides the return count set in the placement or in the Search & Browse configuration. (For example, if you want to return products 30-60, this value would be 30.) Max value = 1000.
 *
 *  @param pageCount The total number of products to return in the response.
 */
- (instancetype)setPageCount:(NSInteger)pageCount;

/*!
 *  Search & Browse only. The starting number for the products that you want to return. (For example, if you want to return products 30-60, this value would be 30.)
 *
 *  @param pageStart The starting number for returned products.
 */
- (instancetype)setPageStart:(NSInteger)pageStart;

/*!
 *  Search & Browse only. Filter based on price ranges that the products should belong to in cents. N/A for clients with localized product prices.
 *
 *  @param ranges An NSArray of RCHRange values representing price ranges.
 */
- (instancetype)setPriceRanges:(NSArray<RCHRange *> *)ranges;

/*!
 *  Search & Browse only. Filter types and values selected by the shopper. Needs configuration by the RichRelevance team before turned on.
 *
 *  @param filterAttributes An NSDictionary of key/value pairs that represent filter attributes. Values can be of type NSString or NSNumber for single values, or, NSArray for multi-value attributes.
 */
- (instancetype)setFilterAttributes:(NSDictionary<NSString *, NSObject *> *)filterAttributes;

/*!
 *  Add to cart only. Specify parameters to add from a previous search result. This string should originate from RCHSearchResult.addToCartParameters
 *
 *  @param addToCartParams The addToCartParameters property of a RCHSearchResult.
 */
- (instancetype)addParametersFromSearchResult:(NSString *)addToCartParams;

/*!
 *  Add to cart only. Specify parameters to add from the last returned search result.
 */
- (instancetype)addParametersFromLastSearchResult;

@end
NS_ASSUME_NONNULL_END
