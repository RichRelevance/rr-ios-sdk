//
//  NSURL+RZIExtensions.m
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

#import "NSURL+RZIExtensions.h"

@implementation NSURL (RZIExtensions)

- (NSDictionary *)rzi_tokenReplacedPathValuesFromPopulatedURL:(NSURL *)populatedURL
{
    NSParameterAssert(populatedURL);
    BOOL lengthMatch = self.pathComponents.count == populatedURL.pathComponents.count;
    if (!lengthMatch) {
        return nil;
    }

    NSMutableDictionary *results = [NSMutableDictionary dictionary];
    for (int i = 0; i < self.pathComponents.count; i++) {
        NSString *templateComponent = self.pathComponents[i];
        NSString *valueComponent = populatedURL.pathComponents[i];
        if ([templateComponent containsString:@":"]) {
            NSString *key = [templateComponent stringByReplacingOccurrencesOfString:@":" withString:@""];
            results[key] = valueComponent;
        }
        else if (![templateComponent isEqualToString:valueComponent]) {
            results = nil;
            break;
        }
    }

    return [results copy];
}

- (NSDictionary *)rzi_tokenReplacedQueryValuesFromPopulatedURL:(NSURL *)populatedURL
{
    __block NSMutableDictionary *results = [NSMutableDictionary dictionary];

    NSDictionary *templateParams = [self rzi_queryParamsAsDictionary];
    NSDictionary *valueParams = [populatedURL rzi_queryParamsAsDictionary];

    [templateParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *populatedVal = valueParams[key];
        if (populatedVal) {
            results[key] = populatedVal;
        }
        else {
            results = nil;
            *stop = YES;
        }
    }];

    return [results copy];
}

- (NSDictionary *)rzi_queryParamsAsDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (self.query) {
        NSArray *queryPairs = [self.query componentsSeparatedByString:@"&"];
        for (NSString *queryPair in queryPairs) {
            NSArray *queryPairArr = [queryPair componentsSeparatedByString:@"="];
            if (queryPairArr.count == 2) {
                result[queryPairArr[0]] = queryPairArr[1];
            }
        }
    }

    return [result copy];
}

@end
