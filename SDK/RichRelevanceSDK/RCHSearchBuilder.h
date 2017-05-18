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
@class RCHSearchFacet;
@class RCHRequestPlacement;

NS_ASSUME_NONNULL_BEGIN
@interface RCHSearchBuilder : RCHRequestBuilder

/*!
 *  The text to search for.
 *
 *  @param text The string to obtain autocomplete suggestions for.
 */
- (instancetype)setQuery:(NSString *)text;

/*!
 *  The total number of suggestions to return in the response.
 *
 *  @param pageCount The total number of suggestions to return in the response.
 */
- (instancetype)setPageCount:(NSInteger)pageCount;

/*!
 *  The starting number for the suggestion that you want to return. (For example, if you want to return suggestions 30-60, this value would be 30.)
 *
 *  @param pageStart The starting number for returned suggestions.
 */
- (instancetype)setPageStart:(NSInteger)pageStart;

/*!
 *  The placement to query.
 *
 *  @param placement The placement to query.
 */
- (instancetype)setPlacement:(RCHRequestPlacement *)placement;

/*!
 *  The sort order for the array of returned products
 *
 *  @param field The field to sort by.
 *  @param ascending ascending or descending sort order.
 */
- (instancetype)addSortOrder:(NSString *)field ascending:(BOOL)ascending;

/*!
 *  Add a filter to the search, forcing results to have the specified field equal to the specified value.
 *
 *  @param field The field to filter on.
 *  @param value The value the field should be equal to.
 */
- (instancetype)addFilter:(NSString *)field value:(NSString *)value;

/*!
 *  Add a filter for a facet result. This will only return results that match the returned facet.
 *
 *  @param facet The facet returned from the API to filter with.
 */
- (instancetype)addFilterFromFacet:(RCHSearchFacet *)facet;

/*!
 *  Configure the facets to return with the query. By default all fields configured as facetable in the dashboard are returned.
 *
 *  @param fields The fields to create facets for
 */
- (instancetype)setFacetFields:(NSArray<NSString *> *)fields;

/*!
 *  The Language the query is performed in.
 *
 *  @param text The string to obtain autocomplete suggestions for.
 */
- (instancetype)setLocale:(NSLocale *)locale;

/*!
 *  A channel is a description of the caller of the application.  It used to describe the client, ie: an iOS app or a Call center app.
 *
 *  @param channel A description of the application
 */
- (instancetype)setChannel:(NSString *)channel;

/*!
 *  Only set it to false if you are testing the API.
 *
 *  @param logRequest The flag to tell the SDK to log the request.
 */
- (instancetype)setLogRequest:(BOOL)logRequest;

/*!
 *  Region ID. Must be consistent with the ID used in the product region feed.
 *
 *  @param regionID A region ID
 */
- (instancetype)setRegionID:(NSString *)regionID;

/*!
 *  Shopper’s referrer prior to viewing this page. Used for reporting and merchandising. Highly recommended.
 *
 *  @param shopperReferrer The shopper referrer.
 */
- (instancetype)setShopperReferrer:(NSString *)shopperReferrer;

@end
NS_ASSUME_NONNULL_END
