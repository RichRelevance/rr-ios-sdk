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

#import "RCHOAuth.h"
#import <CommonCrypto/CommonHMAC.h>

#define RCHPCEN(s) \
    ((__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[s description], NULL, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8))

#define RCHChomp(s)                                                 \
    {                                                               \
        const NSUInteger length = [s length];                       \
        if (length > 0)                                             \
            [s deleteCharactersInRange:NSMakeRange(length - 1, 1)]; \
    }

#ifndef RCHOAuthURLRequestTimeout
#define RCHOAuthURLRequestTimeout 30.0
#endif

static int RCHOAuthUTCTimeOffset = 0;
/* RCHOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING is defined in the XCode project. */

static NSString *nonce()
{
#ifdef RCHOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING
    return @"static-nonce-for-testing";
#else
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef s = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    return (__bridge_transfer NSString *)s;
#endif
}

static NSString *timestamp()
{
    time_t t;
#ifdef RCHOAUTH_USE_STATIC_VALUES_FOR_AUTOMATIC_TESTING
    t = 1456789012;
#else
    time(&t);
#endif
    mktime(gmtime(&t));
    return [NSString stringWithFormat:@"%ld", t + RCHOAuthUTCTimeOffset];
}

@implementation RCHOAuth {
    NSURL *url;
    NSString *signature_secret;
    RCHOAuthSignatureMethod signature_method;
    NSDictionary *oauthParams; // these are pre-percent encoded
    NSDictionary *params;      // these are pre-percent encoded
    NSString *method;
    NSString *unencodedHostAndPathWithoutQuery; // we keep this because NSURL drops trailing slashes and the port number
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
              accessToken:(NSString *)accessToken
              tokenSecret:(NSString *)tokenSecret
          signatureMethod:(RCHOAuthSignatureMethod)signatureMethod
{
    NSString *smString;
    if (signatureMethod == RCHOAuthSignatureMethodHmacSha256) {
        smString = @"HMAC-SHA256";
    }
    else if (signatureMethod == RCHOAuthSignatureMethodHmacSha1) {
        smString = @"HMAC-SHA1";
    }
    else {
        self = nil;
        return self;
    }
    signature_method = signatureMethod;

    oauthParams = [NSDictionary dictionaryWithObjectsAndKeys:
                                    consumerKey, @"oauth_consumer_key",
                                    nonce(), @"oauth_nonce",
                                    timestamp(), @"oauth_timestamp",
                                    @"1.0", @"oauth_version",
                                    smString, @"oauth_signature_method",
                                    accessToken, @"oauth_token",
                                    // LEAVE accessToken last or you'll break XAuth attempts
                                    nil];
    signature_secret = [NSString stringWithFormat:@"%@&%@", consumerSecret, tokenSecret ?: @""];
    return self;
}

- (NSString *)signature_base
{
    NSMutableDictionary *sigParams = [params mutableCopy];
    [sigParams addEntriesFromDictionary:oauthParams];

    NSMutableString *p3 = [NSMutableString stringWithCapacity:256];
    NSArray *keys = [[sigParams allKeys] sortedArrayUsingSelector:@selector(compare:)];
    for (NSString *key in keys) {
        //[p3 appendString:RCHPCEN(key)];
        [p3 appendString:key];
        [p3 appendString:@"="];
        [p3 appendString:[sigParams[key] description]];
        [p3 appendString:@"&"];
    }
    RCHChomp(p3);

    return [NSString stringWithFormat:@"%@&%@%%3A%%2F%%2F%@&%@",
                                      method,
                                      url.scheme.lowercaseString,
                                      RCHPCEN(unencodedHostAndPathWithoutQuery),
                                      RCHPCEN(p3)];
}

- (NSString *)signature
{
    NSData *sigbase = [[self signature_base] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secret = [signature_secret dataUsingEncoding:NSUTF8StringEncoding];

    NSMutableData *digest;
    NSString *result;
    if (signature_method == RCHOAuthSignatureMethodHmacSha256) {
        digest = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA256, secret.bytes, secret.length, sigbase.bytes, sigbase.length, digest.mutableBytes);
    }
    else { // assume RCHOAuthSignatureMethodHmacSha1
        digest = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA1, secret.bytes, secret.length, sigbase.bytes, sigbase.length, digest.mutableBytes);
    }
    result = [digest base64EncodedStringWithOptions:NSDataBase64Encoding76CharacterLineLength];
    return result;
}

- (NSString *)authorizationHeader
{
    NSMutableString *header = [NSMutableString stringWithCapacity:512];
    [header appendString:@"OAuth "];
    for (NSString *key in oauthParams.allKeys) {
        [header appendString:[key description]];
        [header appendString:@"=\""];
        [header appendString:[oauthParams[key] description]];
        [header appendString:@"\", "];
    }
    [header appendString:@"oauth_signature=\""];
    [header appendString:RCHPCEN(self.signature)];
    [header appendString:@"\""];
    return header;
}

- (NSMutableURLRequest *)requestWithHeaderValues:(NSDictionary *)headerValues
{
    NSMutableURLRequest *rq = [NSMutableURLRequest requestWithURL:url
                                                      cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                  timeoutInterval:RCHOAuthURLRequestTimeout];
    [rq setValue:[self authorizationHeader] forHTTPHeaderField:@"Authorization"];
    [rq setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    if (headerValues) // nil is allowed
    {
        for (NSString *key in headerValues) {
            id value = [headerValues objectForKey:key];
            if ([value isKindOfClass:[NSString class]]) {
                [rq setValue:value forHTTPHeaderField:key];
            }
        }
    }
    [rq setHTTPMethod:method];
    return rq;
}

// unencodedParameters are encoded and assigned to self->params, returns encoded queryString
- (id)setParameters:(NSDictionary *)unencodedParameters
{
    NSMutableString *queryString = [NSMutableString string];
    NSMutableDictionary *encodedParameters = [NSMutableDictionary new];
    for (NSString *key in unencodedParameters.allKeys) {
        NSString *enkey = RCHPCEN(key);
        NSString *envalue = RCHPCEN(unencodedParameters[key]);
        encodedParameters[enkey] = envalue;
        [queryString appendString:enkey];
        [queryString appendString:@"="];
        [queryString appendString:envalue];
        [queryString appendString:@"&"];
    }
    RCHChomp(queryString);
    params = [encodedParameters copy];
    return queryString;
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPathWithoutQuery
                      GETParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret
{
    return [RCHOAuth URLRequestForPath:unencodedPathWithoutQuery
                            parameters:unencodedParameters
                                  host:host
                           consumerKey:consumerKey
                        consumerSecret:consumerSecret
                           accessToken:accessToken
                           tokenSecret:tokenSecret
                                scheme:@"http"
                         requestMethod:@"GET"
                          dataEncoding:RCHOAuthContentTypeUrlEncodedForm
                          headerValues:nil
                       signatureMethod:RCHOAuthSignatureMethodHmacSha1];
}

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
{
    if (!host || !unencodedPathWithoutQuery || !scheme || !method)
        return nil;

    RCHOAuth *oauth = [[RCHOAuth alloc] initWithConsumerKey:consumerKey
                                             consumerSecret:consumerSecret
                                                accessToken:accessToken
                                                tokenSecret:tokenSecret
                                            signatureMethod:signatureMethod];
    if (!oauth) // This would happen with someone slipping in an unsupported signature method
        return nil;

    oauth->method = method;
    oauth->unencodedHostAndPathWithoutQuery = [host.lowercaseString stringByAppendingString:unencodedPathWithoutQuery];

    NSMutableURLRequest *rq;
    if ([method isEqualToString:@"GET"]) {
        // We don't use pcen as we don't want to percent encode eg. /, this is perhaps
        // not the most all encompassing solution, but in practice it seems to work
        // everywhere and means that programmer error is *much* less likely.
        NSString *encodedPathWithoutQuery = [unencodedPathWithoutQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        id path = [oauth setParameters:unencodedParameters];
        if (path) {
            [path insertString:@"?" atIndex:0];
            [path insertString:encodedPathWithoutQuery atIndex:0];
        }
        else {
            path = encodedPathWithoutQuery;
        }

        oauth->url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@",
                                                                              scheme, host, path]];
        rq = [oauth requestWithHeaderValues:headerValues];
    }
    else {
        oauth->url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@://%@%@",
                                                                              scheme, host, unencodedPathWithoutQuery]];
        if ((dataEncoding == RCHOAuthContentTypeUrlEncodedForm) || (unencodedParameters == nil)) {
            NSMutableString *postbody = [oauth setParameters:unencodedParameters];
            rq = [oauth requestWithHeaderValues:headerValues];

            if (postbody.length) {
                [rq setHTTPBody:[postbody dataUsingEncoding:NSUTF8StringEncoding]];
                [rq setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
                [rq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)rq.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
            }
        }
        else if (dataEncoding == RCHOAuthContentTypeJsonObject) {
            NSError *error;
            NSData *postbody = [NSJSONSerialization dataWithJSONObject:unencodedParameters options:0 error:&error];
            if (error || !postbody) {
                NSLog(@"Got an error encoding JSON: %@", error);
            }
            else {
                [oauth setParameters:@{}]; // empty dictionary populates variables without putting data into the signature_base
                rq = [oauth requestWithHeaderValues:headerValues];

                if (postbody.length) {
                    [rq setHTTPBody:postbody];
                    [rq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    [rq setValue:[NSString stringWithFormat:@"%lu", (unsigned long)rq.HTTPBody.length] forHTTPHeaderField:@"Content-Length"];
                }
            }
        }
        else // invalid type
            {
            oauth = nil;
            rq = nil;
        }
    }

    return rq;
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPathWithoutQuery
                      GETParameters:(NSDictionary *)unencodedParameters
                             scheme:(NSString *)scheme
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret;
{
    return [RCHOAuth URLRequestForPath:unencodedPathWithoutQuery
                            parameters:unencodedParameters
                                  host:host
                           consumerKey:consumerKey
                        consumerSecret:consumerSecret
                           accessToken:accessToken
                           tokenSecret:tokenSecret
                                scheme:scheme
                         requestMethod:@"GET"
                          dataEncoding:RCHOAuthContentTypeUrlEncodedForm
                          headerValues:nil
                       signatureMethod:RCHOAuthSignatureMethodHmacSha1];
}

+ (NSURLRequest *)URLRequestForPath:(NSString *)unencodedPath
                     POSTParameters:(NSDictionary *)unencodedParameters
                               host:(NSString *)host
                        consumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                        accessToken:(NSString *)accessToken
                        tokenSecret:(NSString *)tokenSecret
{
    return [RCHOAuth URLRequestForPath:unencodedPath
                            parameters:unencodedParameters
                                  host:host
                           consumerKey:consumerKey
                        consumerSecret:consumerSecret
                           accessToken:accessToken
                           tokenSecret:tokenSecret
                                scheme:@"https"
                         requestMethod:@"POST"
                          dataEncoding:RCHOAuthContentTypeUrlEncodedForm
                          headerValues:nil
                       signatureMethod:RCHOAuthSignatureMethodHmacSha1];
}

+ (int)utcTimeOffset
{
    return RCHOAuthUTCTimeOffset;
}

+ (void)setUtcTimeOffset:(int)offset
{
    RCHOAuthUTCTimeOffset = offset;
}

@end
