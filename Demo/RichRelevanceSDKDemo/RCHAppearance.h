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
@import UIKit;

@interface UIColor (Ext)

+ (UIColor *)rch_redColor;
+ (UIColor *)rch_darkBackgroundColor;
+ (UIColor *)rch_lightBackgroundColor;
+ (UIColor *)rch_primaryTextColor;
+ (UIColor *)rch_secondaryTextColor;

@end

@interface UIFont (Ext)

+ (UIFont *)rch_regularFontWithSize:(CGFloat)size;
+ (UIFont *)rch_mediumFontWithSize:(CGFloat)size;
+ (UIFont *)rch_lightFontWithSize:(CGFloat)size;
+ (UIFont *)rch_thinFontWithSize:(CGFloat)size;
+ (UIFont *)rch_condensedFontWithSize:(CGFloat)size;

@end

@interface RCHAppearance : NSObject

+ (void)configureAppearance;

@end
