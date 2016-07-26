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

#import "RCHPlacementsBuilder.h"
#import "RCHLog.h"
#import "RCHAPIConstants.h"
#import "RCHRecsForPlacementsResponseParser.h"

static NSString *const kRCHRequestPlacementDelimiter = @".";

@interface RCHRequestPlacement ()

@end

@implementation RCHRequestPlacement

- (instancetype)initWithListeningPageType:(RCHPlacementPageType)pageType
{
    if (pageType == RCHPlacementPageTypeNotSet) {
        [RCHLog logError:@"Invalid input, you must provide a valid pageType"];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _pageType = pageType;
        _name = nil;
    }
    
    return self;
}

- (instancetype)initWithPageType:(RCHPlacementPageType)pageType name:(NSString *)name;
{
    if (pageType == RCHPlacementPageTypeNotSet || name == nil || name.length == 0) {
        [RCHLog logError:@"Invalid input, you must provide a valid pageType and name"];
        return nil;
    }

    self = [super init];
    if (self) {
        _pageType = pageType;
        _name = name;
    }
    return self;
}

- (NSString *)stringRepresentation
{
    if (self.name == nil || self.name.length == 0) {
        return [RCHEnumMappings stringFromPageType:self.pageType];
    }
    
    return [NSString stringWithFormat:@"%@%@%@", [RCHEnumMappings stringFromPageType:self.pageType],
                                      kRCHRequestPlacementDelimiter,
                                      self.name];
}

@end

@interface RCHRequestProduct ()

@end

@implementation RCHRequestProduct

- (instancetype)initWithIdentifier:(NSString *)identifier quantity:(NSNumber *)quantity priceCents:(NSNumber *)priceCents
{
    if (identifier == nil || identifier.length == 0 || quantity == nil || priceCents == nil) {
        [RCHLog logError:@"You must provide a valid product identifier, quantity, and price when creating an instance of %@", NSStringFromClass([self class])];
        return nil;
    }

    self = [super init];
    if (self) {
        _identifier = identifier;
        _quantity = quantity;
        _priceCents = priceCents;
    }
    return self;
}

- (instancetype)initWithIdentifier:(NSString *)identifier quantity:(NSNumber *)quantity priceDollars:(NSNumber *)priceDollars;
{
    if (identifier == nil || identifier.length == 0 || quantity == nil || priceDollars == nil) {
        [RCHLog logError:@"You must provide a valid product identifier, quantity, and price when creating an instance of %@", NSStringFromClass([self class])];
        return nil;
    }

    self = [super init];
    if (self) {
        _identifier = identifier;
        _quantity = quantity;
        _priceDollars = priceDollars;
    }
    return self;
}

@end

@implementation RCHPlacementsBuilder

- (instancetype)initWithAPIPath:(NSString *)APIPath
{
    self = [super initWithAPIPath:APIPath];
    if (self) {
        [self setExcludeHTML:YES];
    }
    return self;
}

- (instancetype)addPlacement:(RCHRequestPlacement *)placement
{
    if (placement != nil) {
        NSString *placementString = [placement stringRepresentation];
        NSArray *array = [[self valueForKey:kRCHAPIRequestParamRecommendationsPlacements] componentsSeparatedByString:@"|"];
        NSString *placementPageType = [[placementString componentsSeparatedByString:@"."] firstObject];
        for (NSString *placementName in array) {
            if ([placementName isEqualToString:placementString]) {
                [RCHLog logError:@"Invalid parameter passed to %@. Placement %@ has already been added. This placement call will be ignored", NSStringFromSelector(_cmd), placementName];
                return self;
            }
            
            NSString *pageType = [[placementName componentsSeparatedByString:@"."] firstObject];
            if (![placementPageType isEqualToString:pageType]) {
                [RCHLog logError:@"Invalid parameter passed to %@. You are passing a placement of type %@ on a %@ request. Placement types must be all of the same type. This placement call will be ignored.", NSStringFromSelector(_cmd), placementPageType, pageType];
                return self;
            }
        }
        
        [self addValue:placementString toArrayForhKey:kRCHAPIRequestParamRecommendationsPlacements];
    }
    else {
        [RCHLog logError:@"Invalid parameter, nil placement passed to %@", NSStringFromSelector(_cmd)];
    }
    
    return self;
}

- (instancetype)setFeaturedPageBrand:(NSString *)featuredPageBrand
{
    return [self setValue:featuredPageBrand forKey:kRCHAPIRequestParamRecommendationsFeaturedPageBrand];
}

- (instancetype)setExcludeHTML:(BOOL)excludeHTML
{
    return [self setValue:@(excludeHTML) forKey:kRCHAPIRequestParamRecommendationsExcludeHtml];
}

- (instancetype)setIncludeCategoryData:(BOOL)includeCategoryData
{
    return [self setValue:@(includeCategoryData) forKey:kRCHAPIRequestParamRecommendationsIncludeCategoryData];
}

- (instancetype)setUserAttributes:(NSDictionary *)userAttributes
{
    return [self setDictionaryValue:userAttributes forKey:kRCHAPIRequestParamRecommendationsUserAttribute flattenKeys:NO];
}

- (instancetype)setShopperReferrer:(NSString *)shopperReferrer
{
    return [self setValue:shopperReferrer forKey:kRCHAPIRequestParamRecommendationsShopperReferrer];
}

- (instancetype)setCategoryHintIDs:(NSArray *)categoryHintIDs
{
    return [self setArrayValue:categoryHintIDs forKey:kRCHAPIRequestParamRecommendationsCategoryHintID];
}

- (instancetype)setUserSegments:(NSDictionary *)userSegments
{
    return [self setDictionaryValue:userSegments forKey:kRCHAPIRequestParamRecommendationsUserSegments flattenKeys:YES];
}

- (instancetype)setRegionID:(NSString *)regionID
{
    return [self setValue:regionID forKey:kRCHAPIRequestParamRecommendationsRegionID];
}

- (instancetype)setViewedProducts:(NSDictionary *)viewdProducts
{
    return [self setDictionaryValue:[self convertDatesToStringTimestampsForDictionary:viewdProducts] forKey:kRCHAPIRequestParamRecommendationsViewedProducts flattenKeys:NO];
}

- (instancetype)setPurchasedProducts:(NSDictionary *)purchasedProducts
{
    return [self setDictionaryValue:[self convertDatesToStringTimestampsForDictionary:purchasedProducts] forKey:kRCHAPIRequestParamRecommendationsPurchasedProducts flattenKeys:NO];
}

#pragma mark - Helper

- (NSDictionary *)convertDatesToStringTimestampsForDictionary:(NSDictionary *)dict
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionary];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDate class]]) {
            newDict[key] = [self millisecondsStringFromDate:obj];
        }
        else if ([obj isKindOfClass:[NSArray class]]) {
            NSMutableArray *newTimestamps = [NSMutableArray array];
            for (id subObj in obj) {
                if ([subObj isKindOfClass:[NSDate class]]) {
                    [newTimestamps addObject:[self millisecondsStringFromDate:subObj]];
                }
                else {
                    [RCHLog logError:@"Encountered bad product timestamp value: %@, only instances of NSDate or NSArray are allowed.", subObj];
                }
            }
            newDict[key] = [newTimestamps copy];
        }
        else {
            [RCHLog logError:@"Encountered bad product teimstamp value: %@, only instances of NSDate or NSArray are allowed.", obj];
        }
    }];

    return [newDict copy];
}

- (NSString *)millisecondsStringFromDate:(NSDate *)date
{
    NSTimeInterval ms = [date timeIntervalSince1970] * 1000.0;
    return [NSString stringWithFormat:@"%0.f", ms];
}

@end
