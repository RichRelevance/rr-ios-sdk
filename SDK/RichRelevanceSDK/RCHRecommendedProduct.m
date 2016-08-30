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

#import "RCHRecommendedProduct.h"
#import "NSObject+RCHImport.h"
#import "RCHRange.h"
#import "RCHCategory.h"
#import "RCHAPIConstants.h"
#import "RCHSDK.h"
#import "RCHAPIClient.h"

@implementation RCHRecommendedProduct

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    key = [[self class] rch_propertyNameForExternalKey:key];

    if ([key isEqualToString:NSStringFromSelector(@selector(priceRangeCents))] && [value isKindOfClass:[NSArray class]]) {
        RCHRange *range = [[RCHRange alloc] initWithMin:0 max:0];
        NSArray *rangeArray = (NSArray *)value;
        if (rangeArray.count > 1) {
            range.min = rangeArray[0];
            range.max = rangeArray[1];
        }
        else if (rangeArray.count > 0) {
            range.min = rangeArray[0];
        }

        self.priceRangeCents = range;

        return NO;
    }
    if ([key isEqualToString:NSStringFromSelector(@selector(salePriceRangeCents))] && [value isKindOfClass:[NSArray class]]) {
        RCHRange *range = [[RCHRange alloc] initWithMin:0 max:0];
        NSArray *rangeArray = (NSArray *)value;
        if (rangeArray.count > 1) {
            range.min = rangeArray[0];
            range.max = rangeArray[1];
        }
        else if (rangeArray.count > 0) {
            range.min = rangeArray[0];
        }

        self.salePriceRangeCents = range;

        return NO;
    }

    else if ([key isEqualToString:NSStringFromSelector(@selector(categories))] && [value isKindOfClass:[NSArray class]]) {
        self.categories = [RCHCategory rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(categoryIDs))] && [value isKindOfClass:[NSArray class]]) {
        self.categoryIDs = value;
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(attributes))] && [value isKindOfClass:[NSDictionary class]]) {
        self.attributes = value;
        return NO;
    }

    return YES;
}

+ (NSDictionary *)rch_customMappings
{
    return @{
        kRCHAPIResponseKeyID : NSStringFromSelector(@selector(productID))
    };
}

#pragma mark - Product Tracking

- (void)trackProductView
{
    [[RCHSDK defaultClient] trackProductViewWithURL:self.clickURL];
}

@end
