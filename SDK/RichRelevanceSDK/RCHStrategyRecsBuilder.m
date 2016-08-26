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

#import "RCHStrategyRecsBuilder.h"
#import "RCHAPIConstants.h"
#import "RCHRecsUsingStrategyResponseParser.h"

@implementation RCHStrategyRecsBuilder

- (instancetype)init
{
    self = [super initWithAPIPath:kRCHAPIRequestRecsUsingStrategyPath];
    if (self) {
        [self setResponseParserClass:[RCHRecsUsingStrategyResponseParser class]];
    }
    return self;
}

- (instancetype)setStrategy:(RCHStrategy)strategy
{
    return [self setValue:[RCHEnumMappings stringFromStrategy:strategy] forKey:kRCHAPIRequestParamRecommendationsStrategyName];
}

- (instancetype)setSeed:(NSString *)seed
{
    return [self setValue:seed forKey:kRCHAPIRequestParamRecommendationsStrategySeed];
}

- (instancetype)setResultCount:(NSInteger)resultCount
{
    return [self setValue:@(resultCount) forKey:kRCHAPIRequestParamRecommendationsCategoryResultCount];
}

- (instancetype)setCatalogFeedCustomAttributes:(NSArray *)attributes
{
    return [self setValue:attributes forKey:kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute];
}

- (instancetype)setEmailCampaignID:(NSString *)emailCampaignID
{
    return [self setValue:emailCampaignID forKey:kRCHAPIRequestParamRecommendationsEmailCampaignId];
}

- (instancetype)setRequestID:(NSString *)requestID
{
    return [self setValue:requestID forKey:kRCHAPIRequestParamRecommendationsStrategyRequestID];
}

- (instancetype)setIncludeCategoryData:(BOOL)includeCategoryData
{
    return [self setValue:@(includeCategoryData) forKey:kRCHAPIRequestParamRecommendationsIncludeCategoryData];
}

- (instancetype)setUserAttributes:(NSDictionary *)userAttributes
{
    return [self setDictionaryValue:userAttributes forKey:kRCHAPIRequestParamRecommendationsUserAttribute flattenKeys:NO];
}

- (instancetype)setExcludeProductsFromRecommendations:(NSArray *)productIDs
{
    return [self setValue:productIDs forKey:kRCHAPIRequestParamRecommendationsStrategyBlockedProductIds];
}

- (instancetype)setRegionID:(NSString *)regionID
{
    return [self setValue:regionID forKey:kRCHAPIRequestParamRecommendationsStrategyRegionID];
}

@end
