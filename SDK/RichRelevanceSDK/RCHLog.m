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

#import "RCHLog.h"

@implementation RCHLog

+ (instancetype)defaultLogger
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[[self class] alloc] init];
    });

    return instance;
}

- (void)logAtLevel:(RCHLogLevel)level format:(NSString *)format args:(va_list)args
{
    if (format != nil && [self shouldLog:_logLevel]) {
        NSLogv([self prependLevelToFormat:format level:level], args);
    }
}

- (BOOL)shouldLog:(RCHLogLevel)level
{
    return (level > RCHLogLevelOff && level <= self.logLevel);
}

- (NSString *)prependLevelToFormat:(NSString *)format level:(RCHLogLevel)level
{
    static NSDictionary *levelToString = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        levelToString = @{
            @(RCHLogLevelError) : @"ERROR",
            @(RCHLogLevelWarn) : @"WARN",
            @(RCHLogLevelInfo) : @"INFO",
            @(RCHLogLevelDebug) : @"DEBUG",
            @(RCHLogLevelVerbose) : @"VERBOSE"
        };
    });

    NSString *levelString = levelToString[@(level)];
    NSMutableString *newFormat = [[NSMutableString alloc] initWithString:@"RichRelevance ["];
    [newFormat appendString:levelString];
    [newFormat appendString:@"]: "];
    [newFormat appendString:format];

    return [newFormat copy];
}

+ (void)logError:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[[self class] defaultLogger] logAtLevel:RCHLogLevelError format:format args:args];
    va_end(args);
}

+ (void)logWarn:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[[self class] defaultLogger] logAtLevel:RCHLogLevelWarn format:format args:args];
    va_end(args);
}

+ (void)logInfo:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[[self class] defaultLogger] logAtLevel:RCHLogLevelInfo format:format args:args];
    va_end(args);
}

+ (void)logDebug:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[[self class] defaultLogger] logAtLevel:RCHLogLevelDebug format:format args:args];
    va_end(args);
}

+ (void)logVerbose:(NSString *)format, ...
{
    va_list args;
    va_start(args, format);
    [[[self class] defaultLogger] logAtLevel:RCHLogLevelVerbose format:format args:args];
    va_end(args);
}

@end
