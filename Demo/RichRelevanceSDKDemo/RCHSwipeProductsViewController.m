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

#import "RCHSwipeProductsViewController.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "SVProgressHUD.h"
#import "UIViewController+RCHExtensions.h"
#import "ZLSwipeableView.h"
#import "RCHProductCard.h"
#import "RCHAppearance.h"
#import "RCHSwipePrefsViewController.h"

@interface RCHSwipeProductsViewController () <ZLSwipeableViewDataSource, ZLSwipeableViewDelegate>

@property (weak, nonatomic) IBOutlet ZLSwipeableView *swipeableView;
@property (weak, nonatomic) IBOutlet UIImageView *emptyStateImageView;
@property (strong, nonatomic) NSMutableArray *products;

@end

@implementation RCHSwipeProductsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self styleViews];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

#pragma mark - Style Views

- (void)styleViews
{
    self.view.backgroundColor = [UIColor rch_lightBackgroundColor];
    self.swipeableView.backgroundColor = [UIColor clearColor];

    for (UIView *v in self.view.subviews) {
        v.tintColor = nil;
    }

    self.view.tintColor = [UIColor rch_redColor];

    self.emptyStateImageView.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
}

#pragma mark - Data

- (void)loadData
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeAddToCart name:@"prod1"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithPlacement:placement];

    [SVProgressHUD show];

    __weak typeof(self) wself = self;
    [[RCHSDK defaultClient] sendRequest:[builder build] success:^(id responseObject) {

        RCHPlacementsResult *result = responseObject;
        RCHRecommendedPlacement *placement = result.placements[0];

        wself.products = [placement.recommendedProducts mutableCopy];

        [SVProgressHUD dismiss];

        [wself.swipeableView discardAllSwipeableViews];
        [wself.swipeableView loadNextSwipeableViewsIfNeeded];
    } failure:^(id responseObject, NSError *error) {
        [SVProgressHUD dismiss];
        [wself rch_showAlertForError:error];
    }];
}

#pragma mark - Swipable View

- (UIView *)nextViewForSwipeableView:(ZLSwipeableView *)swipeableView
{
    if (self.products.count > 0) {
        RCHRecommendedProduct *product = self.products[0];
        [self.products removeObjectAtIndex:0];

        RCHProductCard *cardView = [RCHProductCard loadFromNib];
        [cardView setProduct:product];
        return cardView;
    }

    return nil;
}

- (void)swipeableView:(ZLSwipeableView *)swipeableView
         didSwipeView:(UIView *)view
          inDirection:(ZLSwipeableViewDirection)direction
{
    RCHUserPrefActionType type = RCHUserPrefActionTypeNotSet;
    if (direction == ZLSwipeableViewDirectionLeft) {
        type = RCHUserPrefActionTypeDislike;
    }
    else if (direction == ZLSwipeableViewDirectionRight) {
        type = RCHUserPrefActionTypeLike;
    }
    else {
        return;
    }

    if ([view isKindOfClass:[RCHProductCard class]]) {
        RCHProductCard *cardView = (RCHProductCard *)view;

        RCHUserPrefBuilder *builder = [RCHSDK builderForTrackingPreferences:@[ cardView.product.productID ]
                                                                 targetType:RCHUserPrefFieldTypeProduct
                                                                 actionType:type];
        [[RCHSDK defaultClient] sendRequest:[builder build]];
    }
}

#pragma mark - Actions

- (IBAction)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)userPrefsTapped:(id)sender
{
    RCHSwipePrefsViewController *prefsVC = [[RCHSwipePrefsViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:prefsVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)refreshTapped:(id)sender
{
    [self loadData];
}

- (IBAction)swipeLeftTapped:(id)sender
{
    [self.swipeableView swipeTopViewToLeft];
}

- (IBAction)swipeRightTapped:(id)sender
{
    [self.swipeableView swipeTopViewToRight];
}

@end
