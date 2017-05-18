//
//  RCHSearchLink.m
//  RichRelevanceSDK
//
//  Created by Brian King on 10/3/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

#import "RCHSearchLink.h"

@implementation RCHSearchLink

- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"id"] && [value isKindOfClass:[NSString class]]) {
        self.linkID = value;
        return NO;
    }
    return YES;
}

@end
