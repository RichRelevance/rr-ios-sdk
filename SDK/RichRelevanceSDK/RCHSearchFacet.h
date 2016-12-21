//
//  RCHSearchFacet.h
//  RichRelevanceSDK
//
//  Created by Brian King on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCHSearchFacet : NSObject

@property (copy, nonatomic, nullable) NSString *filter;
@property (copy, nonatomic, nullable) NSString *title;
@property (assign, nonatomic) NSUInteger count;

@end
