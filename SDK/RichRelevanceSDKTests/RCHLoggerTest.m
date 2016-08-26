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

#import <XCTest/XCTest.h>
#import "RCHLog.h"
#define EXP_SHORTHAND
#import "Expecta.h"
#import "RCHSDK.h"

@interface RCHLog (UnderTest)
- (BOOL)shouldLog:(RCHLogLevel)logLevel;
- (NSString *)prependLevelToFormat:(NSString *)format level:(RCHLogLevel)level;
@end

@interface RCHLoggerTest : XCTestCase

@property (strong, nonnull) RCHLog *log;

@end

@implementation RCHLoggerTest

- (void)setUp
{
    [super setUp];
    self.log = [[RCHLog alloc] init];
    [RCHLog defaultLogger].logLevel = RCHLogLevelOff;
}

- (void)testSDKConfig
{
    RCHLogLevel initialLevel = [RCHLog defaultLogger].logLevel;
    [RCHSDK setLogLevel:RCHLogLevelInfo];
    expect([RCHLog defaultLogger].logLevel).to.equal(RCHLogLevelInfo);
    [RCHLog defaultLogger].logLevel = initialLevel;
}

- (void)testLogToConsole
{
    [RCHLog defaultLogger].logLevel = RCHLogLevelVerbose;
    [RCHLog logError:@"My Error No Format"];
    [RCHLog logError:@"My Error: %@", @"Error!"];
    [RCHLog logWarn:@"My Warn: %@", @"Warn!"];
    [RCHLog logInfo:@"My Info: %@", @"Info!"];
    [RCHLog logDebug:@"My Debug: %@", @"Debug!"];
    [RCHLog logVerbose:@"My Verbose: %@", @"Verbose!"];
    // No Assert, make sure we don't crash.
}

- (void)testLogToConsole_BadArgs
{
    [RCHLog defaultLogger].logLevel = RCHLogLevelVerbose;
    [RCHLog logError:nil];
    [RCHLog logError:@"Format: %@", nil];
}

- (void)testLoggingOff
{
    expect([self.log shouldLog:RCHLogLevelInfo]).to.beFalsy();
}

- (void)testVerifyAllLevelsOnOff
{
    for (int level = RCHLogLevelError; level <= RCHLogLevelVerbose; level++) {
        self.log.logLevel = level;
        expect([self.log shouldLog:level]).to.beTruthy();

        for (int innerLevel = level + 1; innerLevel <= RCHLogLevelVerbose; innerLevel++) {
            expect([self.log shouldLog:level]).to.beFalsy;
        }
    }
}

- (void)testPrependLevelToFormat
{
    expect([self.log prependLevelToFormat:@"Msg" level:RCHLogLevelError]).to.equal(@"RichRelevance [ERROR]: Msg");
    expect([self.log prependLevelToFormat:@"Msg" level:RCHLogLevelWarn]).to.equal(@"RichRelevance [WARN]: Msg");
    expect([self.log prependLevelToFormat:@"Msg" level:RCHLogLevelInfo]).to.equal(@"RichRelevance [INFO]: Msg");
    expect([self.log prependLevelToFormat:@"Msg" level:RCHLogLevelDebug]).to.equal(@"RichRelevance [DEBUG]: Msg");
    expect([self.log prependLevelToFormat:@"Msg" level:RCHLogLevelVerbose]).to.equal(@"RichRelevance [VERBOSE]: Msg");
}

@end
