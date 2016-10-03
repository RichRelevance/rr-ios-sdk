//
//  RCHSearchFacet.m
//  RichRelevanceSDK
//
//  Created by Brian King on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

#import "RCHSearchFacet.h"

@implementation RCHSearchFacet

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"value"] && [value isKindOfClass:[NSString class]]) {
        self.title = value;
        return NO;
    }
    return YES;
}

@end
