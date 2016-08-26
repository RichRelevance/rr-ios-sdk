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

#import "RCHPlacementRecsBuilder.h"
#import "RCHLog.h"
#import "RCHAPIConstants.h"
#import "RCHRecsForPlacementsResponseParser.h"

@interface RCHPlacementRecsBuilder ()

@property (assign, nonatomic, getter=isTimestampEnabled) BOOL timestampEnabled;

@end

@implementation RCHPlacementRecsBuilder

- (instancetype)init
{
    self = [super initWithAPIPath:kRCHAPIRequestRecsForPlacementsPath];
    if (self) {
        [self setResponseParserClass:[RCHRecsForPlacementsResponseParser class]];
        _timestampEnabled = YES;
    }
    return self;
}

- (instancetype)setAddTimestampEnabled:(BOOL)addTimestamp;
{
    self.timestampEnabled = addTimestamp;
    return self;
}

- (instancetype)setFilterByIncludedBrands:(NSArray *)brands
{
    if (brands != nil) {
        [self setArrayValue:brands forKey:kRCHAPIRequestParamRecommendationsBrandFilteredProducts];
        [self setValue:@YES forKey:kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts];
    }

    return self;
}

- (instancetype)setFilterByExcludedBrands:(NSArray *)brands
{
    if (brands != nil) {
        [self setArrayValue:brands forKey:kRCHAPIRequestParamRecommendationsBrandFilteredProducts];
        [self setValue:@NO forKey:kRCHAPIRequestParamRecommendationsIncludeBrandFilteredProducts];
    }

    return self;
}

- (instancetype)setFilterByIncludingPriceRange:(RCHRange *)range;
{
    if (range.min != nil) {
        [self setValue:range.min forKey:kRCHAPIRequestParamRecommendationsMinPriceFilter];
    }

    if (range.max != nil) {
        [self setValue:range.max forKey:kRCHAPIRequestParamRecommendationsMaxPriceFilter];
    }

    return [self setValue:@YES forKey:kRCHAPIRequestParamRecommendationsIncludePriceFilteredProducts];
}

- (instancetype)setFilterByExcludingPriceRange:(RCHRange *)range;
{
    if (range.min != nil) {
        [self setValue:range.min forKey:kRCHAPIRequestParamRecommendationsMinPriceFilter];
    }

    if (range.max != nil) {
        [self setValue:range.max forKey:kRCHAPIRequestParamRecommendationsMaxPriceFilter];
    }

    return [self setValue:@NO forKey:kRCHAPIRequestParamRecommendationsIncludePriceFilteredProducts];
}

- (instancetype)setExcludeItemAttributes:(BOOL)excludeItemAttributes
{
    return [self setValue:@(excludeItemAttributes) forKey:kRCHAPIRequestParamRecommendationsExcludeItemAttributes];
}

- (instancetype)setExcludeRecItems:(BOOL)excludeRecItems
{
    return [self setValue:@(excludeRecItems) forKey:kRCHAPIRequestParamRecommendationsExcludeRecItems];
}

- (instancetype)setReturnMinimalRecItemData:(BOOL)returnMinimalRecItemData
{
    return [self setValue:@(returnMinimalRecItemData) forKey:kRCHAPIRequestParamRecommendationsReturnMinimalRecItemData];
}

- (instancetype)setExcludeProductsFromRecommendations:(NSArray *)productIDs;
{
    return [self setArrayValue:productIDs forKey:kRCHAPIRequestParamRecommendationsExcludeProductsFromRecommendations];
}

- (instancetype)setRefinements:(NSDictionary *)refinements
{
    return [self setDictionaryValue:refinements forKey:kRCHAPIRequestParamRecommendationsRefinementRule flattenKeys:YES];
}

- (instancetype)setProductIDs:(NSArray *)productIDs
{
    return [self setArrayValue:productIDs forKey:kRCHAPIRequestParamRecommendationsProductID];
}

- (instancetype)setCategoryID:(NSString *)categoryID
{
    return [self setValue:categoryID forKey:kRCHAPIRequestParamRecommendationsCategoryID];
}

- (instancetype)setSearchTerm:(NSString *)searchTerm
{
    return [self setValue:searchTerm forKey:kRCHAPIRequestParamRecommendationsSearchTerm];
}

- (instancetype)setOrderID:(NSString *)orderID
{
    return [self setValue:orderID forKey:kRCHAPIRequestParamRecommendationsOrderID];
}

- (instancetype)addPurchasedProduct:(RCHRequestProduct *)product
{
    if (product != nil) {
        [self addValue:product.identifier toArrayForhKey:kRCHAPIRequestParamRecommendationsProductID];
        [self addValue:product.quantity toArrayForhKey:kRCHAPIRequestParamRecommendationsItemQuantities];
        [self addValue:product.priceCents toArrayForhKey:kRCHAPIRequestParamRecommendationsProductPricesCents];
        [self addValue:product.priceDollars toArrayForhKey:kRCHAPIRequestParamRecommendationsProductPrices];
    }
    else {
        [RCHLog logError:@"Invalid parameter, nil  product passed to %@", NSStringFromSelector(_cmd)];
    }

    return self;
}

- (instancetype)setRegistryID:(NSString *)registryID;
{
    return [self setValue:registryID forKey:kRCHAPIRequestParamRecommendationsRegistryID];
}

- (instancetype)setRegistryTypeID:(NSString *)registryTypeID
{
    return [self setValue:registryTypeID forKey:kRCHAPIRequestParamRecommendationsRegistryTypeID];
}

- (instancetype)setAlreadyAddedRegistryProductIDs:(NSArray *)productIDs
{
    return [self setArrayValue:productIDs forKey:kRCHAPIRequestParamRecommendationsAlreadyAddedRegistryProductIDs];
}

- (instancetype)addStrategy:(RCHStrategy)strategy
{
    if (strategy != RCHStrategyDefault) {
        NSString *strategyString = [RCHEnumMappings stringFromStrategy:strategy];
        [self addValue:strategyString toArrayForhKey:kRCHAPIRequestParamRecommendationsStrategySet];
    }

    return self;
}

- (instancetype)setPageCount:(NSInteger)pageCount
{
    return [self setValue:@(pageCount) forKey:kRCHAPIRequestParamRecommendationsPageCount];
}

- (instancetype)setPageStart:(NSInteger)pageStart
{
    return [self setValue:@(pageStart) forKey:kRCHAPIRequestParamRecommendationsPageStart];
}

- (instancetype)setPriceRanges:(NSArray *)ranges
{
    NSMutableArray *rangeStrings = [NSMutableArray array];
    for (id range in ranges) {
        if ([range isKindOfClass:[RCHRange class]] && [range min] != nil && [range max] != nil) {
            [rangeStrings addObject:[range delimitedStringValue]];
        }
        else {
            [RCHLog logError:@"Invalid parameter, when filtering by price ranges, you must specify instances of %@.", NSStringFromClass([RCHRange class])];
        }
    }

    return [self setArrayValue:rangeStrings forKey:kRCHAPIRequestParamRecommendationsPriceRanges];
}

- (instancetype)setFilterAttributes:(NSDictionary *)filterAttributes
{
    return [self setDictionaryValue:filterAttributes forKey:kRCHAPIRequestParamRecommendationsFilterAttributes flattenKeys:NO];
}

#pragma mark - Build

- (NSDictionary *)build
{
    if (self.isTimestampEnabled) {
        NSString *timestampString = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970]];
        [self setValue:timestampString forKey:kRCHAPIRequestParamRecommendationsTimestamp];
    }

    return [[super build] mutableCopy];
}

@end
