//
//  NSURL+RZIExtensions.h
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

/**
 *  A set of utilities for obtaining parameter values from tokenized URL paths and query strings.
 */
@interface NSURL (RZIExtensions)

/**
 *  Returns a dictionary containing key-value pairs that represent token replaced path parameters. It is assumed that sender is a templated URL or path like: /users/:id/widgets.
 *
 *  @param populatedURL A URL containing actual path values to be applied to sender.
 *
 *  @return A dictionary with token replaced key-value pairs. If nil, the passed in URL does not match sender and cannot be processed.
 */
- (NSDictionary *)rzi_tokenReplacedPathValuesFromPopulatedURL:(NSURL *)populatedURL;

/**
 *  Returns a dictionary containing key-value pairs that represent token replaced query parameters. It is assumed that sender is a templated URL or path like: /widgets?sort=:sort
 *
 *  @param populatedURL A URL containing actual query parameter values to be applied to sender.
 *
 *  @return A dictionary with token replaced key-value pairs. If nil, the passed in URL does not match sender and cannot be processed.
 */
- (NSDictionary *)rzi_tokenReplacedQueryValuesFromPopulatedURL:(NSURL *)populatedURL;

/**
 *  Produces a dictionary of sender's query parameters.
 *
 *  @return A dictionary of query parameters as key-value pairs.
 */
- (NSDictionary *)rzi_queryParamsAsDictionary;

@end
