//
//  RCHSearchProduct.m
//  RichRelevanceSDK
//
//  Created by Brian King on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

#import "RCHSearchProduct.h"

@implementation RCHSearchProduct

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"] && [value isKindOfClass:[NSString class]]) {
        self.productID = value;
        return NO;
    }
    else if ([key isEqualToString:@"imageId"] && [value isKindOfClass:[NSString class]]) {
        self.imageURL = value;
        return NO;
    }
    return YES;
}

@end
