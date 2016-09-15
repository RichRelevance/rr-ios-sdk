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
@class RCHUserProfileElementItem;
@class RCHUserProfileViewedCategory;
@class RCHUserProfileOrder;
@class RCHUserProfileViewedBrand;
@class RCHUserProfileAddedToCartItem;
@class RCHUserProfileSearchTerm;
@class RCHUserProfileUserAttributes;
@class RCHUserProfileReferrer;
@class RCHUserProfileVerbNoun;
@class RCHUserProfileCountedEvent;
@class RCHUserProfileUserSegments;

@interface RCHUserProfileResult : RCHAPIResult

@property (copy, nonatomic, nullable) NSString *userID;
@property (copy, nonatomic, nullable) NSString *mostRecentRRUserGUID;
@property (copy, nonatomic, nullable) NSDate *timeOfFirstEvent;

@property (copy, nonatomic, nullable) NSArray<RCHUserProfileElementItem *> *viewedItems;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileElementItem *> *clickedItems;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileOrder *> *orders;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileViewedCategory *> *viewedCategories;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileViewedBrand *> *viewedBrands;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileAddedToCartItem *> *addedToCartItems;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileSearchTerm *> *searchedTerms;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileUserAttributes *> *userAttributes;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileReferrer *> *referrerURLs;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileVerbNoun *> *verbNouns;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileCountedEvent *> *countedEvents;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileUserSegments *> *userSegments;
@property (copy, nonatomic, nullable) NSDictionary<NSString *, NSObject *> *batchAttributes;

@end
