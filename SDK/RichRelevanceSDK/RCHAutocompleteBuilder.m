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

#import "RCHAutocompleteBuilder.h"
#import "RCHAutocompleteResponseParser.h"

@implementation RCHAutocompleteBuilder

- (instancetype)init
{
    self = [super initWithAPIPath:kRCHAPIRequestFindAutocompletePath];
    if (self) {
        [self setUserAndSessionParamStyle:RCHAPIClientUserAndSessionParamStyleAPIKeyInPath];
        [self setResponseParserClass:[RCHAutocompleteResponseParser class]];
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

- (instancetype)setLocale:(NSLocale *)locale
{
    return [self setValue:[locale objectForKey:NSLocaleLanguageCode] forKey:kRCHAPIRequestParamFindLanguage];
}

- (instancetype)setPageCount:(NSInteger)pageCount
{
    return [self setValue:@(pageCount) forKey:kRCHAPIRequestParamFindCount];
}

- (instancetype)setPageStart:(NSInteger)pageStart
{
    return [self setValue:@(pageStart) forKey:kRCHAPIRequestParamFindStart];
}

@end
