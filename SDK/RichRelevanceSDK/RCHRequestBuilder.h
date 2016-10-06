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
#import "RCHCommonIncludes.h"
#import "RCHRange.h"
#import "RCHAPIConstants.h"

NS_ASSUME_NONNULL_BEGIN
OBJC_EXTERN NSString *const kRCHRequestBuilderPipeListDelimiter;
OBJC_EXTERN NSString *const kRCHRequestBuilderCommaListDelimiter;
OBJC_EXTERN NSString *const kRCHRequestBuilderDefaultDictListDelimiter;
OBJC_EXTERN NSString *const kRCHRequestBuilderDefaultDictKeyValueDelimiter;

@protocol RCHAPIResponseParser;

/*!
 *  The base request builder. This class includes various methods for mutating the 
 *  request by setting values of various types. It also includes setters for request info such as
 *  path and response parser that do not get passed as HTTP parameters.
 */
@interface RCHRequestBuilder : NSObject

///-------------------------------
/// @name Initialization
///-------------------------------

/*!
 *  Creates a new instance with the provided API path.
 *
 *  @param APIPath The path against which this request will be executed.
 *
 *  @return A new RCHRequestBuilder instance
 */
- (instancetype)initWithAPIPath:(NSString *)APIPath;

///-------------------------------
/// @name Value Setters
///-------------------------------

/*!
 *  Set a raw value for key.
 *
 *  @param value The value to set, must be a Foundation value
 *  @param key   The key under which to set the value, must not be nil
 */
- (instancetype)setValue:(nullable id)value forKey:(NSString *)key;

/*!
 *  Get a value for the specified key.
 *
 *  @param key The key for the value to look up
 *
 *  @return The value or nil if the value is not containd within this builder
 */
- (id)valueForKey:(NSString *)key;

/*!
 *  Set the delimiter used for array parameters. Default value is pipe ```|```
 *
 *  @param arrayDelimiter The delimiter to be used for array parameters
 */
- (void)setArrayDelimiter:(NSString *)arrayDelimiter;

/*!
 *  Set an array as value. This will result in the values of the array being passed as a single
 *  delimited list parameters, e.g. ```key=a|b|c```
 *
 *  @param array The array value, must be a list of NSString or NSNumber values.
 *  @param key   The key under which to set the value
 */
- (instancetype)setArrayValue:(NSArray *)array forKey:(NSString *)key;

/*!
 *  Add a new value to an existing delimited array value.
 *
 *  @param value The new value to add, an instance of either NSString or NSNumber
 *  @param key   The key under which to add the value
 */
- (instancetype)addValue:(id)value toArrayForKey:(NSString *)key;

/*!
 *  Add a new value to an array that is represented as multiple arguments, not a string delimited array, e.g. ```key=a&key=b&key=c```
 *  @param value The new value to add, an instance of either NSString or NSNumber
 *  @param key   The key under which to add the value
 */
- (instancetype)addValue:(id)value toMultipleArgumentArrayForKey:(NSString *)key;


/*!
 *  Set a dicionary as value. This will result in the key/value pairs of
 *  the dictionary being passed in one of several delimited formats.
 *
 *  @param dict        The dictionary to set as value, must contain instances of NSString or NSNumber
 *  @param key         The key under which to store the value
 *  @param flattenKeys If YES, values that are lists are represented as duplicate key/value pairs.
 */
- (instancetype)setDictionaryValue:(NSDictionary *)dict forKey:(NSString *)key flattenKeys:(BOOL)flattenKeys;

///-------------------------------
/// @name Request Info
///-------------------------------

/*!
 *  Set the API path for this request.
 *
 *  @param APIPath The API path
 */
- (instancetype)setAPIPath:(NSString *)APIPath;

/*!
 *  Set a response parser for this request. If not set, a raw Foundation data structure will be
 *  returned containing the processed JSON.
 *
 *  @param cls A parser class that conforms to RCHAPIResponseParser
 */
- (instancetype)setResponseParserClass:(Class<RCHAPIResponseParser>)cls;

/*!
 *  Set whether or not this request requires OAuth 1.0. Default value is NO.
 *
 *  @param requiresOAuth YES if OAuth 1.0 is required
 */
- (instancetype)setRequiresOAuth:(BOOL)requiresOAuth;

/*!
 *  Set the format of the user and session ID params for this request.
 *
 *  @param style The param style, @see RCHAPIClientUserAndSessionParamStyle for possible values
 */
- (instancetype)setUserAndSessionParamStyle:(RCHAPIClientUserAndSessionParamStyle)style;

/*!
 *  Embed the RCS Token in the request. This is an opaque encrypted token used by the endpoint
 */
- (instancetype)setEmbedRCSToken:(BOOL)embed;

///-------------------------------
/// @name Build
///-------------------------------

/*!
 *  Produces an NSDictionary that can be fed directly to RCHAPIClient in order to execute an API request. The resulting
 *  dictionary has two top-level values: ```kRCHAPIBuilderParamRequestParameters``` contains the parameters to be passed
 *  as HTTP query params while ```kRCHAPIBuilderParamRequestInfo``` contains request information such as path and response parser
 *
 *  @return A request dictionary to be passed to RCHAPIClient sendRequest:
 */
- (NSDictionary *)build;

@end
NS_ASSUME_NONNULL_END
