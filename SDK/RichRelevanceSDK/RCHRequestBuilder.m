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

#import "RCHRequestBuilder.h"
#import "RCHAPIConstants.h"
#import "RCHLog.h"

NSString *const kRCHRequestBuilderPipeListDelimiter = @"|";
NSString *const kRCHRequestBuilderCommaListDelimiter = @",";
NSString *const kRCHRequestBuilderDefaultDictListDelimiter = @";";
NSString *const kRCHRequestBuilderDefaultDictKeyValueDelimiter = @":";

@interface RCHRequestBuilder ()

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@property (copy, nonatomic) NSString *arrayDelimiter;

@end

@implementation RCHRequestBuilder

- (instancetype)initWithAPIPath:(NSString *)APIPath
{
    if (APIPath == nil || APIPath.length == 0) {
        [RCHLog logError:@"Request builder cannot be initialized with a nil or empty APIPath"];
        return nil;
    }

    self = [super init];
    if (self) {
        _requestParams = [NSMutableDictionary dictionary];
        _requestInfo = [NSMutableDictionary dictionary];
        _requestInfo[kRCHAPIBuilderParamRequestInfoPath] = APIPath;
        _requestInfo[kRCHAPIBuilderParamRequestInfoUserAndSessionStyle] = @(RCHAPIClientUserAndSessionParamStyleLong);

        _arrayDelimiter = kRCHRequestBuilderPipeListDelimiter;
    }
    return self;
}

#pragma mark - Default Setters

- (id)valueForKey:(NSString *)key;
{
    return key != nil ? self.requestParams[key] : nil;
}

- (instancetype)setValue:(id)value forKey:(NSString *)key inDict:(NSMutableDictionary *)dict
{
    if (key != nil && value != nil) {
        [RCHLog logDebug:@"%s: setValue:%@ forKey:%@", __PRETTY_FUNCTION__, value, key];

        dict[key] = value;
    }

    return self;
}

- (instancetype)setValue:(id)value forKey:(NSString *)key
{
    return [self setValue:value forKey:key inDict:self.requestParams];
}

- (void)setArrayDelimiter:(NSString *)arrayDelimiter
{
    _arrayDelimiter = arrayDelimiter;
}

- (instancetype)setArrayValue:(NSArray *)array forKey:(NSString *)key
{
    if (array != nil && array.count > 0) {
        NSString *valueString = [array componentsJoinedByString:self.arrayDelimiter];
        [self setValue:valueString forKey:key];
    }

    return self;
}

- (NSArray *)arrayRepresentationOfArrayValueForKey:(NSString *)key
{
    NSArray *array = nil;
    NSString *arrayString = self.requestParams[key];
    if (arrayString != nil && [arrayString isKindOfClass:[NSString class]] && arrayString.length > 0) {
        array = [arrayString componentsSeparatedByString:self.arrayDelimiter];
    }

    return array;
}

- (instancetype)addValue:(id)value toArrayForKey:(NSString *)key
{
    if (value != nil) {
        NSArray *existing = [self arrayRepresentationOfArrayValueForKey:key];
        NSMutableArray *array = existing != nil ? [existing mutableCopy] : [NSMutableArray array];
        [array addObject:value];
        [self setArrayValue:array forKey:key];
    }

    return self;
}

- (instancetype)addValue:(id)value toMultipleArgumentArrayForKey:(NSString *)key
{
    if (value != nil) {
        NSArray *value = [self valueForKey:key] ?: [NSArray array];
        return [self setValue:[value arrayByAddingObject:key] forKey:key];
    }

    return self;
}

- (instancetype)setDictionaryValue:(NSDictionary *)dict forKey:(NSString *)key flattenKeys:(BOOL)flattenKeys
{
    if (dict != nil && dict.count > 0) {
        NSArray *sortedKeys = [dict.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        NSMutableArray *listValues = [NSMutableArray array];
        for (NSString *key in sortedKeys) {
            id obj = dict[key];

            if ([obj isKindOfClass:[NSArray class]]) {
                if (flattenKeys) {
                    for (id subObj in obj) {
                        NSString *valueString = [NSString stringWithFormat:@"%@%@%@", key, kRCHRequestBuilderDefaultDictKeyValueDelimiter, subObj];
                        [listValues addObject:valueString];
                    }
                }
                else {
                    NSString *arrayValues = [(NSArray *)obj componentsJoinedByString:kRCHRequestBuilderDefaultDictListDelimiter];
                    NSString *valueString = [NSString stringWithFormat:@"%@%@%@", key, kRCHRequestBuilderDefaultDictKeyValueDelimiter, arrayValues];
                    [listValues addObject:valueString];
                }
            }
            else if ([obj isKindOfClass:[NSString class]] || [obj isKindOfClass:[NSNumber class]]) {
                NSString *valueString = [NSString stringWithFormat:@"%@%@%@", key, kRCHRequestBuilderDefaultDictKeyValueDelimiter, dict[key]];
                [listValues addObject:valueString];
            }
            else {
                continue;
            }
        }

        [self setValue:[listValues componentsJoinedByString:self.arrayDelimiter] forKey:key];
    }

    return self;
}

#pragma mark - Request Info

- (instancetype)setAPIPath:(NSString *)APIPath;
{
    return [self setValue:APIPath forKey:kRCHAPIBuilderParamRequestInfoPath inDict:self.requestInfo];
}

- (instancetype)setResponseParserClass:(Class<RCHAPIResponseParser>)cls
{
    return [self setValue:cls forKey:kRCHAPIBuilderParamRequestInfoParserClass inDict:self.requestInfo];
}

- (instancetype)setRequiresOAuth:(BOOL)requiresOAuth
{
    self.requestInfo[kRCHAPIBuilderParamRequestInfoRequiresOAuth] = [NSNumber numberWithBool:requiresOAuth];
    return self;
}

- (instancetype)setIncludesEncryptedCook:(BOOL)requiresOAuth
{
    self.requestInfo[kRCHAPIBuilderParamRequestInfoRequiresOAuth] = [NSNumber numberWithBool:requiresOAuth];
    return self;
}

- (instancetype)setUserAndSessionParamStyle:(RCHAPIClientUserAndSessionParamStyle)style
{
    self.requestInfo[kRCHAPIBuilderParamRequestInfoUserAndSessionStyle] = @(style);
    return self;
}

- (instancetype)setEmbedRCSToken:(BOOL)embed
{
    self.requestInfo[kRCHAPIBuilderParamRequestInfoEmbedRCS] = @(embed);
    return self;
}

#pragma mark - Build

- (NSDictionary *)build
{
    return @{
        kRCHAPIBuilderParamRequestInfo : [self.requestInfo copy],
        kRCHAPIBuilderParamRequestParameters : [self.requestParams copy],
    };
}

@end
