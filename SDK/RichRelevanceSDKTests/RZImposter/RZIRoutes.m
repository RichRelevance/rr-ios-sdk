//
//  RZIRoutes.m
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

#import "RZIRoutes.h"

NSString *const kRZIRequestMatchHeadersKey = @"RZIRequestMatchHeadersKey";

NSString *const kRZIRequestPathParametersKey = @"RZIRequestPathParametersKey";
NSString *const kRZIRequestQueryParametersKey = @"RZIRequestQueryParametersKey";

@implementation RZIRouteInfo
@end

@interface RZIRoutes ()

@property (strong, nonatomic) NSMutableArray *routes;

@end

@implementation RZIRoutes

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.routes = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)allRoutes
{
    return [self.routes copy];
}

- (void)HTTPMethod:(NSString *)HTTPMethod path:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block
{
    NSParameterAssert(HTTPMethod);
    NSParameterAssert(path);
    NSParameterAssert(block);

    RZIRouteInfo *routeInfo = [[RZIRouteInfo alloc] init];
    routeInfo.HTTPMethod = HTTPMethod;
    routeInfo.path = path;
    routeInfo.matchDict = matchDict;
    routeInfo.responseBlock = block;

    [self.routes addObject:routeInfo];
}

- (void)get:(NSString *)path do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"GET" path:path match:nil do:block];
}

- (void)get:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"GET" path:path match:matchDict do:block];
}

- (void)head:(NSString *)path do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"HEAD" path:path match:nil do:block];
}

- (void)head:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"HEAD" path:path match:matchDict do:block];
}

- (void)post:(NSString *)path do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"POST" path:path match:nil do:block];
}

- (void)post:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"POST" path:path match:matchDict do:block];
}

- (void)put:(NSString *)path do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"PUT" path:path match:nil do:block];
}

- (void)put:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"PUT" path:path match:matchDict do:block];
}

- (void) delete:(NSString *)path do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"DELETE" path:path match:nil do:block];
}

- (void) delete:(NSString *)path match:(NSDictionary *)matchDict do:(RZItubRouteResponseBlock)block
{
    [self HTTPMethod:@"DELETE" path:path match:matchDict do:block];
}

@end
