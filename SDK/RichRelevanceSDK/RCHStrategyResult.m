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

#import "RCHStrategyResult.h"
#import "RCHRecommendedProduct.h"
#import "NSObject+RCHImport.h"

@implementation RCHStrategyResult

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(recommendedProducts))] && [value isKindOfClass:[NSArray class]]) {
        self.recommendedProducts = [RCHRecommendedProduct rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(strategyName))] && [value isKindOfClass:[NSString class]]) {
        self.strategyName = [RCHEnumMappings strategyFromString:value];
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end
