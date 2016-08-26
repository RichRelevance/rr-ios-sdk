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

#import "RCHAppearance.h"
#import "UIColor+RZExtensions.h"
#import "SVProgressHUD.h"

@implementation UIColor (Ext)

+ (UIColor *)rch_redColor
{
    return [UIColor rz_colorFromHexString:@"990101"];
}

+ (UIColor *)rch_darkBackgroundColor
{
    return [UIColor rz_colorFromHexString:@"454545"];
}

+ (UIColor *)rch_lightBackgroundColor
{
    return [UIColor rz_colorFromHexString:@"f7f7f7"];
}

+ (UIColor *)rch_primaryTextColor
{
    return [UIColor rz_colorFromHexString:@"616161"];
}

+ (UIColor *)rch_secondaryTextColor
{
    return [UIColor rz_colorFromHexString:@"aaaaaa"];
}

@end

@implementation UIFont (Ext)

+ (UIFont *)rch_regularFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)rch_mediumFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:size];
}

+ (UIFont *)rch_lightFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
}

+ (UIFont *)rch_thinFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Thin" size:size];
}

+ (UIFont *)rch_condensedFontWithSize:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:size];
}

@end

@implementation RCHAppearance

+ (void)configureAppearance
{
    [UINavigationBar appearance].tintColor = [UIColor rch_redColor];
    [SVProgressHUD setForegroundColor:[UIColor rch_redColor]];
}

@end
