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

#import "RCHAPIResult.h"
#import "RCHCOmmonINcludes.h"
@class RCHRecommendedProduct;

@interface RCHStrategyResult : RCHAPIResult

@property (copy, nonatomic, nullable) NSString *requestID;
@property (copy, nonatomic, nullable) NSString *message;
@property (copy, nonatomic, nullable) NSString *errormessage;
@property (assign, nonatomic) RCHStrategy strategyName;
@property (copy, nonatomic, nullable) NSArray<RCHRecommendedProduct *> *recommendedProducts;

@end
