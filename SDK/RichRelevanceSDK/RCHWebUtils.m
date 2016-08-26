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

#import "RCHWebUtils.h"

static NSString *const kRCHCharactersToBeEscapedInQueryString = @":/?&=;+!@#$()',*";

static NSString *RCHPercentEscapedQueryStringKeyFromStringWithEncoding(NSString *string, NSStringEncoding encoding)
{
    static NSString *const kRCHCharactersToLeaveUnescapedInQueryStringPairKey = @"[].";

    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, (__bridge CFStringRef)kRCHCharactersToLeaveUnescapedInQueryStringPairKey, (__bridge CFStringRef)kRCHCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

static NSString *RCHPercentEscapedQueryStringValueFromStringWithEncoding(NSString *string, NSStringEncoding encoding)
{
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, (__bridge CFStringRef)kRCHCharactersToBeEscapedInQueryString, CFStringConvertNSStringEncodingToEncoding(encoding));
}

#pragma mark -

@implementation RCHQueryStringPair

- (id)initWithField:(id)field value:(id)value
{
    self = [super init];
    if (!self) {
        return nil;
    }

    self.field = field;
    self.value = value;

    return self;
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding
{
    if (!self.value || [self.value isEqual:[NSNull null]]) {
        return RCHPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding);
    }
    else {
        // Ensure that bools are passed as true/false instead of 1/0
        NSString *valueDesc = nil;
        if ([self.value isKindOfClass:[NSNumber class]] && [NSStringFromClass([self.value class]) isEqualToString:@"__NSCFBoolean"]) {
            valueDesc = [self.value boolValue] ? @"true" : @"false";
        }
        else {
            valueDesc = [self.value description];
        }

        return [NSString stringWithFormat:@"%@=%@", RCHPercentEscapedQueryStringKeyFromStringWithEncoding([self.field description], stringEncoding), RCHPercentEscapedQueryStringValueFromStringWithEncoding(valueDesc, stringEncoding)];
    }
}

@end

#pragma mark -

extern NSArray *RCHQueryStringPairsFromDictionary(NSDictionary *dictionary);
extern NSArray *RCHQueryStringPairsFromKeyAndValue(NSString *key, id value);

static NSString *RCHQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding)
{
    NSMutableArray *mutablePairs = [NSMutableArray array];
    for (RCHQueryStringPair *pair in RCHQueryStringPairsFromDictionary(parameters)) {
        [mutablePairs addObject:[pair URLEncodedStringValueWithEncoding:stringEncoding]];
    }

    return [mutablePairs componentsJoinedByString:@"&"];
}

NSArray *RCHQueryStringPairsFromDictionary(NSDictionary *dictionary)
{
    return RCHQueryStringPairsFromKeyAndValue(nil, dictionary);
}

NSArray *RCHQueryStringPairsFromKeyAndValue(NSString *key, id value)
{
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];

    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:YES selector:@selector(compare:)];

    if ([value isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = value;
        // Sort dictionary keys to ensure consistent ordering in query string, which is important when deserializing potentially ambiguous sequences, such as an array of dictionaries
        for (id nestedKey in [dictionary.allKeys sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            id nestedValue = [dictionary objectForKey:nestedKey];
            if (nestedValue) {
                [mutableQueryStringComponents addObjectsFromArray:RCHQueryStringPairsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
            }
        }
    }
    else if ([value isKindOfClass:[NSArray class]]) {
        NSArray *array = value;
        for (id nestedValue in array) {
            [mutableQueryStringComponents addObjectsFromArray:RCHQueryStringPairsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
        }
    }
    else if ([value isKindOfClass:[NSSet class]]) {
        NSSet *set = value;
        for (id obj in [set sortedArrayUsingDescriptors:@[ sortDescriptor ]]) {
            [mutableQueryStringComponents addObjectsFromArray:RCHQueryStringPairsFromKeyAndValue(key, obj)];
        }
    }
    else {
        [mutableQueryStringComponents addObject:[[RCHQueryStringPair alloc] initWithField:key value:value]];
    }

    return mutableQueryStringComponents;
}

@implementation RCHWebUtils

+ (NSString *)queryStringFromParameters:(NSDictionary *)parameters withEncoding:(NSStringEncoding)encoding
{
    return RCHQueryStringFromParametersWithEncoding(parameters, encoding);
}

@end
