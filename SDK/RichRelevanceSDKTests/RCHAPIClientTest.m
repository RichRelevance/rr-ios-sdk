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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#define EXP_SHORTHAND
#import "Expecta.h"
#import "RCHAPIClientConfig.h"
#import "RCHAPIClient.h"
#import "RZIHost.h"
#import "RZIRoutes.h"
#import "OHHTTPStubsResponse+JSON.h"
#import "RCHAPIConstants.h"
#import "RCHErrors.h"
#import "RCHRecsForPlacementsResponseParser.h"
#import "RCHNetworkReachabilityManager.h"

@interface RCHAPIClient (UnderTest)

@property (strong, nonatomic) RCHNetworkReachabilityManager *reachability;
@property (strong, nonatomic) NSMutableArray *failedClickTrackURLs;

- (NSURLSessionTask *)GET:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(RCHAPIClientSuccess)success
                  failure:(RCHAPIClientFailure)failure;

- (NSURLSessionTask *)GET:(NSString *)path
               parameters:(NSDictionary *)parameters
           signUsingOAuth:(BOOL)signUsingOAuth
                  success:(RCHAPIClientSuccess)success
                  failure:(RCHAPIClientFailure)failure;

- (NSURLRequest *)OAuthURLRequestFromPath:(NSString *)path parameters:(NSDictionary *)parameters;

- (NSURL *)URLFromPath:(NSString *)path parameters:(NSDictionary *)parameters;

@end

typedef void (^RCHNetworkReachabilityStatusBlock)(RCHNetworkReachabilityStatus status);

@interface RCHNetworkReachabilityManager (UnderTest)
@property (readwrite, nonatomic, copy) RCHNetworkReachabilityStatusBlock networkReachabilityStatusBlock;
@end

@interface RCHAPIClientTest : XCTestCase

@property (strong, nonnull) RCHAPIClient *client;
@property (strong, nonnull) RZIHost *mockHost;
@property (strong, nonnull) RCHAPIClientConfig *config;

@end

@implementation RCHAPIClientTest

- (void)setUp
{
    [super setUp];

    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey" endpoint:RCHEndpointProduction useHTTPS:NO];
    config.userID = @"user";
    config.sessionID = @"session";
    config.APIClientSecret = @"secret";
    self.config = config;
    self.client = [[RCHAPIClient alloc] init];
    [self.client configure:config];

    self.mockHost = [[RZIHost alloc] initWithBaseURL:[config baseURL]];
}

#pragma mark - URL

- (void)testURLFromPath_Good
{
    NSURL *URL = [self.client URLFromPath:@"test" parameters:@{ @"a" : @"1",
                                                                @"b1" : @YES,
                                                                @"b2" : @NO,
                                                                @"b3" : @1 }];
    NSString *expected = [NSString stringWithFormat:@"%@/test?a=1&b1=true&b2=false&b3=1", [self.config baseURL]];
    expect([URL absoluteString]).to.equal(expected);
}

- (void)testURLFromPath_RepeatParams
{
    NSURL *URL = [self.client URLFromPath:@"test" parameters:@{ @"a" : @"1",
                                                                @"b" : @[ @"1", @"2" ],
                                                                @"c" : @[ @"3", @"4" ] }];
    NSString *expected = [NSString stringWithFormat:@"%@/test?a=1&b=1&b=2&c=3&c=4", [self.config baseURL]];
    expect([URL absoluteString]).to.equal(expected);
}

- (void)testOAuthURLRequestFromPath_Good
{
    NSURLRequest *request = [self.client OAuthURLRequestFromPath:@"test" parameters:@{ @"a" : @"1" }];
    expect(request).notTo.beNil();

    NSString *expectedURL = [NSString stringWithFormat:@"%@/test/key/user?a=1", [self.config baseURL]];
    expect([request.URL absoluteString]).to.equal(expectedURL);
    expect([request valueForHTTPHeaderField:@"Authorization"]).notTo.beNil();
}

#pragma mark - HTTP

- (void)testGET_NoParam
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:nil success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        expect(responseObject).to.beKindOf([NSDictionary class]);

        NSDictionary *dict = (NSDictionary *)responseObject;
        expect(dict[@"result"]).to.equal(@"test");

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure([NSString stringWithFormat:@"Failed with error: %@", error]);
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_Params
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSDictionary *params = requestInfo[kRZIRequestQueryParametersKey];
        expect(params[@"foo"]).to.equal(@"bar");
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ kRCHAPIBuilderParamRequestParameters : @{@"foo" : @"bar"} } success:^(id responseObject) {
        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure([NSString stringWithFormat:@"Failed with error: %@", error]);
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_Params_OAuth
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/test/key/user" do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSDictionary *params = requestInfo[kRZIRequestQueryParametersKey];
        expect(params[@"foo"]).to.equal(@"bar");
        expect([request valueForHTTPHeaderField:@"Authorization"]).notTo.beNil();
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ kRCHAPIBuilderParamRequestParameters : @{@"foo" : @"bar"} } success:^(id responseObject) {
        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure([NSString stringWithFormat:@"Failed with error: %@", error]);
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_HTTPNon200
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"error" : @"test" } statusCode:400 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ @"foo" : @"bar" } success:^(id responseObject) {
        failure(@"HTTP Error should cause failure");
    } failure:^(id responseObject, NSError *error) {
        done = YES;
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_Error
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:nil]];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ @"foo" : @"bar" } success:^(id responseObject) {
        failure(@"Error should cause failure");
    } failure:^(id responseObject, NSError *error) {
        done = YES;
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_BadJSON
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSData *data = [@"junk" dataUsingEncoding:NSUTF8StringEncoding];
        return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ @"foo" : @"bar" } success:^(id responseObject) {
        failure(@"Error should cause failure");
    } failure:^(id responseObject, NSError *error) {
        done = YES;
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_Signed
{
    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSDictionary *queryParams = requestInfo[kRZIRequestQueryParametersKey];
        expect(queryParams[kRCHAPICommonParamAPIKey]).to.equal(@"key");
        expect(queryParams[kRCHAPICommonParamAPIClientKey]).to.equal(@"clientKey");
        expect(queryParams[kRCHAPICommonParamUserID]).to.equal(@"user");
        expect(queryParams[kRCHAPICommonParamSessionID]).to.equal(@"session");

        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ kRCHAPIBuilderParamRequestParameters : @{@"foo" : @"bar"} } success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        expect(responseObject).to.beKindOf([NSDictionary class]);

        NSDictionary *dict = (NSDictionary *)responseObject;
        expect(dict[@"result"]).to.equal(@"test");

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure([NSString stringWithFormat:@"Failed with error: %@", error]);
    }];

    expect(done).will.beTruthy();
}

- (void)testGET_Signed_NoUserAndSession
{
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey" endpoint:RCHEndpointProduction useHTTPS:NO];
    [self.client configure:config];

    NSString *path = @"/test";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSDictionary *queryParams = requestInfo[kRZIRequestQueryParametersKey];
        expect(queryParams[kRCHAPICommonParamAPIKey]).to.equal(@"key");
        expect(queryParams[kRCHAPICommonParamAPIClientKey]).to.equal(@"clientKey");
        expect(queryParams[kRCHAPICommonParamUserID]).to.beNil();
        expect(queryParams[kRCHAPICommonParamSessionID]).to.beNil();

        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client GET:path parameters:@{ kRCHAPIBuilderParamRequestParameters : @{@"foo" : @"bar"} } success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        expect(responseObject).to.beKindOf([NSDictionary class]);

        NSDictionary *dict = (NSDictionary *)responseObject;
        expect(dict[@"result"]).to.equal(@"test");

        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure([NSString stringWithFormat:@"Failed with error: %@", error]);
    }];

    expect(done).will.beTruthy();
}

#pragma mark - Send Request

- (void)testSendRequest_Good
{
    NSString *path = @"/recsForPlacements";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSDictionary *queryParams = requestInfo[kRZIRequestQueryParametersKey];
        expect(queryParams[kRCHAPICommonParamAPIKey]).to.equal(@"key");
        expect(queryParams[kRCHAPICommonParamAPIClientKey]).to.equal(@"clientKey");
        expect(queryParams[kRCHAPICommonParamUserID]).to.equal(@"user");
        expect(queryParams[kRCHAPICommonParamSessionID]).to.equal(@"session");

        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    NSDictionary *params = @{ kRCHAPIBuilderParamRequestInfo : @{kRCHAPIBuilderParamRequestInfoPath : path},
                              kRCHAPIBuilderParamRequestParameters : @{} };
    __block BOOL done = NO;
    [self.client sendRequest:params success:^(id responseObject) {
        expect(responseObject).notTo.beNil();
        done = YES;
    } failure:^(id responseObject, NSError *error) {
        failure(@"Request should not fail");
    }];

    expect(done).will.beTruthy();
}

- (void)testSendRequest_NoBlocks
{
    NSString *path = @"/recsForPlacements";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        failure(@"API should never be invoked");
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    NSDictionary *params = @{kRCHAPIBuilderParamRequestInfoPath : path};
    [self.client sendRequest:params success:nil failure:nil];
}

- (void)testSendRequest_NoParams
{
    NSString *path = @"/recsForPlacements";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        failure(@"API should never be invoked");
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client sendRequest:nil success:^(id responseObject) {
        failure(@"Request should not succeed");
    } failure:^(id responseObject, NSError *error) {
        expect(error.domain).to.equal(kRCHSDKErrorDomain);
        expect(error.code).to.equal(RCHSDKErrorCodeInvalidArguments);
        done = YES;
    }];

    expect(done).will.beTruthy();
}

- (void)testSendRequest_MissingPath
{
    NSString *path = @"/recsForPlacements";
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        failure(@"API should never be invoked");
        return [OHHTTPStubsResponse responseWithJSONObject:@{ @"result" : @"test" } statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    __block BOOL done = NO;
    [self.client sendRequest:@{} success:^(id responseObject) {
        failure(@"Request should not succeed");
    } failure:^(id responseObject, NSError *error) {
        expect(error.domain).to.equal(kRCHSDKErrorDomain);
        expect(error.code).to.equal(RCHSDKErrorCodeInvalidArguments);
        done = YES;
    }];

    expect(done).will.beTruthy();
}

- (void)testSendRequest_APIError
{
    NSString *path = kRCHAPIRequestRecsForPlacementsPath;
    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:path do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        NSURL *URL = [[NSBundle bundleForClass:[self class]] URLForResource:@"recs_for_placements_error" withExtension:@"json"];
        NSData *data = [[NSData alloc] initWithContentsOfURL:URL];
        id JSONObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        return [OHHTTPStubsResponse responseWithJSONObject:JSONObject statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    NSDictionary *params = @{ kRCHAPIBuilderParamRequestInfo : @{
        kRCHAPIBuilderParamRequestInfoPath : path,
        kRCHAPIBuilderParamRequestInfoParserClass : [RCHRecsForPlacementsResponseParser class]
    }
    };
    __block BOOL done = NO;
    [self.client sendRequest:params success:^(id responseObject) {
        failure(@"Request should fail");
    } failure:^(id responseObject, NSError *error) {
        expect(error).notTo.beNil();
        done = YES;
    }];

    expect(done).will.beTruthy();
}

#pragma mark - View Tracking

- (void)testViewTrack_Good
{
    __block BOOL done = NO;

    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/click" do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        done = YES;
        return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:nil];
    }];
    [self.mockHost registerRoutes:routes];

    [self.client trackProductViewWithURL:[[[self.config baseURL] absoluteString] stringByAppendingFormat:@"/click"]];

    expect(done).will.beTruthy();
}

- (void)testViewTrack_Good_Error
{
    __block BOOL doneCount = 0;
    __block BOOL returnError = YES;

    RZIRoutes *routes = [[RZIRoutes alloc] init];
    [routes get:@"/click" do:^OHHTTPStubsResponse *(NSURLRequest *request, NSDictionary *requestInfo) {
        doneCount++;

        if (returnError) {
            return [OHHTTPStubsResponse responseWithError:[NSError errorWithDomain:@"domain" code:0 userInfo:nil]];
        }
        else {
            return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:nil];
        }
    }];
    [self.mockHost registerRoutes:routes];

    NSString *fullURL = [[[self.config baseURL] absoluteString] stringByAppendingFormat:@"/click"];
    [self.client trackProductViewWithURL:fullURL];
    [self.client trackProductViewWithURL:fullURL];

    expect(doneCount).will.equal(1);
    expect(self.client.failedClickTrackURLs).to.haveCount(2);
    expect(self.client.failedClickTrackURLs).to.contain(fullURL);

    doneCount = 0;
    returnError = NO;

    self.client.reachability.networkReachabilityStatusBlock(RCHNetworkReachabilityStatusReachableViaWWAN);

    expect(doneCount).will.equal(1);
    expect(self.client.failedClickTrackURLs).to.haveCount(0);
}

@end
