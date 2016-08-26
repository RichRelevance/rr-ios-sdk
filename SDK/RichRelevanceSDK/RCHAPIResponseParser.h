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
 *  Objects conforming to this protocol can participate in API response parsing.
 */
@protocol RCHAPIResponseParser <NSObject>

/*!
 *  Parse an API request and return model objects.
 *
 *  @param responseObject A JSON object (NSDictionary or NSArray)
 *  @param error          An error that will be populated if the parsing fails.
 *
 *  @return A populated model object representing an API result
 */
- (id)parseResponse:(id)responseObject error:(NSError *__autoreleasing *)error;

@end
