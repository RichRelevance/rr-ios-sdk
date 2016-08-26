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

#import "RCHProductCard.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "UIImageView+WebCache.h"
#import "RCHAppearance.h"

@interface RCHProductCard ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UIView *innerView;

@end

@implementation RCHProductCard

+ (instancetype)loadFromNib
{
    NSString *nibName = NSStringFromClass([self class]);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    return [[nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.backgroundColor = [UIColor clearColor];

    self.clipsToBounds = NO;
    self.layer.masksToBounds = NO;
    self.layer.contentsScale = [UIScreen mainScreen].scale;
    self.layer.shouldRasterize = YES;

    CALayer *layer = self.innerView.layer;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.masksToBounds = YES;
    layer.cornerRadius = 6.0f;
    layer.shouldRasterize = YES;

    [self.layer setShadowOffset:CGSizeMake(0.5f, 0.5f)];
    [self.layer setShadowOpacity:0.7];
    [self.layer setShadowRadius:2.0f];

    [self.layer setShadowPath:[[UIBezierPath bezierPathWithRoundedRect:self.innerView.frame
                                                          cornerRadius:6.0f] CGPath]];

    [self.layer setRasterizationScale:[[UIScreen mainScreen] scale]];
    [layer setRasterizationScale:[[UIScreen mainScreen] scale]];

    // Styling

    self.innerView.backgroundColor = [UIColor rch_darkBackgroundColor];
    self.productImageView.backgroundColor = [UIColor whiteColor];

    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.font = [UIFont rch_regularFontWithSize:22.0f];

    self.brandLabel.textColor = [UIColor rch_secondaryTextColor];
    self.brandLabel.font = [UIFont rch_mediumFontWithSize:14.0f];

    self.priceLabel.font = [UIFont rch_condensedFontWithSize:24.0f];
    self.priceLabel.textColor = [UIColor whiteColor];
    self.priceLabel.superview.backgroundColor = [UIColor rch_redColor];
}

- (void)setProduct:(RCHRecommendedProduct *)product;
{
    _product = product;

    self.nameLabel.text = product.name;
    self.brandLabel.text = product.brand;
    [self.productImageView sd_setImageWithURL:[NSURL URLWithString:product.imageURL]];

    float dollars = [product.salePriceCents floatValue] / 100.0;
    NSDecimalNumber *currency = [NSDecimalNumber decimalNumberWithString:[@(dollars) stringValue]];

    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    self.priceLabel.text = [numberFormatter stringFromNumber:currency];
}

@end
