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

#import "RCHAPIClient.h"
#import "RCHAPIClientConfig.h"
#import "RCHLog.h"
#import "RCHWebUtils.h"
#import "RCHErrors.h"
#import "RCHAPIConstants.h"
#import "RCHAPIResponseParser.h"
#import "RCHOAuth.h"
#import "RCHNetworkReachabilityManager.h"
#import "RCHAPIResult.h"

@interface RCHAPIClient ()

@property (strong, readwrite, nonatomic) RCHAPIClientConfig *clientConfig;
@property (strong, nonatomic) NSURLSession *URLSession;
@property (strong, nonatomic) RCHNetworkReachabilityManager *reachability;
@property (strong, nonatomic) NSMutableArray *failedClickTrackURLs;

@property (copy, nonatomic) NSString *opaqueRCSToken;

@end

@implementation RCHAPIClient

- (instancetype)init
{
    self = [super init];
    if (self) {
        _failedClickTrackURLs = [NSMutableArray array];
    }
    return self;
}

- (void)configure:(RCHAPIClientConfig *)config
{
    if (_URLSession) {
        [RCHLog logInfo:@"Applying new client configuration, invalidating existing session..."];
        [_URLSession invalidateAndCancel];
        _URLSession = nil;
    }

    [RCHLog logInfo:@"Configuring API client with config: %@", config];

    self.clientConfig = config;
}

#pragma mark - Session

- (NSURLSession *)URLSession
{
    if (_URLSession == nil) {
        NSURLSessionConfiguration *config = [RCHAPIClientConfig sessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:config];
    }

    return _URLSession;
}

#pragma mark - Request Execution

- (void)sendRequest:(NSDictionary *)requestDict
{
    [self sendRequest:requestDict success:^(id responseObject) {
    } failure:^(id responseObject, NSError *error){
    }];
}

- (void)sendRequest:(NSDictionary *)requestDict
            success:(RCHAPIClientSuccess)success
            failure:(RCHAPIClientFailure)failure
{
    @try {
        [self internalSendRequest:requestDict success:success failure:failure];
    }
    @catch (NSException *exception) {
        [RCHLog logError:@"%s: Error processing request: %@", __PRETTY_FUNCTION__, exception];
        if (failure != nil) {
            [self invokefailure:failure errorCode:RCHSDKErrorCodeUnknown message:@"Unknown error while executing request"];
        }
    }
}

- (void)internalSendRequest:(NSDictionary *)requestDict
                    success:(RCHAPIClientSuccess)success
                    failure:(RCHAPIClientFailure)failure
{
    [RCHLog logInfo:@"Sending API request."];
    [RCHLog logDebug:@"Request: %@", requestDict];

    if ([self validateRequest:requestDict success:success failure:failure]) {
        NSMutableDictionary *requestInfo = [requestDict[kRCHAPIBuilderParamRequestInfo] mutableCopy];

        if ([requestInfo[kRCHAPIBuilderParamRequestInfoEmbedRCS] boolValue]) {
            requestInfo[kRCHAPICommonParamRCS] = self.opaqueRCSToken;
        }
        [self GET:requestInfo[kRCHAPIBuilderParamRequestInfoPath] parameters:requestDict success:^(id responseObject) {

            [RCHLog logDebug:@"%s: API responded with: %@", __PRETTY_FUNCTION__, responseObject];

            id result = responseObject;
            id<RCHAPIResponseParser> parser = [[requestInfo[kRCHAPIBuilderParamRequestInfoParserClass] alloc] init];
            if (parser != nil && responseObject != nil) {
                NSError *parseError = nil;
                result = [parser parseResponse:responseObject error:&parseError];

                if ([result isKindOfClass:[RCHAPIResult class]]) {
                    RCHAPIClient *apiResult = result;
                    self.opaqueRCSToken = apiResult.opaqueRCSToken ?: self.opaqueRCSToken;
                }

                if (parseError != nil) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(result, parseError);
                    });
                    return;
                }
            }

            dispatch_async(dispatch_get_main_queue(), ^{
                success(result);
            });
        } failure:^(id responseObject, NSError *error) {
            [RCHLog logError:@"%s: API failed with: %@", __PRETTY_FUNCTION__, error];

            dispatch_async(dispatch_get_main_queue(), ^{
                failure(responseObject, error);
            });
        }];
    }
}

- (BOOL)validateRequest:(NSDictionary *)requestDict
                success:(RCHAPIClientSuccess)success
                failure:(RCHAPIClientFailure)failure
{
    if (![self assertNotNilSuccess:success failure:failure]) {
        return NO;
    }

    if (![self.clientConfig isValid]) {
        [self invokefailure:failure errorCode:RCHSDKErrorCodeSDKNotConfigured message:@"Invalid or missing SDK configuration. Please call configure: on the SDK client and pass a valid configuration."];
        return NO;
    }

    if (requestDict == nil) {
        [self invokefailure:failure errorCode:RCHSDKErrorCodeInvalidArguments message:@"Invalid input. You must pass a request dictionary."];
        return NO;
    }

    if (requestDict[kRCHAPIBuilderParamRequestInfo][kRCHAPIBuilderParamRequestInfoPath] == nil) {
        [self invokefailure:failure errorCode:RCHSDKErrorCodeInvalidArguments message:@"Invalid input. The request dictionary must contain a valid value for path (kRCHAPIBuilderParamRequestInfoPath)"];
        return NO;
    }

    return YES;
}

#pragma mark - Request Internal

- (NSURLSessionTask *)GET:(NSString *)path
               parameters:(NSDictionary *)parameters
                  success:(RCHAPIClientSuccess)success
                  failure:(RCHAPIClientFailure)failure
{
    NSMutableDictionary *requestParams = [parameters[kRCHAPIBuilderParamRequestParameters] mutableCopy];
    NSDictionary *requestInfo = parameters[kRCHAPIBuilderParamRequestInfo];
    BOOL signUsingOAuth = requestInfo[kRCHAPIBuilderParamRequestInfoRequiresOAuth] != nil;

    RCHAPIClientUserAndSessionParamStyle userAndSessionStyle = RCHAPIClientUserAndSessionParamStyleLong;
    if (requestInfo[kRCHAPIBuilderParamRequestInfoUserAndSessionStyle] != nil) {
        userAndSessionStyle = [requestInfo[kRCHAPIBuilderParamRequestInfoUserAndSessionStyle] integerValue];
    }

    // Build the URL

    NSURL *URL;
    NSURLRequest *URLRequest = nil;
    if (signUsingOAuth) {
        if ([self.clientConfig.APIClientKey length] > 0 && [self.clientConfig.APIClientSecret length] > 0) {
            URLRequest = [self OAuthURLRequestFromPath:path parameters:requestParams];
            URL = URLRequest.URL;
        }
        else {
            [self invokefailure:failure errorCode:RCHSDKErrorCodeInvalidArguments message:@"Invalid input. Requests that require OAuth must have both APIClientKey and APIClientSecret set."];
            return nil;
        }
    }
    else {
        NSDictionary *signedRequestParams = [self addAuthToParams:requestParams style:userAndSessionStyle];
        URL = [self URLFromPath:path parameters:signedRequestParams];
        if (userAndSessionStyle == RCHAPIClientUserAndSessionParamStyleLongWithAPIKeyInPath ||
            userAndSessionStyle == RCHAPIClientUserAndSessionParamStyleAPIKeyInPath) {
            URL = [URL URLByAppendingPathComponent:self.clientConfig.APIKey];
        }
        URL = [NSURL URLWithString:[URL absoluteString]];
        URLRequest = [NSURLRequest requestWithURL:URL];
    }

    [RCHLog logInfo:@"%s: Executing HTTP request: %@", __PRETTY_FUNCTION__, URLRequest];

    __weak typeof(self) wself = self;
    __block NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            failure(data, error);
        }
        else if ([response isKindOfClass:[NSHTTPURLResponse class]] && [self isErrorResponse:(NSHTTPURLResponse *)response]) {
            NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
            NSString *desc = [NSString stringWithFormat:@"Request for URL: %@ failed with HTTP status code: %d", [URL absoluteString], (int)code];
            [wself invokefailure:failure errorCode:RCHSDKErrorCodeHTTPError message:desc];
        }
        else {
            [wself parseJSONData:data success:success failure:failure];
        }
    }];

    [dataTask resume];

    return dataTask;
}

- (NSDictionary *)addAuthToParams:(NSDictionary *)requestParams style:(RCHAPIClientUserAndSessionParamStyle)style
{
    NSMutableDictionary *newParams = [requestParams mutableCopy];

    switch (style) {
        case RCHAPIClientUserAndSessionParamStyleLong: {
            newParams[kRCHAPICommonParamAPIKey] = self.clientConfig.APIKey;
            newParams[kRCHAPICommonParamAPIClientKey] = self.clientConfig.APIClientKey;

            if (self.clientConfig.userID != nil && self.clientConfig.userID.length > 0) {
                newParams[kRCHAPICommonParamUserID] = self.clientConfig.userID;
            }

            if (self.clientConfig.sessionID != nil && self.clientConfig.sessionID.length > 0) {
                newParams[kRCHAPICommonParamSessionID] = self.clientConfig.sessionID;
            }

            break;
        }
        case RCHAPIClientUserAndSessionParamStyleShort: {
            newParams[kRCHAPICommonParamAPIKey] = self.clientConfig.APIKey;

            if (self.clientConfig.userID != nil && self.clientConfig.userID.length > 0) {
                newParams[kRCHAPICommonParamUserIDShort] = self.clientConfig.userID;
            }

            if (self.clientConfig.sessionID != nil && self.clientConfig.sessionID.length > 0) {
                newParams[kRCHAPICommonParamSessionIDShort] = self.clientConfig.sessionID;
            }

            break;
        }
        case RCHAPIClientUserAndSessionParamStyleLongWithAPIKeyInPath: {
            if (self.clientConfig.userID != nil && self.clientConfig.userID.length > 0) {
                newParams[kRCHAPICommonParamUserID] = self.clientConfig.userID;
            }

            if (self.clientConfig.sessionID != nil && self.clientConfig.sessionID.length > 0) {
                newParams[kRCHAPICommonParamSessionID] = self.clientConfig.sessionID;
            }

            break;
        }
        case RCHAPIClientUserAndSessionParamStyleNone: {
            newParams[kRCHAPICommonParamAPIKey] = self.clientConfig.APIKey;
            break;
        }
        default:
            break;
    }

    return [newParams copy];
}

- (NSURL *)URLFromPath:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSString *URLString = path;

    NSMutableDictionary *newParams = parameters != nil ? [parameters mutableCopy] : [NSMutableDictionary dictionary];

    //!!! A handful of list parameters need to be specified as repeat params, (i.e. foo=1&foo=2&foo=3)
    // If any value is specified as a list, this signifies we need to break out the values into repeats.
    NSMutableString *repeatParamsString = [NSMutableString string];
    NSArray *sortedKeys = [newParams.allKeys sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (id key in sortedKeys) {
        if ([newParams[key] isKindOfClass:[NSArray class]]) {
            for (id value in newParams[key]) {
                if ([value isKindOfClass:[NSString class]]) {
                    RCHQueryStringPair *pair = [[RCHQueryStringPair alloc] initWithField:key value:value];
                    [repeatParamsString appendFormat:@"&%@", [pair URLEncodedStringValueWithEncoding:NSUTF8StringEncoding]];
                }
            }

            // Since we've added the list to the repeatParams string, remove it
            // from the master params list so it doesn't end up in there twice.
            [newParams removeObjectForKey:key];
        }
    }

    NSString *queryString = [RCHWebUtils queryStringFromParameters:newParams withEncoding:NSUTF8StringEncoding];
    if ([repeatParamsString length] > 0) {
        queryString = [queryString stringByAppendingString:repeatParamsString];
    }

    URLString = [URLString stringByAppendingFormat:@"?%@", queryString];

    NSURL *baseURL = ([self isV2Path:path] ? self.clientConfig.baseURLv2 : self.clientConfig.baseURL);
    return [NSURL URLWithString:URLString relativeToURL:baseURL];
}

- (BOOL)isV2Path:(NSString *)path
{
    return [path hasPrefix:kRCHAPIRequestFindSearchPath] || [path hasPrefix:kRCHAPIRequestFindAutocompletePath];
}

- (NSURLRequest *)OAuthURLRequestFromPath:(NSString *)path parameters:(NSDictionary *)parameters
{
    NSMutableString *mutablePath = [path mutableCopy];
    if (![[path substringToIndex:1] isEqual:@"/"]) {
        [mutablePath insertString:@"/" atIndex:0];
    }
    [mutablePath appendFormat:@"/%@", self.clientConfig.APIKey];

    if (self.clientConfig.userID != nil && self.clientConfig.userID.length > 0) {
        [mutablePath appendFormat:@"/%@", self.clientConfig.userID];
    }
    else {
        [mutablePath appendString:@"/*"];
    }

    NSDictionary *newParams = parameters.count > 0 ? parameters : nil;
    NSURLRequest *request = [RCHOAuth URLRequestForPath:mutablePath
                                             parameters:newParams
                                                   host:[[self.clientConfig baseURL] host]
                                            consumerKey:self.clientConfig.APIClientKey
                                         consumerSecret:self.clientConfig.APIClientSecret
                                            accessToken:nil
                                            tokenSecret:nil
                                                 scheme:[self.clientConfig protocolString]
                                          requestMethod:@"GET"
                                           dataEncoding:RCHOAuthContentTypeUrlEncodedForm
                                           headerValues:nil
                                        signatureMethod:RCHOAuthSignatureMethodHmacSha1];

    return request;
}

#pragma mark - Response

- (BOOL)isErrorResponse:(NSHTTPURLResponse *)response
{
    NSInteger codeNum = response.statusCode / 100;
    return codeNum == 4 || codeNum == 5;
}

- (void)invokefailure:(RCHAPIClientFailure)failure errorCode:(RCHSDKErrorCode)code message:(NSString *)message
{
    NSDictionary *userInfo = message != nil ? userInfo = @{NSLocalizedDescriptionKey : message} : nil;
    NSError *error = [NSError errorWithDomain:kRCHSDKErrorDomain code:code userInfo:userInfo];
    failure(nil, error);
}

- (BOOL)assertNotNilSuccess:(RCHAPIClientSuccess)success failure:(RCHAPIClientFailure)failure
{
    BOOL valid = (success != nil && failure != nil);
    if (!valid) {
        [RCHLog logError:@"Invalid block parameters, both success and failure must not be nil."];
    }

    return valid;
}

#pragma mark - JSON

- (void)parseJSONData:(NSData *)data
              success:(RCHAPIClientSuccess)success
              failure:(RCHAPIClientFailure)failure
{
    if (data != nil) {
        NSError *error = nil;
        id JSONObj = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error == nil) {
            success(JSONObj);
        }
        else {
            failure(nil, error);
        }
    }
    else {
        success(nil);
    }
}

#pragma mark - URL Tracking

- (void)configureReachability
{
    if (self.reachability == nil) {
        [RCHLog logDebug:@"Configuring reachability for API Client click tracking retry."];

        self.reachability = [RCHNetworkReachabilityManager managerForDomain:[[self.clientConfig baseURL] host]];
        [self.reachability startMonitoring];

        __weak typeof(self) wself = self;
        [self.reachability setReachabilityStatusChangeBlock:^(RCHNetworkReachabilityStatus status) {
            [RCHLog logDebug:@"%s: Network status change: %d", __PRETTY_FUNCTION__, (int)status];

            if (status == RCHNetworkReachabilityStatusReachableViaWiFi || status == RCHNetworkReachabilityStatusReachableViaWWAN) {
                [wself retryFailedClickTrackURLs];
            }
        }];
    }
}

- (void)trackProductViewWithURL:(NSString *)productClickURL
{
    [RCHLog logInfo:@"Tracking product view for click URL: %@", productClickURL];

    [self configureReachability];

    __weak typeof(self) wself = self;
    [self executeTrackProductViewWithURL:productClickURL success:^(id responseObject) {
    } failure:^(id responseObject, NSError *error) {
        [RCHLog logError:@"%s: Failed to track URL: %@ error: %@. Adding to retry queue.", __PRETTY_FUNCTION__, productClickURL, error];
        [wself.failedClickTrackURLs addObject:productClickURL];
    }];
}

- (void)executeTrackProductViewWithURL:(NSString *)productClickURL success:(RCHAPIClientSuccess)success failure:(RCHAPIClientFailure)failure
{
    if ([productClickURL length] == 0) {
        [RCHLog logError:@"Nil click track URL supplied to %@, aborting.", NSStringFromSelector(_cmd)];
        return;
    }

    __block NSURLSessionDataTask *dataTask = [self.URLSession dataTaskWithURL:[NSURL URLWithString:productClickURL] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            [RCHLog logError:@"Error tracking product view: %@", error];

            if (failure != nil) {
                failure(nil, error);
            }
        }
        else {
            [RCHLog logInfo:@"%s: Successfully tracked product URL: %@", __PRETTY_FUNCTION__, productClickURL];

            if (success != nil) {
                success(nil);
            }
        }
    }];

    dataTask.priority = NSURLSessionTaskPriorityLow;
    [dataTask resume];
}

- (void)retryFailedClickTrackURLs
{
    [RCHLog logInfo:@"Retrying %d failed product views.", (int)self.failedClickTrackURLs.count];

    __weak typeof(self) wself = self;

    for (NSString *URL in self.failedClickTrackURLs) {
        [self executeTrackProductViewWithURL:URL success:^(id responseObject) {
            [wself.failedClickTrackURLs removeObject:URL];
        } failure:^(id responseObject, NSError *error) {
            [RCHLog logError:@"%s: Failed retry track URL: %@ error: %@.", __PRETTY_FUNCTION__, URL, error];
        }];
    }
}

@end
