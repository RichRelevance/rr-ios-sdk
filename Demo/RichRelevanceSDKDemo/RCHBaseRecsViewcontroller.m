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

#import "RCHBaseRecsViewcontroller.h"
#import "RCHProductCell.h"
#import "SVProgressHUD.h"
#import "UIViewController+RCHExtensions.h"
#import "RCHRecommendedProductViewController.h"

@implementation RCHBaseRecsViewcontroller

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([RCHProductCell class]) bundle:nil] forCellReuseIdentifier:[RCHProductCell cellID]];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 64.0;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.products = @[];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)loadData
{
}

#pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHProductCell *cell = (RCHProductCell *)[tableView dequeueReusableCellWithIdentifier:[RCHProductCell cellID]];
    RCHRecommendedProduct *product = self.products[indexPath.row];
    [cell setProduct:product];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RCHRecommendedProduct *product = self.products[indexPath.row];
    RCHRecommendedProductViewController *detailVC = [[RCHRecommendedProductViewController alloc] initWithProduct:product];
    [self.navigationController pushViewController:detailVC animated:YES];
}

@end
