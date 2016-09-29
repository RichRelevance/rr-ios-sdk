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
#import "RCHAPIConstants.h"

static NSString *const kRCHRequestBuilderTestDefaultPath = @"/defaultPath";

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface RCHRequestBuilder (UnderTest)

@property (strong, nonatomic) NSMutableDictionary *requestParams;
@property (strong, nonatomic) NSMutableDictionary *requestInfo;

@end

@interface RCHRequestBuilderTest : XCTestCase

@property (strong, nonatomic) RCHRequestBuilder *builder;

@end

@implementation RCHRequestBuilderTest

- (void)setUp
{
    [super setUp];
    self.builder = [[RCHRequestBuilder alloc] initWithAPIPath:kRCHRequestBuilderTestDefaultPath];
}

- (void)testInit
{
    expect(self.builder).notTo.beNil();
    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHRequestBuilderTestDefaultPath);
}

- (void)testInit_NoPath
{
    RCHRequestBuilder *builder = [[RCHRequestBuilder alloc] initWithAPIPath:nil];
    expect(builder).to.beNil();
}

- (void)testValueForKey
{
    NSString *key = @"someKey";
    NSString *value = @"someValue";
    self.builder.requestParams[key] = value;

    expect([self.builder valueForKey:key]).to.equal(value);
    expect(([self.builder valueForKey:nil])).to.beNil();
}

- (void)testSetValueForKey
{
    [self.builder setValue:@"value1" forKey:@"key1"];
    expect(self.builder.requestParams[@"key1"]).to.equal(@"value1");

    [self.builder setValue:nil forKey:@"key1"];
    expect(self.builder.requestParams[@"key1"]).to.equal(@"value1");

    [self.builder setValue:@"key2" forKey:nil];
    expect(self.builder.requestParams[@"key2"]).to.beNil();

    [self.builder setValue:nil forKey:nil];
    // don't crash.
}

- (void)testSetAPIPath
{
    NSString *path = @"/recsForPlacements";
    [self.builder setAPIPath:path];

    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(path);

    [self.builder setAPIPath:nil];

    expect(self.builder.requestInfo[kRCHAPIBuilderParamRequestInfoPath]).to.equal(path);
}

- (void)testSetArrayValue
{
    [self.builder setArrayValue:nil forKey:@"key1"];
    expect(self.builder.requestParams[@"key"]).to.beNil();

    [self.builder setArrayValue:@[] forKey:@"key1"];
    expect(self.builder.requestParams[@"key"]).to.beNil();

    [self.builder setArrayValue:@[ @"1", @"2", @3 ] forKey:@"key1"];
    expect(self.builder.requestParams[@"key1"]).to.equal(@"1|2|3");
}

- (void)testBuild
{
    [self.builder setValue:@"value1" forKey:@"key1"];
    [self.builder setValue:@2 forKey:@"key2"];

    NSDictionary *dict = [self.builder build];
    expect(dict).notTo.beNil();
    expect(dict[kRCHAPIBuilderParamRequestInfo][kRCHAPIBuilderParamRequestInfoPath]).to.equal(kRCHRequestBuilderTestDefaultPath);
    expect(dict[kRCHAPIBuilderParamRequestParameters][@"key1"]).to.equal(@"value1");
    expect(dict[kRCHAPIBuilderParamRequestParameters][@"key2"]).to.equal(@2);
}

- (void)testAddValueToArrayForKey
{
    [self.builder addValue:@"value1" toArrayForhKey:@"key1"];
    NSString *arrayString = self.builder.requestParams[@"key1"];

    expect(arrayString).notTo.beNil();
    expect(arrayString).to.equal(@"value1");

    [self.builder addValue:@"value2" toArrayForhKey:@"key1"];
    NSString *arrayString2 = self.builder.requestParams[@"key1"];
    expect(arrayString2).notTo.beNil();
    expect(arrayString2).to.equal(@"value1|value2");
}

- (void)testSetDictionaryValueForKey
{
    [self.builder setDictionaryValue:nil forKey:@"key1" flattenKeys:NO];
    expect(self.builder.requestParams[@"key"]).to.beNil();

    [self.builder setDictionaryValue:@{} forKey:@"key1" flattenKeys:NO];
    expect(self.builder.requestParams[@"key"]).to.beNil();

    NSDictionary *dict = @{
        @"k1" : @"1",
        @"k2" : @2,
        @"k3" : @[ @"A", @"B", @1 ],
        @"k4" : @{@"foo" : @"bar"} // should be ignored.
    };
    [self.builder setDictionaryValue:dict forKey:@"key1" flattenKeys:NO];
    expect(self.builder.requestParams[@"key1"]).to.equal(@"k1:1|k2:2|k3:A;B;1");

    [self.builder setDictionaryValue:dict forKey:@"key1" flattenKeys:YES];
    expect(self.builder.requestParams[@"key1"]).to.equal(@"k1:1|k2:2|k3:A|k3:B|k3:1");
}

@end

#pragma clang diagnostic pop
