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

//  RCHCommonIncludes.m
//  RichRelevanceSDK
//
//  Created on 5/11/15.
//  Copyright (c) 2015 Rich Relevance Inc.All rights reserved.
//

#import "RCHCommonIncludes.h"

@implementation RCHEnumMappings

+ (NSString *)stringFromPageType:(RCHPlacementPageType)pageType
{
    static NSDictionary *typeToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeToString = @{
            @(RCHPlacementPageTypeHome) : @"home_page",
            @(RCHPlacementPageTypeItem) : @"item_page",
            @(RCHPlacementPageTypeAddToCart) : @"add_to_cart_page",
            @(RCHPlacementPageTypeSearch) : @"search_page",
            @(RCHPlacementPageTypePurchaseComplete) : @"purchase_complete_page",
            @(RCHPlacementPageTypeCategory) : @"category_page",
            @(RCHPlacementPageTypeCart) : @"cart_page",
            @(RCHPlacementPageTypePersonal) : @"personal_page",
        };
    });

    return typeToString[@(pageType)];
}

+ (RCHPlacementPageType)pageTypeFromString:(NSString *)pageTypeString
{
    static NSDictionary *stringToType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringToType = @{
            @"home_page" : @(RCHPlacementPageTypeHome),
            @"item_page" : @(RCHPlacementPageTypeItem),
            @"add_to_cart_page" : @(RCHPlacementPageTypeAddToCart),
            @"search_page" : @(RCHPlacementPageTypeSearch),
            @"purchase_complete_page" : @(RCHPlacementPageTypePurchaseComplete),
            @"category_page" : @(RCHPlacementPageTypeCategory),
            @"cart_page" : @(RCHPlacementPageTypeCart),
            @"personal_page" : @(RCHPlacementPageTypePersonal)
        };
    });

    return [stringToType[pageTypeString] integerValue];
}

+ (NSString *)stringFromStrategy:(RCHStrategy)strategy
{
    static NSDictionary *typeToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeToString = @{
            @(RCHStrategySiteWideBestSellers) : @"SiteWideBestSellers",
            @(RCHStrategyProductBoughtBought) : @"ProductBoughtBought",
            @(RCHStrategyCategoryBestSellers) : @"CategoryBestSellers",
            @(RCHStrategyProductViewedViewed) : @"ProductViewedViewed",
            @(RCHStrategySearchBought) : @"SearchBought",
            @(RCHStrategyRatingsReviews) : @"RatingsReviews",
            @(RCHStrategyNewArrivals) : @"NewArrivals",
            @(RCHStrategyCategoryBoughtBought) : @"CategoryBoughtBought",
            @(RCHStrategyMoversAndShakers) : @"MoversAndShakers",
            @(RCHStrategyPersonalized) : @"Personalized",
            @(RCHStrategyBrandTopSellers) : @"BrandTopSellers",
        };
    });

    return typeToString[@(strategy)];
}

+ (RCHStrategy)strategyFromString:(NSString *)strategyString
{
    static NSDictionary *stringToType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringToType = @{
            @"SiteWideBestSellers" : @(RCHStrategySiteWideBestSellers),
            @"ProductBoughtBought" : @(RCHStrategyProductBoughtBought),
            @"CategoryBestSellers" : @(RCHStrategyCategoryBestSellers),
            @"ProductViewedViewed" : @(RCHStrategyProductViewedViewed),
            @"SearchBought" : @(RCHStrategySearchBought),
            @"RatingsReviews" : @(RCHStrategyRatingsReviews),
            @"NewArrivals" : @(RCHStrategyNewArrivals),
            @"CategoryBoughtBought" : @(RCHStrategyCategoryBoughtBought),
            @"MoversAndShakers" : @(RCHStrategyMoversAndShakers),
            @"Personalized" : @(RCHStrategyPersonalized),
            @"BrandTopSellers" : @(RCHStrategyBrandTopSellers),
        };
    });

    return [stringToType[strategyString] integerValue];
}

+ (NSString *)stringFromUserProfileFieldType:(RCHUserProfileFieldType)fieldType
{
    static NSDictionary *typeToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeToString = @{
            @(RCHUserProfileFieldTypeViewedItems) : @"viewedItems",
            @(RCHUserProfileFieldTypeClickedItems) : @"clickedItems",
            @(RCHUserProfileFieldTypeReferrerUrls) : @"referrerUrls",
            @(RCHUserProfileFieldTypeOrders) : @"orders",
            @(RCHUserProfileFieldTypeViewedCategories) : @"viewedCategories",
            @(RCHUserProfileFieldTypeViewedBrands) : @"viewedBrands",
            @(RCHUserProfileFieldTypeAddedToCartItems) : @"addedToCartItems",
            @(RCHUserProfileFieldTypeSearchedTerms) : @"searchedTerms",
            @(RCHUserProfileFieldTypeUserAttributes) : @"userAttributes",
            @(RCHUserProfileFieldTypeUserSegments) : @"userSegments",
            @(RCHUserProfileFieldTypeVerbNouns) : @"verbNouns",
            @(RCHUserProfileFieldTypeCountedEvents) : @"countedEvents",
            @(RCHUserProfileFieldTypeAll) : @"all",
        };
    });

    return typeToString[@(fieldType)];
}

+ (RCHUserProfileFieldType)userProfileFieldTypeFromString:(NSString *)fieldTypeString
{
    static NSDictionary *stringToType = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringToType = @{
            @"viewedItems" : @(RCHUserProfileFieldTypeViewedItems),
            @"clickedItems" : @(RCHUserProfileFieldTypeClickedItems),
            @"referrerUrls" : @(RCHUserProfileFieldTypeReferrerUrls),
            @"orders" : @(RCHUserProfileFieldTypeOrders),
            @"viewedCategories" : @(RCHUserProfileFieldTypeViewedCategories),
            @"viewedBrands" : @(RCHUserProfileFieldTypeViewedBrands),
            @"addedToCartItems" : @(RCHUserProfileFieldTypeAddedToCartItems),
            @"searchedTerms" : @(RCHUserProfileFieldTypeSearchedTerms),
            @"userAttributes" : @(RCHUserProfileFieldTypeUserAttributes),
            @"userSegments" : @(RCHUserProfileFieldTypeUserSegments),
            @"verbNouns" : @(RCHUserProfileFieldTypeVerbNouns),
            @"countedEvents" : @(RCHUserProfileFieldTypeCountedEvents),
            @"all" : @(RCHUserProfileFieldTypeAll)
        };
    });

    return [stringToType[fieldTypeString] integerValue];
}

+ (NSString *)stringFromUserPrefTargetType:(RCHUserPrefFieldType)targetType
{
    static NSDictionary *typeToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeToString = @{
            @(RCHUserPrefFieldTypeBrand) : @"brand",
            @(RCHUserPrefFieldTypeCategory) : @"category",
            @(RCHUserPrefFieldTypeProduct) : @"product",
            @(RCHUserPrefFieldTypeStore) : @"store",
            @(RCHUserPrefFieldTypeSkuSize) : @"skuSize"
        };
    });

    return typeToString[@(targetType)];
}

+ (NSString *)stringFromUserPrefActionType:(RCHUserPrefActionType)actionType
{
    static NSDictionary *typeToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeToString = @{
            @(RCHUserPrefActionTypeDislike) : @"dislike",
            @(RCHUserPrefActionTypeLike) : @"like",
            @(RCHUserPrefActionTypeNeutral) : @"neutral",
            @(RCHUserPrefActionTypeNotForRecs) : @"notForRecs"
        };
    });

    return typeToString[@(actionType)];
}

+ (NSString *)stringFromUserPrefFieldType:(RCHUserPrefFieldType)fieldType
{
    static NSDictionary *typeToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        typeToString = @{
            @(RCHUserPrefFieldTypeBrand) : @"pref_brand",
            @(RCHUserPrefFieldTypeCategory) : @"pref_category",
            @(RCHUserPrefFieldTypeProduct) : @"pref_product",
            @(RCHUserPrefFieldTypeStore) : @"pref_store",
            @(RCHUserPrefFieldTypeSkuSize) : @"pref_skueSize"
        };
    });

    return typeToString[@(fieldType)];
}

+ (RCHUserPrefFieldType)userPrefFieldTypeFromString:(NSString *)fieldTypeString
{
    static NSDictionary *stringToTypes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stringToTypes = @{
            @"pref_brand" : @(RCHUserPrefFieldTypeBrand),
            @"pref_category" : @(RCHUserPrefFieldTypeCategory),
            @"pref_product" : @(RCHUserPrefFieldTypeProduct),
            @"pref_store" : @(RCHUserPrefFieldTypeStore),
            @"pref_skueSize" : @(RCHUserPrefFieldTypeSkuSize)
        };
    });

    return [stringToTypes[fieldTypeString] integerValue];
}

@end
