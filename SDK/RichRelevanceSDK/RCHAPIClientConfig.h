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
/*!
 *  The default Rich Relevance production endpoint.
 */
OBJC_EXTERN NSString *const RCHEndpointProduction;

/*!
 *  The Rich Relevance integration environment.
 */
OBJC_EXTERN NSString *const RCHEndpointIntegration;

/*!
 *  Represents configuration for an RCHAPIClient. 
 */
@interface RCHAPIClientConfig : NSObject

///-------------------------------
/// @name Configuration
///-------------------------------

/*!
 *  A valid API Key.
 */
@property (copy, readonly, nonatomic) NSString *APIKey;

/*!
 *  A valid API client key.
 */
@property (copy, readonly, nonatomic) NSString *APIClientKey;

/*!
 *  A valid API client secret. Required for any requests that use OAuth.
 */
@property (copy, nonatomic) NSString *APIClientSecret;

/*!
 *  The ID for the currently logged in user.
 */
@property (copy, nonatomic) NSString *userID;

/*!
 *  An ID for the current session.
 */
@property (copy, nonatomic) NSString *sessionID;

/*!
 *  The Locale the client is in. This defaults to being configured with [NSLocale currentLocale].
 *  This will use the `languageCode` property of the locale to submit along to supported endpoints.
 */
@property (copy, nonatomic) NSLocale *locale;

/*!
 *  The Rich Relevance API endpoint. Default value is RCHEndpointProduction
 */
@property (copy, readonly, nonatomic) NSString *endpoint;

/*!
 *  A channel is a description of the caller of this API. This defaults to 'iOS'.
 */
@property (copy, readonly, nonatomic) NSString *channel;

/*!
 *  Whether or not to use HTTPS for all requests. Default value is YES.
 */
@property (assign, readonly, nonatomic) BOOL useHTTPS;

///-------------------------------
/// @name Initialization
///-------------------------------

- (instancetype)init NS_UNAVAILABLE;

/*!
 *  Create a new API client configuration instance.
 */
- (instancetype)initWithAPIKey:(NSString *)APIKey
                  APIClientKey:(NSString *)APIClientKey;

/*!
 *  Create a new API client configuration instance.
 */
- (instancetype)initWithAPIKey:(NSString *)APIKey
                  APIClientKey:(NSString *)APIClientKey
                      endpoint:(NSString *)endpoint
                      useHTTPS:(BOOL)useHTTPS;

///-------------------------------
/// @name Other
///-------------------------------

/*!
 *  Creates a full HTTP base URL for the default configured endpoint.
 *
 *  @return An HTTP base URL
 */
- (NSURL * __nullable)baseURL;

/*!
 *  Validates this configuration includes values for all required fields.
 *
 *  @return YES if valid, NO if not valid
 */
- (BOOL)isValid;

/*!
 *  Creates a default instance of NSURLSessionConfiguration to be used when configuring
 *  an NSURLSession for RCHAPIClient.
 *
 *  @return A default NSURLSessionConfiguration
 */
+ (NSURLSessionConfiguration *)sessionConfiguration;

/*!
 *  Returns the protocol string for the current configuration.
 *
 *  @return If useHTTPS is YES, returns ```https://``` else returns ```http://```
 */
- (NSString *)protocolString;

@end

NS_ASSUME_NONNULL_END
