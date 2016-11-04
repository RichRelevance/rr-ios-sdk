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

@import Foundation;
#import "RCHCommonIncludes.h"
#import "RCHLogLevels.h"
#import "RCHAPIClient.h"
#import "RCHAPIClientConfig.h"

@class RCHRequestBuilder;
@class RCHPlacementRecsBuilder;
@class RCHStrategyRecsBuilder;
@class RCHUserPrefBuilder;
@class RCHUserProfileBuilder;
@class RCHRequestPlacement;
@class RCHRequestProduct;
@class RCHPersonalizeBuilder;
@class RCHGetProductsBuilder;
@class RCHAutocompleteBuilder;
@class RCHSearchBuilder;

/*!
 *  The central launchpoint for all Rich Relevance SDK activity. 
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHSDK : NSObject

///-------------------------------
/// @name Logging
///-------------------------------

/*!
*  Set the SDK log level. Default value is RCHLogLevelOff
*  @warning Ensure this value is set to RCHLogLevelOff for production builds as logging can have adverse
*           performance ramifications.
*
*  @param logLevel The log level, one of the values in RCHLogLevel
*/
+ (void)setLogLevel:(RCHLogLevel)logLevel;

///-------------------------------
/// @name API Client
///-------------------------------

/*!
 *  Access the default API client. Use this client to execute all API requests.
 *
 *  @return The default API client
 */
+ (RCHAPIClient *)defaultClient;

///-------------------------------
/// @name Fetch Builder Helpers
///-------------------------------

/*!
 *  Produces a builder that represents a request for placements using the specified strategy.
 *
 *  @param strategy The strategy to use, one of the values in RCHStrategy
 *
 *  @return A pre-populated builder
 */
+ (RCHStrategyRecsBuilder *)builderForRecsWithStrategy:(RCHStrategy)strategy;

/*!
 *  Produces a builder that represents a request for the specified placement and category ID.
 *
 *  @param categoryID The category ID
 *  @param placement  An instance of RCHRequestPlacement representing the desired placement
 *
 *  @return A pre-populated builder
 */
+ (RCHPlacementRecsBuilder *)builderForRecsWithCategoryID:(NSString *)categoryID
                                                placement:(RCHRequestPlacement *)placement;
/*!
 *  Produces a builder that represents a request for the specified placement and search term.
 *
 *  @param searchTerm The search term
 *  @param placement  An instance of RCHRequestPlacement representing the desired placement
 *
 *  @return A pre-populated builder
 */
+ (RCHPlacementRecsBuilder *)builderForRecsWithSearchTerm:(NSString *)searchTerm
                                                placement:(RCHRequestPlacement *)placement;
/*!
 *  Produces a builder that represents a request for the specified placement, personalized to the current user.
 *
 *  @param placement  An instance of RCHRequestPlacement representing the desired placement
 *
 *  @return A pre-populated builder
 */
+ (RCHPlacementRecsBuilder *)builderForRecsWithPlacement:(RCHRequestPlacement *)placement;

/*!
 *  Produces a builder that represents a request for the current user's preferences.
 *
 *  @param fieldType The desired field type, one of the values in RCHUserPrefFieldType. 
 *                   Call ```addFetchPreference``` on the returned RCHUserPrefBuilder instance to add
 *                   additional preferences to this request.
 *
 *  @return A pre-populated builder
 */
+ (RCHUserPrefBuilder *)builderForUserPrefFieldType:(RCHUserPrefFieldType)fieldType;

/*!
 *  Produces a builder that represents a request for the current user's profile information.
 *
 *  @param fieldType The desired field type, one of the values in RCHUserProfileFieldType.
 *                   Call ```addFieldType``` on the returned RCHUserProfileBuilder instance to add
 *                   additional profile fields to this request.
 *
 *  @return A pre-populated builder
 */
+ (RCHUserProfileBuilder *)builderForUserProfileFieldType:(RCHUserProfileFieldType)fieldType;

/*!
 *  Produces a builder that represents a request for personalize data for the provided placement.
 *
 *  @param placement  An instance of RCHRequestPlacement representing the desired placement
 *
 *  @return A pre-populated builder
 */
+ (RCHPersonalizeBuilder *)builderForPersonalizeWithPlacement:(RCHRequestPlacement *)placement;

/*!
 *  Produces a builder that represents a request for products.
 *
 *  @param productIDs  An NSArray of NSString objects representing product IDs for  which to fetch product info
 *
 *  @return A pre-populated builder
 */
+ (RCHGetProductsBuilder *)builderForGetProducts:(NSArray<NSString *> *)productIDs;

///-------------------------------
/// @name Tracking Builder Helpers
///-------------------------------

/*!
 *  Produces a builder that represents a request to track a product view.
 *
 *  @param productID The product that was viewed.
 *
 *  @return A pre-populated builder
 */
+ (RCHPlacementRecsBuilder *)builderForTrackingProductViewWithProductID:(NSString *)productID;

/*!
 *  Produces a builder that represents a request to track a product purchase.
 *
 *  @param orderID   The order ID for the purchase
 *  @param product   An instance of RCHRequestProduct representing the product info for this purchase
 *
 *  @return A pre-populated builder
 */
+ (RCHPlacementRecsBuilder *)builderForTrackingPurchaseWithOrderID:(NSString *)orderID
                                                           product:(RCHRequestProduct *)product;

/*!
 *  Produces a builder that represents a request to track a category view.
 *
 *  @param categoryID   The category ID that was viewed.
 *
 *  @return A pre-populated builder
 */
+ (RCHPlacementRecsBuilder *)builderForTrackingCategoryViewWithCategoryID:(NSString *)categoryID;

/*!
 *  Produces a builder that represents a request to track a user preference.
 *
 *  @param preferences A list of NSString instances representing the preferred items
 *  @param targetType  The target field type, one of the values in RCHUserPrefFieldType
 *  @param actionType  The action type, one of the values in RCHUserPrefActionType
 *
 *  @return A pre-populated builder
 */
+ (RCHUserPrefBuilder *)builderForTrackingPreferences:(NSArray<NSString *> *)preferences
                                           targetType:(RCHUserPrefFieldType)targetType
                                           actionType:(RCHUserPrefActionType)actionType;


/*!
 *  Produce a builder to retrieve autocomplete options.
 *
 *  @param query The text to be autocompleted
 *
 *  @return A pre-populated builder
 */
+ (RCHAutocompleteBuilder *)builderForAutocompleteWithQuery:(NSString *)query;

/*!
 *  Produce a builder to search with the specified query
 *
 *  @param placement The placement to search
 *  @param query The text to be searched
 *
 *  @return A pre-populated builder
 */
+ (RCHSearchBuilder *)builderForSearchPlacement:(RCHRequestPlacement *)placement withQuery:(NSString *)query;


@end
NS_ASSUME_NONNULL_END
