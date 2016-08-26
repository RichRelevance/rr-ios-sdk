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

#import "RCHPersonalizeBuilder.h"
#import "RCHPersonalizeResponseParser.h"

@implementation RCHPersonalizeBuilder

- (instancetype)init
{
    self = [super initWithAPIPath:kRCHAPIRequestPersonalizePath];
    if (self) {
        [self setResponseParserClass:[RCHPersonalizeResponseParser class]];
    }
    return self;
}

#pragma mark - Parameters

- (instancetype)setCartValue:(NSInteger)cartValue;
{
    return [self setValue:@(cartValue) forKey:kRCHAPIRequestParamPersonalizeCartValue];
}

- (instancetype)setSpoofString:(NSString *)spoofString;
{
    return [self setValue:spoofString forKey:kRCHAPIRequestParamPersonalizeSpoof];
}

- (instancetype)setEmailCampaignID:(NSString *)emailCampaignID;
{
    return [self setValue:emailCampaignID forKey:kRCHAPIRequestParamPersonalizeEmailCampaignID];
}

- (instancetype)setExternalCategoryIDs:(NSArray *)externalCategoryIDs;
{
    return [self setArrayValue:externalCategoryIDs forKey:kRCHAPIRequestParamPersonalizeExternalCategoryIDs];
}

- (instancetype)setCategoryName:(NSString *)categoryName;
{
    return [self setValue:categoryName forKey:kRCHAPIRequestParamPersonalizeCategoryName];
}

- (instancetype)setRecProductCount:(NSInteger)count;
{
    return [self setValue:@(count) forKey:kRCHAPIRequestParamPersonalizeRecProductsCount];
}

- (instancetype)setCatalogFeedCustomAttributes:(NSArray *)attributes
{
    return [self setValue:attributes forKey:kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute];
}

@end
