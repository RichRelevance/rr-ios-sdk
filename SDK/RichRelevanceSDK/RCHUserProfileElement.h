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
#import "RCHImportable.h"

@interface RCHUserProfileElement : NSObject <RCHImportable>

@property (copy, nonatomic, nullable) NSString *sessionID;
@property (copy, nonatomic, nullable) NSString *channel;
@property (copy, nonatomic, nullable) NSDate *timestamp;

@end

@interface RCHUserProfileElementItem : NSObject <RCHImportable>

@property (copy, nonatomic, nullable) NSString *itemID;
@property (copy, nonatomic, nullable) NSNumber *quantity;
@property (copy, nonatomic, nullable) NSNumber *priceInCents;

@end

#pragma mark - Orders

@interface RCHUserProfileOrder : RCHUserProfileElement

@property (copy, nonatomic, nullable) NSString *orderID;
@property (copy, nonatomic, nullable) NSArray<RCHUserProfileElementItem *> *items;

@end

#pragma mark - Viewed Categories

@interface RCHUserProfileViewedCategory : RCHUserProfileElement

@property (copy, nonatomic, nullable) NSString *categoryID;

@end

#pragma mark - Viewed Brands

@interface RCHUserProfileViewedBrand : RCHUserProfileElement

@property (copy, nonatomic, nullable) NSString *brand;

@end

#pragma mark - Added to Cart Items

@interface RCHUserProfileAddedToCartItem : RCHUserProfileElement

@property (copy, nonatomic) NSArray<RCHUserProfileElementItem *> *items;

@end

#pragma mark - Search Terms

@interface RCHUserProfileSearchTerm : RCHUserProfileElement

@property (copy, nonatomic) NSString *searchTerm;

@end

#pragma mark - Search Terms

@interface RCHUserProfileUserAttributes : RCHUserProfileElement

@property (copy, nonatomic) NSDictionary<NSString *, NSObject *> *values;

@end

#pragma mark - Referrer

@interface RCHUserProfileReferrer : RCHUserProfileElement

@property (copy, nonatomic) NSString *URL;

@end

#pragma mark - User Segments

@interface RCHUserProfileUserSegments : RCHUserProfileElement

@property (copy, nonatomic) NSArray *segments;

@end

#pragma mark - Verb Nounts

@interface RCHUserProfileVerbNoun : RCHUserProfileElement

@property (copy, nonatomic) NSString *verb;
@property (copy, nonatomic) NSString *noun;

@end

#pragma mark - Counted Events

@interface RCHUserProfileCountedEvent : NSObject <RCHImportable>

@property (copy, nonatomic) NSString *value;
@property (copy, nonatomic) NSNumber *count;
@property (copy, nonatomic) NSDate *mostRecentTime;

@end
