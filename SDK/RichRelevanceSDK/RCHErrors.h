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
 *  Error domain for Rich Relevance SDK errors.
 */
OBJC_EXTERN NSString *const kRCHSDKErrorDomain;

/*!
 *  Rich Relevance SDK error codes.
 */
typedef NS_ENUM(NSInteger, RCHSDKErrorCode) {
    /*!
     *  An uknown error occurred.
     */
    RCHSDKErrorCodeUnknown = 0,
    /*!
     *  The SDK was not properly configured prior to executing requests.
     */
    RCHSDKErrorCodeSDKNotConfigured,
    /*!
     *  Invalid arguments were passed to an SDK method such that it could not be executed.
     */
    RCHSDKErrorCodeInvalidArguments,
    /*!
     *  An API response could not be parsed.
     */
    RCHSDKErrorCodeCannotParseResponse,
    /*!
     *  The Rich Relevance API responded with an error.
     */
    RCHSDKErrorCodeAPIError,
    /*!
     *  An HTTP error was encountered. 
     */
    RCHSDKErrorCodeHTTPError
};
