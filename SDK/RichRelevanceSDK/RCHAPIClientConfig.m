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

#import "RCHAPIClientConfig.h"

NSString *const RCHEndpointProduction = @"recs.richrelevance.com";
NSString *const RCHEndpointIntegration = @"integration.richrelevance.com";

NSString *const RCHDefaultChannel = @"iOS";

static const NSTimeInterval kRCHAPIClientConfigDefaultRequestTimeout = 20.0f;
static const NSTimeInterval kRCHAPIClientConfigDefaultResourceTimeout = 60.0f;

@interface RCHAPIClientConfig ()

@property (copy, readwrite, nonatomic) NSString *APIKey;
@property (copy, readwrite, nonatomic) NSString *APIClientKey;

@property (copy, readwrite, nonatomic) NSString *endpoint;
@property (assign, readwrite, nonatomic) BOOL useHTTPS;

@end

@implementation RCHAPIClientConfig : NSObject

- (instancetype)initWithAPIKey:(NSString *)APIKey
                  APIClientKey:(NSString *)APIClientKey
                      endpoint:(NSString *)endpoint
                      useHTTPS:(BOOL)useHTTPS
{
    self = [super init];
    if (self) {
        _endpoint = endpoint;
        _useHTTPS = useHTTPS;

        _APIKey = APIKey;
        _APIClientKey = APIClientKey;
        _locale = [NSLocale currentLocale];
        _channel = RCHDefaultChannel;
        if (![self isValid]) {
            return nil;
        }
    }
    return self;
}

- (instancetype)initWithAPIKey:(NSString *)APIKey
                  APIClientKey:(NSString *)APIClientKey
{
    return [[[self class] alloc] initWithAPIKey:APIKey
                                   APIClientKey:APIClientKey
                                       endpoint:RCHEndpointProduction
                                       useHTTPS:YES];
}

- (BOOL)isValid
{
    return (self.APIKey != nil && self.APIClientKey != nil && self.endpoint != nil);
}

- (BOOL)isProduction
{
    return [self.endpoint isEqualToString:RCHEndpointProduction];
}

- (NSURL *)baseURL
{
    NSURL *URL = nil;
    if (self.endpoint != nil) {
        NSString *protocol = self.useHTTPS ? @"https" : @"http";
        NSString *URLString = [NSString stringWithFormat:@"%@://%@", protocol, self.endpoint];
        URL = [NSURL URLWithString:URLString];
    }

    return URL;
}

+ (NSURLSessionConfiguration *)sessionConfiguration
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];

    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    sessionConfig.timeoutIntervalForRequest = kRCHAPIClientConfigDefaultRequestTimeout;
    sessionConfig.timeoutIntervalForResource = kRCHAPIClientConfigDefaultResourceTimeout;
    sessionConfig.HTTPShouldUsePipelining = YES;

    return sessionConfig;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Configuration:\nAPIKey:%@\nAPIClientKey:%@\nUserID:%@\nSessionID:%@\nEndpoint:%@\nUseHTTPS:%d\n",
                                      _APIKey,
                                      _APIClientKey,
                                      _userID,
                                      _sessionID,
                                      _endpoint,
                                      _useHTTPS];
}

- (NSString *)protocolString
{
    return self.useHTTPS ? @"https" : @"http";
}

@end
