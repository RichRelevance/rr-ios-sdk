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
 *  A request builder for the user/preference API endpoint.
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHUserPrefBuilder : RCHRequestBuilder

///-------------------------------
/// @name Initialization
///-------------------------------

/*!
 *  Create an instance configured with the appropriate path
 *
 *  @return A newly created instance
 */
- (instancetype)init NS_DESIGNATED_INITIALIZER;

///-------------------------------
/// @name Updates
///-------------------------------

/*!
 *  View GUID. Unique string to identify a set of recommendations. Returned as part of the RichRelevance response.
 *
 *  @param viewGUID A view GUID
 */
- (instancetype)setViewGUID:(NSString *)viewGUID;

/*!
 *  Preference. A list of brand IDs, category IDs, product IDs, or store IDs (depending on the value of targetType).
 *
 *  @param prefs An NSArray of NSString instances representing preferences
 */
- (instancetype)setPreferences:(NSArray<NSString *> *)prefs;

/*!
 *  The type of value being passed as a preference.
 *
 *  @param targetType A preference target type, one of the values in RCHUserPrefFieldType
 */
- (instancetype)setTargetType:(RCHUserPrefFieldType)targetType;

/*!
 *  What has the shopper indicated about the brands/categories/products/stores set as preferences?
 *
 *  @param actionType An action type, one of the values in RCHUserPrefActionType
 */
- (instancetype)setActionType:(RCHUserPrefActionType)actionType;

///-------------------------------
/// @name Fetching
///-------------------------------

/*!
 *  Add a preference value to the list of preferences to be returned by this fetch.
 *
 *  @param preference A preference value type, one of the values in RCHUserPrefFieldType
 */
- (instancetype)addFetchPreference:(RCHUserPrefFieldType)preference;

@end
NS_ASSUME_NONNULL_END
