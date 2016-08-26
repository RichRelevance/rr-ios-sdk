//
//  RZIHost.h
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

@class RZIRoutes;

/**
 Represents an instance of a mocked HTTP host. All registered routes are relative to the host, in this way, multiple hosts for different
 environments can be conditionally created and serve the same set of routes.
 */
@interface RZIHost : NSObject

/**
 *  Create a new host instance with baseURL.
 *
 *  @param baseURL The baseURL for all routes.
 *
 *  @return A new host instance.
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL;

/**
 *  Register this set of routes with sender. Registering routes will activate these routes via OHHTTPStubs.
 *
 *  @param routes Routes to register.
 */
- (void)registerRoutes:(RZIRoutes *)routes;

@end
