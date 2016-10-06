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

NS_ASSUME_NONNULL_BEGIN
@interface RCHAutocompleteBuilder : RCHRequestBuilder

/*!
 *  Create an instance configured with the appropriate path
 *
 *  @return A newly created instance
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/*!
 *  The text to obtain autocomplete suggestions for.
 *
 *  @param text The string to obtain autocomplete suggestions for.
 */
- (instancetype)setQuery:(NSString *)text;

/*!
 *  The Language the query is performed in. 
 *
 *  @param text The string to obtain autocomplete suggestions for.
 */
- (instancetype)setLocale:(NSLocale *)locale;

/*!
 *  The total number of suggestions to return in the response. 
 *
 *  @param pageCount The total number of suggestions to return in the response.
 */
- (instancetype)setPageCount:(NSInteger)pageCount;

/*!
 *  The starting number for the suggestion that you want to return. (For example, if you want to return suggestions 30-60, this value would be 30.)
 *
 *  @param pageStart The starting number for returned suggestions.
 */
- (instancetype)setPageStart:(NSInteger)pageStart;

@end
NS_ASSUME_NONNULL_END
