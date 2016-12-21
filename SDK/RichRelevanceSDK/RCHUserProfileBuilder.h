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
 *  Builder for User Profile requests. Note that this builder produces requests that only
 *  work with OAuth configuration present in the API Client and HTTPS (i.e. useHTTPS set to YES (the default)
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHUserProfileBuilder : RCHRequestBuilder

///-------------------------------
/// @name Initialization
///-------------------------------

/*!
 *  Create an instance configured with the appropriate path
 *
 *  @return A newly created instance
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/*!
 *  Add a profile field to this request. Not adding any field types will result in a default request that includes item views and purchases.
 *
 *  @param fieldType A value from RCHUserProfileFieldType.
 */
- (instancetype)addFieldType:(RCHUserProfileFieldType)fieldType;

@end
NS_ASSUME_NONNULL_END
