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

#import "RCHSearchBuilder.h"
#import "RCHSearchResponseParser.h"
#import "RCHPlacementsBuilder.h"

@implementation RCHSearchBuilder

- (instancetype)init
{
    self = [super initWithAPIPath:kRCHAPIRequestFindSearchPath];
    if (self) {
        [self setUserAndSessionParamStyle:RCHAPIClientUserAndSessionParamStyleLongWithAPIKeyInPath];
        [self setResponseParserClass:[RCHSearchResponseParser class]];
        [self setEmbedRCSToken:YES];
        [self setValue:@YES forKey:kRCHAPIRequestParamSearchSSL];
        [self setLocale:[NSLocale currentLocale]];
        [self setPageStart:0];
        [self setPageCount:20];
    }
    return self;
}

- (instancetype)setQuery:(NSString *)text
{
    return [self setValue:text forKey:kRCHAPIRequestParamFindQuery];
}

- (instancetype)setPageCount:(NSInteger)pageCount
{
    return [self setValue:@(pageCount) forKey:kRCHAPIRequestParamFindCount];
}

- (instancetype)setPageStart:(NSInteger)pageStart
{
    return [self setValue:@(pageStart) forKey:kRCHAPIRequestParamFindStart];
}

- (instancetype)setPlacement:(RCHRequestPlacement *)placement
{
    return [self setValue:placement.stringRepresentation forKey:kRCHAPIRequestParamSearchPlacement];
}

- (instancetype)addSortOrder:(NSString *)field ascending:(BOOL)ascending
{
    NSString *sortValue = [NSString stringWithFormat:@"%@ %@", field, ascending ? kRCHAPIRequestParamSearchAscending :kRCHAPIRequestParamSearchDescending];
    return [self addValue:sortValue toMultipleArgumentArrayForKey:kRCHAPIRequestParamSearchSort];
}

- (instancetype)addFilter:(NSString *)field value:(NSString *)value
{
    NSString *filterValue = [NSString stringWithFormat:@"%@:\"%@\"", field, value];
    return [self addValue:filterValue toArrayForKey:kRCHAPIRequestParamSearchFilter];
}

- (instancetype)addFilterFromFacet:(RCHSearchFacet *)facet
{
    return [self addValue:facet.filter toArrayForKey:kRCHAPIRequestParamSearchFilter];
}

- (instancetype)setFacetFields:(NSArray<NSString *> *)fields
{
    return [self setValue:fields forKey:kRCHAPIRequestParamSearchFacet];
}

- (instancetype)setLocale:(NSLocale *)locale
{
    return [self setValue:[locale objectForKey:NSLocaleLanguageCode] forKey:kRCHAPIRequestParamFindLanguage];
}

- (instancetype)setSortOrder:(NSString *)field ascending:(BOOL)ascending
{
    return [self setValue:field forKey:kRCHAPIRequestParamSearchSort];
}

- (instancetype)setChannel:(NSString *)channel;
{
    return [self setValue:channel forKey:kRCHAPIRequestParamSearchChannel];
}

- (instancetype)setLogRequest:(BOOL)logRequest
{
    return [self setValue:@(logRequest) forKey:kRCHAPIRequestParamSearchLog];
}

- (instancetype)setRegionID:(NSString *)regionID
{
    return [self setValue:regionID forKey:kRCHAPIRequestParamSearchRegion];
}

- (instancetype)setShopperReferrer:(NSString *)shopperReferrer
{
    return [self setValue:shopperReferrer forKey:kRCHAPIRequestParamSearchReference];
}

@end
