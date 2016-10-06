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
 *  A request builder for the "recsUsingStrategy" endpoint.
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHStrategyRecsBuilder : RCHRequestBuilder

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
 *  Strategy family name.
 *
 *  @param strategy A strategy name, one of the values in RCHStrategy.
 */
- (instancetype)setStrategy:(RCHStrategy)strategy;

/*!
 *  A product, a category, or a search string depending on the type of strategy chosen for strategyName.
 *    - PurchaseCP, ClickCP: Use a product ID
 *    - CategoryCP2, CategoryTopSellers, NewArrivalsIncategory: Use a category ID
 *    - SolrSearchToProduct: Use a search term
 *    - BrandTopSellers: Use a brand
 *    - TopSellers, TopRatedProducts, movers_and_shakers_1, PersonalizedClickCP: No seed needed
 *    - Others: Use a product ID
 * 
 * recsUsingStrategy does not infer category information from product seeds.
 *
 *  @param seed The seed value.
 */
- (instancetype)setSeed:(NSString *)seed;

/*!
 *  How many categories to return. Default=5.
 *
 *  @param resultCount The result count.
 */
- (instancetype)setResultCount:(NSInteger)resultCount;

/*!
 *  Retrieves custom attributes provided in the catalog feed.
 *
 *  @param attributes A list of NSString instances, pass a list containing a single value of * to retrieve all attributes.
 */
- (instancetype)setCatalogFeedCustomAttributes:(NSArray<NSString *> *)attributes;

/*!
 *  Used only if the request is part of an email campaign.
 *
 *  @return The email campaign ID.
 */
- (instancetype)setEmailCampaignID:(NSString *)emailCampaignID;

/*!
 *  recsUsingStrategy simply returns this ID in the response object untouched. If you have multiple outstanding requests that were issued in parallel, the request ID lets you figure out which response matches which request. This parameter is purely for identifying responses if more than one requests were made asynchronously.
 *
 *  @param requestID A request ID.
 */
- (instancetype)setRequestID:(NSString *)requestID;

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
- (instancetype)setUserAttributes:(NSDictionary *)userAttributes;

/*!
 *  List of product IDs that should not be recommended in this response.
 *
 *  @param productIDs A list of product IDs for products that should not be recommended as part of this request/response, represented as instances of NSString.
 */
- (instancetype)setExcludeProductsFromRecommendations:(NSArray<NSString *> *)productIDs;

/*!
 *  Region ID. Must be consistent with the ID used in the product region feed.
 *
 *  @param regionID A region ID.
  */
- (instancetype)setRegionID:(NSString *)regionID;

@end
NS_ASSUME_NONNULL_END
