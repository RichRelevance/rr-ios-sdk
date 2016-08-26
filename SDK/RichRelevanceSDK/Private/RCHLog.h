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

@import Foundation;
#import "RCHLogLevels.h"

@interface RCHLog : NSObject

@property (assign, nonatomic) RCHLogLevel logLevel;

+ (instancetype)defaultLogger;

- (void)logAtLevel:(RCHLogLevel)level format:(NSString *)format args:(va_list)args NS_FORMAT_FUNCTION(2, 0);

+ (void)logError:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (void)logWarn:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (void)logInfo:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (void)logDebug:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);
+ (void)logVerbose:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);

@end
