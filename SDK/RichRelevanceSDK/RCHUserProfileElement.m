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

#import "RCHUserProfileElement.h"
#import "NSObject+RCHImport.h"

@implementation RCHUserProfileElement

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(timestamp))] && [value isKindOfClass:[NSNumber class]]) {
        self.timestamp = [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000.0];
        return NO;
    }

    return YES;
}

@end

@implementation RCHUserProfileElementItem

@end

#pragma mark - Orders

@implementation RCHUserProfileOrder

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(items))] && [value isKindOfClass:[NSArray class]]) {
        self.items = [RCHUserProfileElementItem rch_objectsFromArray:value];
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end

#pragma mark - Viewed Categories

@implementation RCHUserProfileViewedCategory
@end

#pragma mark - Viewed Brands

@implementation RCHUserProfileViewedBrand : RCHUserProfileElement
@end

#pragma mark - Added to Cart Items

@implementation RCHUserProfileAddedToCartItem

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(items))] && [value isKindOfClass:[NSArray class]]) {
        self.items = [RCHUserProfileElementItem rch_objectsFromArray:value];
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end

#pragma mark - Search Terms

@implementation RCHUserProfileSearchTerm
@end

#pragma mark - User Attributes

@implementation RCHUserProfileUserAttributes : RCHUserProfileElement

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(values))] && [value isKindOfClass:[NSDictionary class]]) {
        self.values = value;
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end

#pragma mark - Referrer

@implementation RCHUserProfileReferrer
@end

#pragma mark - User Segments

@implementation RCHUserProfileUserSegments : RCHUserProfileElement

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(segments))] && [value isKindOfClass:[NSArray class]]) {
        self.segments = value;
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end

#pragma mark - Verb Nounts

@implementation RCHUserProfileVerbNoun
@end

#pragma mark - Counted Events

@implementation RCHUserProfileCountedEvent

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:NSStringFromSelector(@selector(mostRecentTime))] && [value isKindOfClass:[NSNumber class]]) {
        self.mostRecentTime = [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000.0];
        return NO;
    }

    return YES;
}

@end
