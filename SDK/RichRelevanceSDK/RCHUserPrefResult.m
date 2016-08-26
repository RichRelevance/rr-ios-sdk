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

#import "RCHUserPrefResult.h"

@implementation RCHUserPrefResult

+ (NSArray *)rch_nestedObjectKeys
{
    NSArray *keys = @[
        NSStringFromSelector(@selector(brand)),
        NSStringFromSelector(@selector(category)),
        NSStringFromSelector(@selector(product)),
        NSStringFromSelector(@selector(store)),
        NSStringFromSelector(@selector(skuSize)),
    ];

    return keys;
}

+ (NSString *)prefStringFromSelector:(SEL)sel
{
    NSString *key = [NSString stringWithFormat:@"pref_%@", NSStringFromSelector(sel)];
    return key;
}

+ (NSDictionary *)rch_customMappings
{
    return @{
        [[self class] prefStringFromSelector:@selector(brand)] : NSStringFromSelector(@selector(brand)),
        [[self class] prefStringFromSelector:@selector(category)] : NSStringFromSelector(@selector(category)),
        [[self class] prefStringFromSelector:@selector(product)] : NSStringFromSelector(@selector(product)),
        [[self class] prefStringFromSelector:@selector(store)] : NSStringFromSelector(@selector(store)),
        [[self class] prefStringFromSelector:@selector(skuSize)] : NSStringFromSelector(@selector(skuSize)),
    };
}

@end
