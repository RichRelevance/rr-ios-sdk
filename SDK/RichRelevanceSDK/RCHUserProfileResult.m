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

#import "RCHUserProfileResult.h"
#import "NSObject+RCHImport.h"
#import "RCHUserProfileElement.h"

@implementation RCHUserProfileResult

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    key = [[self class] rch_propertyNameForExternalKey:key];

    if ([key isEqualToString:NSStringFromSelector(@selector(timeOfFirstEvent))] && [value isKindOfClass:[NSNumber class]]) {
        self.timeOfFirstEvent = [NSDate dateWithTimeIntervalSince1970:[value doubleValue] / 1000.0];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(viewedItems))] && [value isKindOfClass:[NSArray class]]) {
        self.viewedItems = [RCHUserProfileElementItem rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(clickedItems))] && [value isKindOfClass:[NSArray class]]) {
        self.clickedItems = [RCHUserProfileElementItem rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(orders))] && [value isKindOfClass:[NSArray class]]) {
        self.orders = [RCHUserProfileOrder rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(viewedCategories))] && [value isKindOfClass:[NSArray class]]) {
        self.viewedCategories = [RCHUserProfileViewedCategory rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(viewedBrands))] && [value isKindOfClass:[NSArray class]]) {
        self.viewedBrands = [RCHUserProfileViewedBrand rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(addedToCartItems))] && [value isKindOfClass:[NSArray class]]) {
        self.addedToCartItems = [RCHUserProfileAddedToCartItem rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(searchedTerms))] && [value isKindOfClass:[NSArray class]]) {
        self.searchedTerms = [RCHUserProfileSearchTerm rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(userAttributes))] && [value isKindOfClass:[NSArray class]]) {
        self.userAttributes = [RCHUserProfileUserAttributes rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(batchAttributes))] && [value isKindOfClass:[NSDictionary class]]) {
        self.batchAttributes = value;
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(referrerURLs))] && [value isKindOfClass:[NSArray class]]) {
        self.referrerURLs = [RCHUserProfileReferrer rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(verbNouns))] && [value isKindOfClass:[NSArray class]]) {
        self.verbNouns = [RCHUserProfileVerbNoun rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(countedEvents))] && [value isKindOfClass:[NSArray class]]) {
        self.countedEvents = [RCHUserProfileCountedEvent rch_objectsFromArray:value];
        return NO;
    }
    else if ([key isEqualToString:NSStringFromSelector(@selector(userSegments))] && [value isKindOfClass:[NSArray class]]) {
        self.userSegments = [RCHUserProfileUserSegments rch_objectsFromArray:value];
        return NO;
    }

    return [super rch_shouldImportValue:value forKey:key];
}

@end
