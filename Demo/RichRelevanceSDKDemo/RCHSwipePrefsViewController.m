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

#import "RCHSwipePrefsViewController.h"
#import "RCHAppearance.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "SVProgressHUD.h"
#import "UIViewController+RCHExtensions.h"
#import "RCHProductCell.h"

@interface RCHSwipePrefsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *emptyStateImageView;

@property (strong, nonatomic) RCHUserPreference *productsPref;
@property (strong, nonatomic) NSMutableDictionary *productsMap;

@end

@implementation RCHSwipePrefsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.productsMap = [NSMutableDictionary dictionary];

    self.navigationItem.title = NSLocalizedString(@"User Preferences", nil);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelTapped:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"trash"] style:UIBarButtonItemStylePlain target:self action:@selector(resetPrefsTapped:)];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RCHProductCell class]) bundle:nil] forCellReuseIdentifier:[RCHProductCell cellID]];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64.0;

    for (UIView *v in self.view.subviews) {
        v.tintColor = nil;
    }

    self.view.tintColor = [UIColor rch_redColor];
    self.emptyStateImageView.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];

    [self setEmptyStateVisible:YES animated:NO];

    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)cancelTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadData
{
    RCHUserPrefBuilder *builder = [RCHSDK builderForUserPrefFieldType:RCHUserPrefFieldTypeProduct];

    [SVProgressHUD show];

    [[RCHSDK defaultClient] sendRequest:[builder build] success:^(id responseObject) {

        RCHUserPrefResult *result = responseObject;
        self.productsPref = result.product;

        NSMutableArray *productIDs = [self.productsPref.like mutableCopy];
        [productIDs addObjectsFromArray:self.productsPref.dislike];

        if (productIDs == nil || productIDs.count == 0) {
            [self.tableView reloadData];
            [self updateEmptyState];
            [SVProgressHUD dismiss];
            return;
        }

        RCHGetProductsBuilder *productsBuilder = [RCHSDK builderForGetProducts:productIDs];

        [[RCHSDK defaultClient] sendRequest:[productsBuilder build] success:^(id responseObject) {
            RCHGetProductsResult *productsResult = responseObject;
            for (RCHRecommendedProduct *product in productsResult.products) {
                self.productsMap[product.productID] = product;
            }

            [self.tableView reloadData];

            [self updateEmptyState];

            [SVProgressHUD dismiss];
        } failure:^(id responseObject, NSError *error) {
            [SVProgressHUD dismiss];
            [self rch_showAlertForError:error];
        }];
    } failure:^(id responseObject, NSError *error) {
        [SVProgressHUD dismiss];
        [self rch_showAlertForError:error];
    }];
}

#pragma mark - Empty State

- (void)updateEmptyState
{
    BOOL hasItems = [self dataList].count > 0;
    [self setEmptyStateVisible:!hasItems animated:YES];
}

- (void)setEmptyStateVisible:(BOOL)visible animated:(BOOL)animated
{
    NSTimeInterval duration = animated ? 0.25 : 0.0;
    CGFloat alpha = visible ? 0.0f : 1.0f;
    [UIView animateWithDuration:duration animations:^{
        self.tableView.alpha = alpha;
    }];
}

#pragma mark - TableView

- (NSArray *)dataList
{
    NSArray *list = nil;

    if (self.productsPref != nil) {
        list = self.segmentedControl.selectedSegmentIndex == 0 ? self.productsPref.like : self.productsPref.dislike;
    }

    if (list == nil) {
        list = @[];
    }

    return list;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self dataList].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHProductCell *cell = (RCHProductCell *)[tableView dequeueReusableCellWithIdentifier:[RCHProductCell cellID]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSString *pref = [self dataList][indexPath.row];
    RCHRecommendedProduct *product = self.productsMap[pref];
    if (product != nil) {
        [cell setProduct:product];
    }

    return cell;
}

#pragma mark - Actions

- (IBAction)segmentChanged:(id)sender
{
    [self.tableView reloadData];
    [self updateEmptyState];
}

- (void)resetPrefsTapped:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Reset Preferences", nil) message:NSLocalizedString(@"Are you sure you'd like to reset all user preferences?", nil) preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Reset Preferences", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
               [SVProgressHUD show];

               RCHUserPrefBuilder *builder = [RCHSDK builderForTrackingPreferences:[self.productsMap allKeys]
                                                                        targetType:RCHUserPrefFieldTypeProduct
                                                                        actionType:RCHUserPrefActionTypeNeutral];

               [[RCHSDK defaultClient] sendRequest:[builder build] success:^(id responseObject) {

                   [self dismissViewControllerAnimated:YES completion:nil];
               } failure:^(id responseObject, NSError *error) {
                   [SVProgressHUD dismiss];
                   [self rch_showAlertForError:error];
               }];
           }]];

    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

@end
