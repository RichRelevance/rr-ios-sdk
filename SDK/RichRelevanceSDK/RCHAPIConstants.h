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

NS_ASSUME_NONNULL_BEGIN

///-------------------------------
/// @name General
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPICommonParamAPIKey;
OBJC_EXTERN NSString *const kRCHAPICommonParamAPIClientKey;
OBJC_EXTERN NSString *const kRCHAPICommonParamUserID;
OBJC_EXTERN NSString *const kRCHAPICommonParamSessionID;
OBJC_EXTERN NSString *const kRCHAPICommonParamUserIDShort;
OBJC_EXTERN NSString *const kRCHAPICommonParamSessionIDShort;
OBJC_EXTERN NSString *const kRCHAPICommonParamRCS;

///-------------------------------
/// @name Request Info
///-------------------------------

/*!
 *  An enum representing the style in which user and session IDs are passed to the API.
 */
typedef NS_ENUM(NSInteger, RCHAPIClientUserAndSessionParamStyle) {
    /*!
     *  Long style: ```userId=123&sessionId=456```
     */
    RCHAPIClientUserAndSessionParamStyleLong = 0,
    /*!
     *  Short style: ```u=123&s=456```
     */
    RCHAPIClientUserAndSessionParamStyleShort,
    /*!
     *  Do not include user and session ID params
     */
    RCHAPIClientUserAndSessionParamStyleNone,
    /*!
     *  Append the API Key to the path
     */
    RCHAPIClientUserAndSessionParamStyleAPIKeyInPath,
    /*!
     *  Long style: ```userId=123&sessionId=456``` with the API Key appended to the path
     */
    RCHAPIClientUserAndSessionParamStyleLongWithAPIKeyInPath
};

OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestParameters;
OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestInfo;
OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestInfoPath;
OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestInfoParserClass;
OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestInfoRequiresOAuth;
OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestInfoUserAndSessionStyle;
OBJC_EXTERN NSString *const kRCHAPIBuilderParamRequestInfoEmbedRCS;

///-------------------------------
/// @name Paths
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestRecsForPlacementsPath;
OBJC_EXTERN NSString *const kRCHAPIRequestRecsUsingStrategyPath;
OBJC_EXTERN NSString *const kRCHAPIRequestUserPrefPath;
OBJC_EXTERN NSString *const kRCHAPIRequestUserProfilePath;
OBJC_EXTERN NSString *const kRCHAPIRequestPersonalizePath;
OBJC_EXTERN NSString *const kRCHAPIRequestGetProductsPath;
OBJC_EXTERN NSString *const kRCHAPIRequestFindAutocompletePath;
OBJC_EXTERN NSString *const kRCHAPIRequestFindSearchPath;

///-------------------------------
/// @name Response
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIResponseKeyStatus;
OBJC_EXTERN NSString *const kRCHAPIResponseKeyStatusOK;
OBJC_EXTERN NSString *const kRCHAPIResponseKeyStatusError;
OBJC_EXTERN NSString *const kRCHAPIResponseKeyID;

///-------------------------------
/// @name Recommendations
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsPlacements;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsTimestamp;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsGenreFilter;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsBrandFilteredProducts;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsFeaturedPageBrand;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsMinPriceFilter;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsMaxPriceFilter;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsIncludePriceFilteredProducts;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsExcludeHtml;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsExcludeItemAttributes;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsExcludeRecItems;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsReturnMinimalRecItemData;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsIncludeCategoryData;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsExcludeProductsFromRecommendations;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsUserAttribute;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsRefinementRule;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsShopperReferrer;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsClickthroughServer;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsClickthroughParams;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsProductID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsCategoryID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsCategoryHintID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsSearchTerm;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsOrderID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsItemQuantities;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsProductPrices;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsProductPricesCents;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsUserSegments;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsRegistryID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsRegistryTypeID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsAlreadyAddedRegistryProductIDs;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsStrategySet;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsRegionID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsViewedProducts;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsPurchasedProducts;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsPageCount;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsPageStart;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsPriceRanges;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsFilterAttributes;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsStrategyName;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsStrategySeed;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsCategoryResultCount;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsEmailCampaignId;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsStrategyRequestID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsStrategyBlockedProductIds;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsStrategyRegionID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamRecommendationsAddedToCartProductID;

///-------------------------------
/// @name User Preferences
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestParamUserPrefViewGUID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamUserPrefPreference;
OBJC_EXTERN NSString *const kRCHAPIRequestParamUserPrefTargetType;
OBJC_EXTERN NSString *const kRCHAPIRequestParamUserPrefActionType;
OBJC_EXTERN NSString *const kRCHAPIRequestParamUserPrefFields;

///-------------------------------
/// @name User Profile
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestParamUserProfileFields;

///-------------------------------
/// @name Personalize
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestParamPersonalizeCartValue;
OBJC_EXTERN NSString *const kRCHAPIRequestParamPersonalizeSpoof;
OBJC_EXTERN NSString *const kRCHAPIRequestParamPersonalizeEmailCampaignID;
OBJC_EXTERN NSString *const kRCHAPIRequestParamPersonalizeExternalCategoryIDs;
OBJC_EXTERN NSString *const kRCHAPIRequestParamPersonalizeCategoryName;
OBJC_EXTERN NSString *const kRCHAPIRequestParamPersonalizeRecProductsCount;


///-------------------------------
/// @name Autocomplete
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestParamFindQuery;
OBJC_EXTERN NSString *const kRCHAPIRequestParamFindLanguage;
OBJC_EXTERN NSString *const kRCHAPIRequestParamFindStart;
OBJC_EXTERN NSString *const kRCHAPIRequestParamFindCount;

OBJC_EXTERN NSString *const kRCHAPIResponseKeyAutocompleteTerms;
OBJC_EXTERN NSString *const kRCHAPIResponseKeyAutocompleteType;
OBJC_EXTERN NSString *const kRCHAPIResponseKeyAutocompleteValue;

///-------------------------------
/// @name Search
///-------------------------------

OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchPlacement;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchFilter;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchFacet;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchSort;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchChannel;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchLog;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchRegion;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchReference;

OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchAscending;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchDescending;
OBJC_EXTERN NSString *const kRCHAPIRequestParamSearchSSL;

OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchProducts;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchPlacements;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchTrackingURL;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchNumFound;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchSpellChecked;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchLinks;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchFacets;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchFacet;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchValues;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchMessage;
OBJC_EXTERN NSString *const kRCHAPIResponseKeySearchAddToCartParams;

NS_ASSUME_NONNULL_END
