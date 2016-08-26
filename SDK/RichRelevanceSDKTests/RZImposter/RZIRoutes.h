//
//  RZIRoutes.h
//
// Copyright 2015 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

@import Foundation;
#import "OHHTTPStubs.h"

typedef OHHTTPStubsResponse * (^RZItubRouteResponseBlock)(NSURLRequest *request, NSDictionary *requestInfo);

// MATCHER KEYS

/**
 *  Use this key in the "match" parameter of a route in order to match on HTTP header key-value pairs.
 */
OBJC_EXTERN NSString *const kRZIRequestMatchHeadersKey;

// REQUEST PARAMS

/**
 *  Used to lookup the token replaced path parameters in a requestInfo dictionary.
 */
OBJC_EXTERN NSString *const kRZIRequestPathParametersKey;
/**
 *  Used to lookup the query parameters in a requestInfo dictionary.
 */
OBJC_EXTERN NSString *const kRZIRequestQueryParametersKey;

@interface RZIRouteInfo : NSObject

@property (copy, nonatomic) NSString *path;
@property (copy, nonatomic) NSString *HTTPMethod;
@property (copy, nonatomic) NSDictionary *matchDict;
@property (copy, nonatomic) RZItubRouteResponseBlock responseBlock;

@end

/**
 *  A set of routes that define HTTP request mocking behavior based on HTTP method, path, query, and other match items.
 */
@interface RZIRoutes : NSObject

/**
 *  A list of all individual route info objects for this route set.
 */
@property (strong, nonatomic, readonly) NSArray *allRoutes;

/**
 *  Mock an HTTP GET for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param block The response block to invoke on match.
 */
- (void)get:(NSString *)path do:(RZItubRouteResponseBlock)block;
/**
 *  Mock an HTTP GET for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param matchDict  Additional match conditions such as HTTP header matching.
 *  @param block The response block to invoke on match.
 */
- (void)get:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block;

/**
 *  Mock an HTTP HEAD for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param block The response block to invoke on match.
 */
- (void)head:(NSString *)path do:(RZItubRouteResponseBlock)block;
/**
 *  Mock an HTTP HEAD for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param matchDict  Additional match conditions such as HTTP header matching.
 *  @param block The response block to invoke on match.
 */
- (void)head:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block;

/**
 *  Mock an HTTP POST for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param block The response block to invoke on match.
 */
- (void)post:(NSString *)path do:(RZItubRouteResponseBlock)block;
/**
 *  Mock an HTTP POST for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param matchDict  Additional match conditions such as HTTP header matching.
 *  @param block The response block to invoke on match.
 */
- (void)post:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block;

/**
 *  Mock an HTTP PUT for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param block The response block to invoke on match.
 */
- (void)put:(NSString *)path do:(RZItubRouteResponseBlock)block;
/**
 *  Mock an HTTP PUT for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param matchDict  Additional match conditions such as HTTP header matching.
 *  @param block The response block to invoke on match.
 */
- (void)put:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block;

/**
 *  Mock an HTTP DELETE for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param block The response block to invoke on match.
 */
- (void) delete:(NSString *)path do:(RZItubRouteResponseBlock)block;
/**
 *  Mock an HTTP DELETE for the given path by responding with block.
 *
 *  @param path  The relative path to match.
 *  @param matchDict  Additional match conditions such as HTTP header matching.
 *  @param block The response block to invoke on match.
 */
- (void) delete:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block;

@end
