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

//! Project version number for RichRelevanceSDK.
FOUNDATION_EXPORT double RichRelevanceSDKVersionNumber;

//! Project version string for RichRelevanceSDK.
FOUNDATION_EXPORT const unsigned char RichRelevanceSDKVersionString[];

// GENERAL

#import <RichRelevanceSDK/RCHSDK.h>
#import <RichRelevanceSDK/RCHLogLevels.h>
#import <RichRelevanceSDK/RCHCommonIncludes.h>
#import <RichRelevanceSDK/RCHErrors.h>

// REQUEST BUILDERS

#import <RichRelevanceSDK/RCHRequestBuilder.h>
#import <RichRelevanceSDK/RCHPlacementsBuilder.h>
#import <RichRelevanceSDK/RCHPlacementRecsBuilder.h>
#import <RichRelevanceSDK/RCHStrategyRecsBuilder.h>
#import <RichRelevanceSDK/RCHUserPrefBuilder.h>
#import <RichRelevanceSDK/RCHUserProfileBuilder.h>
#import <RichRelevanceSDK/RCHPersonalizeBuilder.h>
#import <RichRelevanceSDK/RCHGetProductsBuilder.h>
#import <RichRelevanceSDK/RCHAutocompleteBuilder.h>
#import <RichRelevanceSDK/RCHSearchBuilder.h>

// API

#import <RichRelevanceSDK/RCHAPIClient.h>
#import <RichRelevanceSDK/RCHAPIClientConfig.h>
#import <RichRelevanceSDK/RCHAPIConstants.h>

// MODEL

#import <RichRelevanceSDK/RCHAPIResult.h>
#import <RichRelevanceSDK/RCHRange.h>
#import <RichRelevanceSDK/RCHPlacementsResult.h>
#import <RichRelevanceSDK/RCHStrategyResult.h>
#import <RichRelevanceSDK/RCHPlacement.h>
#import <RichRelevanceSDK/RCHRecommendedPlacement.h>
#import <RichRelevanceSDK/RCHRecommendedProduct.h>
#import <RichRelevanceSDK/RCHCategory.h>
#import <RichRelevanceSDK/RCHUserPrefResult.h>
#import <RichRelevanceSDK/RCHUserPreference.h>
#import <RichRelevanceSDK/RCHUserProfileResult.h>
#import <RichRelevanceSDK/RCHUserProfileElement.h>
#import <RichRelevanceSDK/RCHImportable.h>
#import <RichRelevanceSDK/RCHPersonalizeResult.h>
#import <RichRelevanceSDK/RCHPersonalizedPlacement.h>
#import <RichRelevanceSDK/RCHCreative.h>
#import <RichRelevanceSDK/RCHGetProductsResult.h>
#import <RichRelevanceSDK/RCHSearchResult.h>
#import <RichRelevanceSDK/RCHSearchLink.h>
#import <RichRelevanceSDK/RCHSearchProduct.h>
#import <RichRelevanceSDK/RCHSearchFacet.h>

// RESPONSE PARSER

#import <RichRelevanceSDK/RCHAPIResponseParser.h>
#import <RichRelevanceSDK/RCHRecsForPlacementsResponseParser.h>
#import <RichRelevanceSDK/RCHRecsUsingStrategyResponseParser.h>
#import <RichRelevanceSDK/RCHUserPrefResponseParser.h>
#import <RichRelevanceSDK/RCHUserProfileResponseParser.h>
#import <RichRelevanceSDK/RCHPersonalizeResponseParser.h>
#import <RichRelevanceSDK/RCHGetProductsResponseParser.h>
