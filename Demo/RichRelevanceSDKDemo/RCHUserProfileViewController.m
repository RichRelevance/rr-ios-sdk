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

#import "RCHUserProfileViewController.h"
#import "SVProgressHUD.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "UIViewController+RCHExtensions.h"

@interface RCHUserProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstEventLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewdItemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *ordersLabel;

@end

@implementation RCHUserProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.hidden = YES;
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)loadData
{
    RCHUserProfileBuilder *builder = [RCHSDK builderForUserProfileFieldType:RCHUserProfileFieldTypeAll];

    [SVProgressHUD show];

    [[RCHSDK defaultClient] sendRequest:[builder build] success:^(id responseObject) {

        RCHUserProfileResult *result = responseObject;

        self.userIDLabel.text = result.userID;

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateComponentsFormatterUnitsStyleShort;
        formatter.timeStyle = NSDateComponentsFormatterUnitsStyleShort;
        self.firstEventLabel.text = [formatter stringFromDate:result.timeOfFirstEvent];

        NSInteger numViewd = result.viewedItems != nil ? result.viewedItems.count : 0;
        self.viewdItemsLabel.text = [NSString stringWithFormat:@"%d items", (int)numViewd];

        NSInteger numOrders = result.viewedItems != nil ? result.orders.count : 0;
        self.ordersLabel.text = [NSString stringWithFormat:@"%d orders", (int)numOrders];

        [SVProgressHUD dismiss];
        self.tableView.hidden = NO;
    } failure:^(id responseObject, NSError *error) {
        [SVProgressHUD dismiss];
        [self rch_showAlertForError:error];
    }];
}

@end
