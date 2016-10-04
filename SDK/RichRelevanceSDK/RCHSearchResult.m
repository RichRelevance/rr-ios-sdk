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

#import "RCHSearchResult.h"
#import "RCHSearchProduct.h"
#import "RCHSearchLink.h"
#import "RCHSearchFacet.h"
#import "NSObject+RCHImport.h"

@implementation RCHSearchResult

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:kRCHAPIResponseKeySearchPlacements] && [value isKindOfClass:[NSArray class]]) {
        NSArray<NSDictionary *> *placements = value;
        if (placements.count > 0 && [placements[0] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *placement = placements[0];
            self.searchTrackingURL = placement[kRCHAPIResponseKeySearchTrackingURL];
            self.count = [placement[kRCHAPIResponseKeySearchNumFound] unsignedIntegerValue];
            self.spellCheckedQuery = placement[kRCHAPIResponseKeySearchSpellChecked];
            self.opaqueRCSToken = placement[kRCHAPICommonParamRCS];
            NSArray<NSDictionary *> *products = placement[kRCHAPIResponseKeySearchProducts];
            if ([products isKindOfClass:[NSArray class]]) {
                self.products = [RCHSearchProduct rch_objectsFromArray:products];
            }

            NSDictionary<NSString *, NSArray *> *links = placement[kRCHAPIResponseKeySearchLinks];
            NSMutableDictionary<NSString *, NSArray<RCHSearchLink *> *> *resultLinks = [NSMutableDictionary dictionary];
            if ([links isKindOfClass:[NSDictionary class]]) {
                [links enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray * _Nonnull obj, BOOL * _Nonnull stop) {
                    resultLinks[key] = [RCHSearchLink rch_objectsFromArray:obj];
                }];
            }
            self.links = resultLinks;

            NSArray<NSDictionary *> *facets = placement[kRCHAPIResponseKeySearchFacets];
            NSMutableDictionary<NSString *, NSArray<RCHSearchFacet *> *> *resultFacets = [NSMutableDictionary dictionary];
            if ([facets isKindOfClass:[NSArray class]]) {
                for (NSDictionary *facet in facets) {
                    NSString *key = facet[kRCHAPIResponseKeySearchFacet];
                    NSArray *values = facet[kRCHAPIResponseKeySearchValues];
                    resultFacets[key] = [RCHSearchFacet rch_objectsFromArray:values];
                }
            }
            self.facets = resultFacets;
        }
        return NO;
    }
    else if ([key isEqualToString:kRCHAPIResponseKeySearchMessage] && [value isKindOfClass:[NSString class]]) {
        self.errormessage = value;
    }

    return YES;
}

@end
