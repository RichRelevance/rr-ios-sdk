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

FOUNDATION_EXPORT double RCHOAuthVersionNumber;
FOUNDATION_EXPORT const unsigned char RCHOAuthVersionString[];

typedef NS_ENUM(NSInteger, RCHOAuthSignatureMethod) {
    RCHOAuthSignatureMethodHmacSha1,
    RCHOAuthSignatureMethodHmacSha256,
};
typedef NS_ENUM(NSInteger, RCHOAuthContentType) {
    RCHOAuthContentTypeUrlEncodedForm,
    RCHOAuthContentTypeJsonObject,
};

@interface RCHOAuth : NSObject
/**
  @p unencodeParameters may be nil. Objects in the dictionary must be strings.
  You are contracted to consume the NSURLRequest *immediately*. Don't put the
  queryParameters in the path as a query string! Path MUST start with a slash!
  Don't percent encode anything! This will submit via HTTP. If you need HTTPS refer
  to the next selector.
*/
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath_WITHOUT_Query
                      GETParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;

/**
  Some services insist on HTTPS. Or maybe you don't want the data to be sniffed.
  You can pass @"https" via the scheme parameter.
*/
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath_WITHOUT_Query
                      GETParameters:(NSDictionary *)unencodedParameters
                             scheme:(NSString *)scheme
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;

/**
  We always POST with HTTPS. This is because at least half the time the user's
  data is at least somewhat private, but also because apparently some carriers
  mangle POST requests and break them. We saw this in France for example.
  READ THE DOCUMENTATION FOR GET AS IT APPLIES HERE TOO!
*/
+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath
                     POSTParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;

/**
 This method allows the caller to specify particular values for many different parameters such
 as scheme, method, header values and alternate signature hash algorithms.

 @p scheme may be any string value, generally "http" or "https".
 @p requestMethod may be any string value. There is no validation, so remember that all
 currently-defined HTTP methods are uppercase and the RFC specifies that the method
 is case-sensitive.
 @p dataEncoding allows for the transmission of data as either URL-encoded form data or
 JSON by passing the value RCHOAuthContentTypeUrlEncodedForm or RCHOAuthContentTypeJsonObject.
 This parameter is ignored for the requestMethod "GET".
 @p headerValues accepts a hash of key-value pairs (both must be strings) that specify
 HTTP header values to be included in the resulting URL Request. For example, the argument
 value @{@"Accept": @"application/json"} will include the header to indicate the server
 should respond with JSON. Other values are acceptable, depending on the server, but be
 careful. Values you supply will override the defaults which are set for User-Agent
 (set to "app-bundle-name/version" your app resources), Accept-Encoding (set to "gzip")
 and the calculated Authentication header. Attempting to specify the latter will be fatal.
 You should also avoid passing in values for the Content-Type and Content-Length header fields.
 @p signatureMethod accepts an enum and should normally be set to RCHOAuthSignatureMethodHmacSha1.
 You have the option of using HMAC-SHA256 by setting this parameter to
 RCHOAuthSignatureMethodHmacSha256; this is not included in the RFC for OAuth 1.0a, so most servers
 will not support it.
*/

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPathWithoutQuery
                         parameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret
                             scheme:(NSString *)scheme
                      requestMethod:(NSString *)method
                       dataEncoding:(RCHOAuthContentType)dataEncoding
                       headerValues:(NSDictionary *)headerValues
                    signatureMethod:(RCHOAuthSignatureMethod)signatureMethod;

/**

 OAuth requires the UTC timestamp we send to be accurate. The user's device
 may not be, and often isn't. To work around this you should set this to the
 UTC timestamp that you get back in HTTP headers from OAuth servers.
 */
+ (int)utcTimeOffset;
+ (void)setUtcTimeOffset:(int)offset;

@end

/**
  XAuth example (because you may otherwise be scratching your head):

    NSURLRequest *xauth = [RCHOAuth URLRequestForPath:@"/oauth/access_token"
                                      POSTParameters:[NSDictionary dictionaryWithObjectsAndKeys:
                                                      username, @"x_auth_username",
                                                      password, @"x_auth_password",
                                                      @"client_auth", @"x_auth_mode",
                                                      nil]
                                                host:@"api.twitter.com"
                                         consumerKey:CONSUMER_KEY
                                      consumerSecret:CONSUMER_SECRET
                                         accessToken:nil
                                         tokenSecret:nil];

  OAuth Echo example (we have found that some consumers require HTTPS for the
  echo, so to be safe we always do it):

    NSURLRequest *echo = [RCHOAuth URLRequestForPath:@"/1/account/verify_credentials.json"
                                      GETParameters:nil
                                             scheme:@"https"
                                               host:@"api.twitter.com"
                                        consumerKey:CONSUMER_KEY
                                     consumerSecret:CONSUMER_SECRET
                                        accessToken:accessToken
                                        tokenSecret:tokenSecret];
    NSMutableURLRequest *rq = [NSMutableURLRequest new];
    [rq setValue:[[echo URL] absoluteString] forHTTPHeaderField:@"X-Auth-Service-Provider"];
    [rq setValue:[echo valueForHTTPHeaderField:@"Authorization"] forHTTPHeaderField:@"X-Verify-Credentials-Authorization"];
    // Now consume rq with an NSURLConnection
    [rq release];
*/

/**
  Suggested usage would be to make some categories for this class that
  automatically adds both secrets, both tokens and host information. This
  makes usage less cumbersome. Eg:

      [TwitterOAuth GET:@"/1/statuses/home_timeline.json"];
      [TwitterOAuth GET:@"/1/statuses/home_timeline.json" queryParameters:dictionary];

  At TweetDeck we have RCHAccount classes that represent separate user logins
  for different services when instantiated.
*/
