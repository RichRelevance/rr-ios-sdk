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

NS_ASSUME_NONNULL_BEGIN

@class RCHAPIClientConfig;

typedef void (^RCHAPIClientSuccess)(id _Nullable responseObject);
typedef void (^RCHAPIClientFailure)(id _Nullable responseObject, NSError  * _Nullable error);

/*!
 *  The API client is the central location for all Rich Relevance API interactions. This class includes
 *  several methods for specifying configuration, sending requests, and view tracking.
 */
@interface RCHAPIClient : NSObject

///-------------------------------
/// @name Configuration
///-------------------------------

/*!
 *  The current client configuration.
 */
@property (strong, readonly, nonatomic) RCHAPIClientConfig *clientConfig;

/*!
 *  Set a configuration for this API client.
 *
 *  @param config The API client configuration, an instance of RCHAPIClientConfig
 */
- (void)configure:(RCHAPIClientConfig *)config;

///-------------------------------
/// @name Sending Requests
///-------------------------------

/*!
 *  Sends an API request, returning no response. This method is intended for write-only style requests (i.e. any 
 *  tracking requests where you don't care about receiving a response).
 *
 *  @param requestDict An NSDictionary containing request information and parameters. You should only pass instances created by invoking
 *  the build method of an RCHRequestBuilder subclass.
 */
- (void)sendRequest:(NSDictionary *)requestDict;

/*!
 *  Sends an API request, returning a parsed response. This method dis intended for API requests that return data.
 *
 *  @param requestDict An NSDictionary containing request information and parameters. You should only pass instances created by invoking
 *                     the build method of an RCHRequestBuilder subclass.
 *  @param success     A block that is invoked upon successful request completion. If the response can be parsed into model objects, the result parameter of
 *                     the block will be a subclass of RCHAPIResult, otherwise it will be a raw Foundation value such as NSDictionary or NSArray.
 *  @param failure     A block that is invoked upon failure. See RCHErrors.h for possible error codes.
 */
- (void)sendRequest:(NSDictionary *)requestDict
            success:(RCHAPIClientSuccess)success
            failure:(RCHAPIClientFailure)failure;

///-------------------------------
/// @name View Tracking
///-------------------------------

/*!
 *  Track a product view. Requests produced by this method will be cached in memory in the event of network failure and retried upon 
 *  connectivity restoration.
 *
 *  @param productClickURL A product click URL, found on RCHRecommendedProduct
 */
- (void)trackProductViewWithURL:(NSString *)productClickURL;

@end

NS_ASSUME_NONNULL_END
