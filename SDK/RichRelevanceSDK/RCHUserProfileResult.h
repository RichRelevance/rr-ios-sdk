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

@interface RCHUserProfileResult : RCHAPIResult

@property (copy, nonatomic) NSString *userID;
@property (copy, nonatomic) NSString *mostRecentRRUserGUID;
@property (copy, nonatomic) NSDate *timeOfFirstEvent;

@property (copy, nonatomic) NSArray *viewedItems;
@property (copy, nonatomic) NSArray *clickedItems;
@property (copy, nonatomic) NSArray *referrerURLs;
@property (copy, nonatomic) NSArray *orders;
@property (copy, nonatomic) NSArray *viewedCategories;
@property (copy, nonatomic) NSArray *viewedBrands;
@property (copy, nonatomic) NSArray *addedToCartItems;
@property (copy, nonatomic) NSArray *searchedTerms;
@property (copy, nonatomic) NSArray *userAttributes;
@property (copy, nonatomic) NSArray *userSegments;
@property (copy, nonatomic) NSArray *verbNouns;
@property (copy, nonatomic) NSArray *countedEvents;
@property (copy, nonatomic) NSDictionary *batchAttributes;

@end
