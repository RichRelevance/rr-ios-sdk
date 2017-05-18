//
//  RCHSearchProduct.h
//  RichRelevanceSDK
//
//  Created by Brian King on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHSearchProduct : NSObject

@property (copy, nonatomic, nullable) NSString *productID;
@property (copy, nonatomic, nullable) NSString *name;
@property (copy, nonatomic, nullable) NSString *linkID;
@property (copy, nonatomic, nullable) NSString *brand;

@property (copy, nonatomic, nullable) NSNumber *salePriceCents;
@property (copy, nonatomic, nullable) NSNumber *priceCents;

@property (copy, nonatomic, nullable) NSString *clickURL;
@property (copy, nonatomic, nullable) NSString *imageURL;

@end
