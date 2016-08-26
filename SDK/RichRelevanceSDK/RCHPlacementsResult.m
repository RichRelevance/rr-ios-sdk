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

#import "RCHPlacementsResult.h"
#import "NSObject+RCHImport.h"
#import "RCHPlacement.h"
#import "RCHRecommendedPlacement.h"

@implementation RCHPlacementsResult

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(placements))] && [value isKindOfClass:[NSArray class]]) {
        self.placements = [RCHRecommendedPlacement rch_objectsFromArray:value];
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end
