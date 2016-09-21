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

@import Foundation;

/*!
 *  A range representation.
 */
NS_ASSUME_NONNULL_BEGIN
@interface RCHRange : NSObject

/*!
 *  Min value, or nil for no min.
 */
@property (strong, nonatomic, nullable) NSNumber *min;

/*!
 *  Max value, or nil for no max.
 */
@property (strong, nonatomic, nullable) NSNumber *max;

/*!
 *  Create a new range instance.
 *
 *  @param min The min value, or nil for no min
 *  @param max The max value or nil for no max
 *
 *  @return A new range instance
 */

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMin:(nullable NSNumber *)min max:(nullable NSNumber *)max NS_DESIGNATED_INITIALIZER;

/*!
 *  A delimited range string value: ```min:max```
 *
 *  @return Delimited string value for this range
 */
- (NSString *)delimitedStringValue;

@end
NS_ASSUME_NONNULL_END
