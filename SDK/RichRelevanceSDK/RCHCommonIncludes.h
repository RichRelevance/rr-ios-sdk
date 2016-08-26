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

#pragma mark - Placements

typedef NS_ENUM(NSInteger, RCHPlacementPageType) {
    RCHPlacementPageTypeNotSet = 0,
    RCHPlacementPageTypeHome,
    RCHPlacementPageTypeItem,
    RCHPlacementPageTypeAddToCart,
    RCHPlacementPageTypeSearch,
    RCHPlacementPageTypePurchaseComplete,
    RCHPlacementPageTypeCategory,
    RCHPlacementPageTypeCart,
    RCHPlacementPageTypePersonal,
};

///-------------------------------
/// @name Strategy
///-------------------------------

typedef NS_ENUM(NSInteger, RCHStrategy) {
    RCHStrategyDefault = 0,
    RCHStrategySiteWideBestSellers,
    RCHStrategyProductBoughtBought,
    RCHStrategyCategoryBestSellers,
    RCHStrategyProductViewedViewed,
    RCHStrategySearchBought,
    RCHStrategyRatingsReviews,
    RCHStrategyNewArrivals,
    RCHStrategyCategoryBoughtBought,
    RCHStrategyMoversAndShakers,
    RCHStrategyPersonalized,
    RCHStrategyBrandTopSellers,
};

///-------------------------------
/// @name Preferences
///-------------------------------

typedef NS_ENUM(NSInteger, RCHUserPrefActionType) {
    RCHUserPrefActionTypeNotSet = 0,
    RCHUserPrefActionTypeDislike,
    RCHUserPrefActionTypeLike,
    RCHUserPrefActionTypeNeutral,
    RCHUserPrefActionTypeNotForRecs
};

typedef NS_ENUM(NSInteger, RCHUserPrefFieldType) {
    RCHUserPrefFieldTypeNotSet = 0,
    RCHUserPrefFieldTypeBrand,
    RCHUserPrefFieldTypeCategory,
    RCHUserPrefFieldTypeProduct,
    RCHUserPrefFieldTypeStore,
    RCHUserPrefFieldTypeSkuSize
};

typedef NS_ENUM(NSInteger, RCHUserProfileFieldType) {
    RCHUserProfileFieldTypeNotSet = 0,
    RCHUserProfileFieldTypeViewedItems,
    RCHUserProfileFieldTypeClickedItems,
    RCHUserProfileFieldTypeReferrerUrls,
    RCHUserProfileFieldTypeOrders,
    RCHUserProfileFieldTypeViewedCategories,
    RCHUserProfileFieldTypeViewedBrands,
    RCHUserProfileFieldTypeAddedToCartItems,
    RCHUserProfileFieldTypeSearchedTerms,
    RCHUserProfileFieldTypeUserAttributes,
    RCHUserProfileFieldTypeUserSegments,
    RCHUserProfileFieldTypeVerbNouns,
    RCHUserProfileFieldTypeCountedEvents,
    RCHUserProfileFieldTypeAll
};

/*!
 A collection of helper methods to convert typedef values to strings and the reverse.
 */
@interface RCHEnumMappings : NSObject

///-------------------------------
/// @name Recommendations
///-------------------------------

/*!
 *  A mapping of placement type enum values to strings.
 *
 *  @param pageType The page type
 */
+ (NSString *)stringFromPageType:(RCHPlacementPageType)pageType;

/*!
 *  A mapping of string values to placement type enum values.
 *
 *  @param pageType The page type enum value.
 *
 */
+ (RCHPlacementPageType)pageTypeFromString:(NSString *)pageTypeString;

/*!
 *  A mapping of string values to strategy enum values.
 *
 *  @param strategy A string representation of the provided strategy enum value.
 */
+ (NSString *)stringFromStrategy:(RCHStrategy)strategy;

/*!
 *  A mapping of strategy string values to enum values.
 *
 *  @param strategyString A strategy string value representing the corresponding enum value.
 */
+ (RCHStrategy)strategyFromString:(NSString *)strategyString;

///-------------------------------
/// @name User Profile
///-------------------------------

/*!
 *  A mapping of string values to user profile field type enum values.
 *
 *  @param fieldType A field type enum value representing the corresponding string value.
 */
+ (NSString *)stringFromUserProfileFieldType:(RCHUserProfileFieldType)fieldType;

/*!
 *  A mapping of user profile field type string values to enum values.
 *
 *  @param fieldTypeString A field type string value representing the corresponding enum value.
 */
+ (RCHUserProfileFieldType)userProfileFieldTypeFromString:(NSString *)fieldTypeString;

///-------------------------------
/// @name User Preferences
///-------------------------------

/*!
 *  A mapping of string values to user pref target type enum values.
 *
 *  @param targetType A target type enum value representing the corresponding string value.
 */
+ (NSString *)stringFromUserPrefTargetType:(RCHUserPrefFieldType)targetType;

/*!
 *  A mapping of string values to user pref action type enum values.
 *
 *  @param actionType An action type enum value representing the corresponding string value.
 */
+ (NSString *)stringFromUserPrefActionType:(RCHUserPrefActionType)actionType;

/*!
 *  A mapping of string values to user pref field type enum values.
 *
 *  @param fieldType An action type enum value representing the corresponding string value.
 */
+ (NSString *)stringFromUserPrefFieldType:(RCHUserPrefFieldType)fieldType;

/*!
 *  A mapping of user pref field type string values to enum values.
 *
 *  @param fieldTypeString A field type string value representing the corresponding enum value.
 */
+ (RCHUserPrefFieldType)userPrefFieldTypeFromString:(NSString *)fieldTypeString;

@end
