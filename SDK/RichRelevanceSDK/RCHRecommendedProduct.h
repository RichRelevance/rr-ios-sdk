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

@class RCHRange;

@interface RCHRecommendedProduct : NSObject <RCHImportable>

@property (copy, nonatomic) NSString *productID;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *brand;
@property (copy, nonatomic) NSString *genre;
@property (copy, nonatomic) NSString *clickURL;
@property (copy, nonatomic) NSString *imageURL;
@property (copy, nonatomic) NSNumber *salePriceCents;
@property (copy, nonatomic) NSNumber *rating;
@property (copy, nonatomic) NSNumber *numReviews;
@property (copy, nonatomic) NSString *regionPriceDescription;
@property (copy, nonatomic) NSString *regionalProductSku;
@property (copy, nonatomic) NSNumber *priceCents;
@property (assign, nonatomic) BOOL isRecommendable;
@property (strong, nonatomic) RCHRange *priceRangeCents;
@property (strong, nonatomic) RCHRange *salePriceRangeCents;

@property (copy, nonatomic) NSDictionary *attributes;
@property (copy, nonatomic) NSArray *categoryIDs;
@property (copy, nonatomic) NSArray *categories;

/*!
 *  Track a view of this product using the default API client.
 */
- (void)trackProductView;

@end
