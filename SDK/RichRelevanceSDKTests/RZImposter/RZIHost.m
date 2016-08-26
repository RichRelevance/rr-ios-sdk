//
//  RZIHost.m
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

#import "RZIHost.h"
#import "OHHTTPStubs.h"
#import "RZIRoutes.h"
#import "NSURL+RZIExtensions.h"
#import "NSURLRequest+RZIExtensions.h"

@interface RZIHost ()

@property (copy, nonatomic) NSURL *baseURL;

@end

@implementation RZIHost

- (instancetype)initWithBaseURL:(NSURL *)baseURL
{
    self = [super init];
    if (self) {
        _baseURL = baseURL;
    }
    return self;
}

- (void)dealloc
{
    // TODO: be more selective
    [OHHTTPStubs removeAllStubs];
}

- (void)registerRoutes:(RZIRoutes *)routes
{
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        // TODO: match on scheme too? Probably
        if ([request.URL.host isEqualToString:self.baseURL.host] && [request.URL.port intValue] == [self.baseURL.port intValue]) {
            return [self findRouteInfoFromRoutes:routes forRequest:request] != nil;
        }

        return NO;
    }
                        withStubResponse:
                            ^OHHTTPStubsResponse *(NSURLRequest *request) {
                                RZIRouteInfo *routeInfo = [self findRouteInfoFromRoutes:routes forRequest:request];
                                NSMutableDictionary *params = [NSMutableDictionary dictionary];

                                NSString *routePath = [self.baseURL.path stringByAppendingPathComponent:routeInfo.path];
                                NSDictionary *pathParams = [[NSURL URLWithString:routePath] rzi_tokenReplacedPathValuesFromPopulatedURL:request.URL];
                                if (pathParams != nil) {
                                    params[kRZIRequestPathParametersKey] = pathParams;
                                }

                                NSDictionary *queryParams = [request.URL rzi_queryParamsAsDictionary];
                                if (queryParams != nil) {
                                    params[kRZIRequestQueryParametersKey] = queryParams;
                                }

                                OHHTTPStubsResponse *stubResp = nil;
                                if (routeInfo != nil) {
                                    stubResp = routeInfo.responseBlock(request, [params copy]);
                                }

                                return stubResp;
                            }];
}

- (RZIRouteInfo *)findRouteInfoFromRoutes:(RZIRoutes *)routes forRequest:(NSURLRequest *)request
{
    RZIRouteInfo *foundRoute = nil;

    for (RZIRouteInfo *routeInfo in routes.allRoutes) {
        NSString *testPath = [self.baseURL.path stringByAppendingPathComponent:routeInfo.path];
        BOOL matchesPath = [[NSURL URLWithString:testPath] rzi_tokenReplacedPathValuesFromPopulatedURL:request.URL] != nil;

        BOOL matchesHeaders = YES;
        NSDictionary *headersToMatch = routeInfo.matchDict[kRZIRequestMatchHeadersKey];
        if (headersToMatch != nil) {
            matchesHeaders = [request rzi_containsHeaders:headersToMatch];
        }

        if (matchesPath && matchesHeaders) {
            foundRoute = routeInfo;
            break;
        }
    }

    return foundRoute;
}

@end
