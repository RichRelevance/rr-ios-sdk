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

/*!
 A builder for creating a getProducts request.
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHGetProductsBuilder : RCHRequestBuilder

/*!
 *  A single, or list of, product IDs. Part of an order definition on the purchase complete page.
 *
 *  @param productIDs An NSArray of NSString instances representing product IDs.
 */
- (instancetype)setProductIDs:(NSArray<NSString *> *)productIDs;

/*!
 *  Retrieves custom attributes provided in the catalog feed.
 *
 *  @param attributes A list of NSString instances, pass a list containing a single value of * to retrieve all attributes.
 */
- (instancetype)setCatalogFeedCustomAttributes:(NSArray<NSString *> *)attributes;

@end
NS_ASSUME_NONNULL_END
