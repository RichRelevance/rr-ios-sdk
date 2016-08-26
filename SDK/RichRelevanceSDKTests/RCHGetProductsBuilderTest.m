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
#import "RCHRequestBuilder.h"
#import "RCHGetProductsBuilder.h"
#import "RCHAPIConstants.h"
#import "RCHGetProductsResponseParser.h"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHGetProductsBuilderTest : XCTestCase

@property (strong, nonatomic) RCHGetProductsBuilder *builder;

@end

@implementation RCHGetProductsBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHGetProductsBuilder alloc] init];
}

- (void)testInit
{
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHAPIRequestGetProductsPath);
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoParserClass]).to.equal([RCHGetProductsResponseParser class]);
}

#pragma mark - Parameters

- (void)testSetProductIDs
{
    [self.builder setProductIDs:@[ @"1", @"A", @"B" ]];
    expect(self.builder.requestParams[kRCHAPIRequestParamRecommendationsProductID]).to.equal(@"1|A|B");
}

- (void)testSetCatalogFeedCustomAttributes
{
    NSArray *attributes = @[ @"A", @"B", @3 ];
    expect([self.builder setCatalogFeedCustomAttributes:attributes].requestParams[kRCHAPIRequestParamRecommendationsCatalogFeedCustomAttribute]).to.equal(attributes);
}

@end
