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

@interface RCHAPIClientConfigTest : XCTestCase

@end

@implementation RCHAPIClientConfigTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)testInit
{
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey"];
    config.userID = @"userID";
    config.sessionID = @"sessionID";

    expect(config).notTo.beNil();
    expect(config.APIKey).to.equal(@"key");
    expect(config.APIClientKey).to.equal(@"clientKey");
    expect(config.userID).to.equal(@"userID");
    expect(config.sessionID).to.equal(@"sessionID");
    expect(config.endpoint).equal(RCHEndpointProduction);
    expect(config.useHTTPS).to.beTruthy();

    config = [[RCHAPIClientConfig alloc] initWithAPIKey:nil APIClientKey:@"clientKey"];
    expect(config).to.beNil();

    config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:nil];
    expect(config).to.beNil();

    config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey" endpoint:nil useHTTPS:YES];
    expect(config).to.beNil();
}

- (void)testBaseURL
{
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey"];
    NSURL *baseURL = [config baseURL];
    expect(baseURL).notTo.beNil();
    expect(baseURL).to.beKindOf([NSURL class]);
    expect([baseURL scheme]).to.equal(@"https");
    //    expect([baseURL host]).to.equal(RCHEndpointProduction);

    config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"key" APIClientKey:@"clientKey" endpoint:@"foo.com" useHTTPS:NO];
    baseURL = [config baseURL];
    expect(baseURL).notTo.beNil();
    expect(baseURL).to.beKindOf([NSURL class]);
    expect([baseURL scheme]).to.equal(@"http");
    expect([baseURL host]).to.equal(@"foo.com");
}

- (void)testSessionConfiguration
{
    NSURLSessionConfiguration *sessionConfig = [RCHAPIClientConfig sessionConfiguration];
    expect(sessionConfig).notTo.beNil();
    expect(sessionConfig).to.beKindOf([NSURLSessionConfiguration class]);

    expect(sessionConfig.requestCachePolicy).to.equal(NSURLRequestReloadIgnoringCacheData);
    expect(sessionConfig.timeoutIntervalForRequest).to.equal(20.0);
    expect(sessionConfig.timeoutIntervalForResource).to.equal(60.0f);
    expect(sessionConfig.HTTPShouldUsePipelining).to.beTruthy();
}

@end
