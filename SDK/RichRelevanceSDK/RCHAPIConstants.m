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

#import "RCHAPIConstants.h"

#pragma mark - Common

NSString *const kRCHAPICommonParamAPIKey = @"apiKey";
NSString *const kRCHAPICommonParamAPIClientKey = @"apiClientKey";
NSString *const kRCHAPICommonParamUserID = @"userId";
NSString *const kRCHAPICommonParamSessionID = @"sessionId";
NSString *const kRCHAPICommonParamUserIDShort = @"u";
NSString *const kRCHAPICommonParamSessionIDShort = @"s";

#pragma mark - Request Info

NSString *const kRCHAPIBuilderParamRequestParameters = @"com.richrelevance.SDK.RequestParameters";
NSString *const kRCHAPIBuilderParamRequestInfo = @"com.richrelevance.SDK.RequestInfo";
NSString *const kRCHAPIBuilderParamRequestInfoPath = @"com.richrelevance.SDK.RequestPath";
NSString *const kRCHAPIBuilderParamRequestInfoParserClass = @"com.richrelevance.SDK.ResponseParserClass";
NSString *const kRCHAPIBuilderParamRequestInfoRequiresOAuth = @"com.richrelevance.SDK.RequiresOAuth";
NSString *const kRCHAPIBuilderParamRequestInfoUserAndSessionStyle = @"com.richrelevance.SDK.UserAndSessionParamStyle";

#pragma mark - Response

NSString *const kRCHAPIResponseKeyStatus = @"status";
NSString *const kRCHAPIResponseKeyStatusOK = @"ok";
NSString *const kRCHAPIResponseKeyStatusError = @"error";
NSString *const kRCHAPIResponseKeyID = @"id";

#pragma mark - Paths

NSString *const kRCHAPIRequestRecsForPlacementsPath = @"rrserver/api/rrPlatform/recsForPlacements";
NSString *const kRCHAPIRequestRecsUsingStrategyPath = @"rrserver/api/rrPlatform/recsUsingStrategy";
NSString *const kRCHAPIRequestUserPrefPath = @"rrserver/api/user/preference";
NSString *const kRCHAPIRequestUserProfilePath = @"userProfile/api/v1/service/userProfile";
NSString *const kRCHAPIRequestPersonalizePath = @"rrserver/api/personalize";
NSString *const kRCHAPIRequestGetProductsPath = @"rrserver/api/rrPlatform/getProducts";

#pragma mark - Recommendations

NSString *const kRCHAPIRequestParamRecommendationsPlacements = @"placements";
NSString *const kRCHAPIRequestParamRecommendationsTimestamp = @"ts";
NSString *const kRCHAPIRequestParamRecommendationsGenreFilter = @"genreFilter";
NSString *const kRCHAPIRequestParamRecommendationsBrandFilteredProducts = @"filter";
NSString *const kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts = @"includeBrandFilteredProducts";
NSString *const kRCHAPIRequestParamRecommendationsFeaturedPageBrand = @"fpb";
NSString *const kRCHAPIRequestParamRecommendationsMinPriceFilter = @"minPriceFilter";
NSString *const kRCHAPIRequestParamRecommendationsMaxPriceFilter = @"maxPriceFilter";
NSString *const kRCHAPIRequestParamRecommendationsIncludePriceFilteredProducts = @"includePriceFilteredProducts";
NSString *const kRCHAPIRequestParamRecommendationsExcludeHtml = @"excludeHtml";
NSString *const kRCHAPIRequestParamRecommendationsExcludeItemAttributes = @"excludeItemAttributes";
NSString *const kRCHAPIRequestParamRecommendationsExcludeRecItems = @"excludeRecItems";
NSString *const kRCHAPIRequestParamRecommendationsReturnMinimalRecItemData = @"returnMinimalRecItemData";
NSString *const kRCHAPIRequestParamRecommendationsIncludeCategoryData = @"categoryData";
NSString *const kRCHAPIRequestParamRecommendationsExcludeProductsFromRecommendations = @"bi";
NSString *const kRCHAPIRequestParamRecommendationsUserAttribute = @"userAttribute";
NSString *const kRCHAPIRequestParamRecommendationsRefinementRule = @"rfm";
NSString *const kRCHAPIRequestParamRecommendationsShopperReferrer = @"pref";
NSString *const kRCHAPIRequestParamRecommendationsClickthroughServer = @"cts";
NSString *const kRCHAPIRequestParamRecommendationsClickthroughParams = @"ctp";
NSString *const kRCHAPIRequestParamRecommendationsProductID = @"productId";
NSString *const kRCHAPIRequestParamRecommendationsCategoryID = @"categoryId";
NSString *const kRCHAPIRequestParamRecommendationsCategoryHintID = @"chi";
NSString *const kRCHAPIRequestParamRecommendationsSearchTerm = @"searchTerm";
NSString *const kRCHAPIRequestParamRecommendationsOrderID = @"o";
NSString *const kRCHAPIRequestParamRecommendationsItemQuantities = @"q";
NSString *const kRCHAPIRequestParamRecommendationsProductPrices = @"pp";
NSString *const kRCHAPIRequestParamRecommendationsProductPricesCents = @"ppc";
NSString *const kRCHAPIRequestParamRecommendationsUserSegments = @"sgs";
NSString *const kRCHAPIRequestParamRecommendationsRegistryID = @"rg";
NSString *const kRCHAPIRequestParamRecommendationsRegistryTypeID = @"rgt";
NSString *const kRCHAPIRequestParamRecommendationsAlreadyAddedRegistryProductIDs = @"aari";
NSString *const kRCHAPIRequestParamRecommendationsStrategySet = @"strategySet";
NSString *const kRCHAPIRequestParamRecommendationsRegionID = @"rid";
NSString *const kRCHAPIRequestParamRecommendationsViewedProducts = @"viewed";
NSString *const kRCHAPIRequestParamRecommendationsPurchasedProducts = @"purchased";
NSString *const kRCHAPIRequestParamRecommendationsPageCount = @"count";
NSString *const kRCHAPIRequestParamRecommendationsPageStart = @"st";
NSString *const kRCHAPIRequestParamRecommendationsPriceRanges = @"priceRanges";
NSString *const kRCHAPIRequestParamRecommendationsFilterAttributes = @"filterAtr";
NSString *const kRCHAPIRequestParamRecommendationsStrategyName = @"strategyName";
NSString *const kRCHAPIRequestParamRecommendationsStrategySeed = @"seed";
NSString *const kRCHAPIRequestParamRecommendationsCategoryResultCount = @"resultCount";
NSString *const kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute = @"attribute";
NSString *const kRCHAPIRequestParamRecommendationsEmailCampaignId = @"emailCampaignId";
NSString *const kRCHAPIRequestParamRecommendationsStrategyRequestID = @"requestId";
NSString *const kRCHAPIRequestParamRecommendationsStrategyBlockedProductIds = @"blockedProductIds";
NSString *const kRCHAPIRequestParamRecommendationsStrategyRegionID = @"region";

#pragma mark - User Pref

NSString *const kRCHAPIRequestParamUserPrefViewGUID = @"vg";
NSString *const kRCHAPIRequestParamUserPrefPreference = @"p";
NSString *const kRCHAPIRequestParamUserPrefTargetType = @"targetType";
NSString *const kRCHAPIRequestParamUserPrefActionType = @"actionType";
NSString *const kRCHAPIRequestParamUserPrefFields = @"fields";

#pragma mark - User Profile

NSString *const kRCHAPIRequestParamUserProfileFields = @"fields";

#pragma mark - Personalize

NSString *const kRCHAPIRequestParamPersonalizeCartValue = @"cv";
NSString *const kRCHAPIRequestParamPersonalizeSpoof = @"spoof";
NSString *const kRCHAPIRequestParamPersonalizeEmailCampaignID = @"cpi";
NSString *const kRCHAPIRequestParamPersonalizeExternalCategoryIDs = @"cis";
NSString *const kRCHAPIRequestParamPersonalizeCategoryName = @"cn";
NSString *const kRCHAPIRequestParamPersonalizeRecProductsCount = @"recProductsCount";
