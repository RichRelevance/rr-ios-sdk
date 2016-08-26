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

#import "RCHUserPrefsViewController.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "RZCollectionList.h"
#import "SVProgressHUD.h"
#import "UIViewController+RCHExtensions.h"

@interface RCHUserPrefsViewController () <RZCollectionListTableViewDataSourceDelegate>

@property (strong, nonatomic) RZCompositeCollectionList *collectionList;
@property (strong, nonatomic) RZCollectionListTableViewDataSource *dataSource;

@end

@implementation RCHUserPrefsViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.navigationItem.title = NSLocalizedString(@"User Prefs (Brand)", nil);
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.collectionList = [[RZCompositeCollectionList alloc] initWithSourceLists:@[]];
    self.dataSource = [[RZCollectionListTableViewDataSource alloc] initWithTableView:self.tableView collectionList:self.collectionList delegate:self];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)loadData
{
    // Create a "recsForPlacements" builder for the "add to cart" placement type.

    RCHUserPrefBuilder *builder = [RCHSDK builderForUserPrefFieldType:RCHUserPrefFieldTypeBrand];

    // Execute the request, process the results, and track a view of the first product returned.

    [SVProgressHUD show];

    [[RCHSDK defaultClient] sendRequest:[builder build] success:^(id responseObject) {

        RCHUserPrefResult *result = responseObject;
        RCHUserPreference *brand = result.brand;

        NSMutableArray *lists = [NSMutableArray array];
        if (brand.like.count > 0) {
            NSArray *sections = @[ [[RZArrayCollectionListSectionInfo alloc] initWithName:NSLocalizedString(@"Likes", nil) sectionIndexTitle:NSLocalizedString(@"Likes", nil) numberOfObjects:brand.like.count] ];
            [lists addObject:[[RZArrayCollectionList alloc] initWithArray:brand.like sections:sections]];
        }

        if (brand.dislike.count > 0) {
            NSArray *sections = @[ [[RZArrayCollectionListSectionInfo alloc] initWithName:NSLocalizedString(@"Dislikes", nil) sectionIndexTitle:NSLocalizedString(@"Dislikes", nil) numberOfObjects:brand.like.count] ];
            [lists addObject:[[RZArrayCollectionList alloc] initWithArray:brand.dislike sections:sections]];
        }

        if (brand.neutral.count > 0) {
            NSArray *sections = @[ [[RZArrayCollectionListSectionInfo alloc] initWithName:NSLocalizedString(@"Neutral", nil) sectionIndexTitle:NSLocalizedString(@"Neutral", nil) numberOfObjects:brand.like.count] ];
            [lists addObject:[[RZArrayCollectionList alloc] initWithArray:brand.neutral sections:sections]];
        }

        if (brand.notForRecs.count > 0) {
            NSArray *sections = @[ [[RZArrayCollectionListSectionInfo alloc] initWithName:NSLocalizedString(@"Not for Recs", nil) sectionIndexTitle:NSLocalizedString(@"Not for Recs", nil) numberOfObjects:brand.like.count] ];
            [lists addObject:[[RZArrayCollectionList alloc] initWithArray:brand.notForRecs sections:sections]];
        }

        self.collectionList = [[RZCompositeCollectionList alloc] initWithSourceLists:lists];
        self.dataSource = [[RZCollectionListTableViewDataSource alloc] initWithTableView:self.tableView collectionList:self.collectionList delegate:self];

        [self.tableView reloadData];

        [SVProgressHUD dismiss];
    } failure:^(id responseObject, NSError *error) {
        [SVProgressHUD dismiss];
        [self rch_showAlertForError:error];
    }];
}

#pragma mark - TableView

- (UITableViewCell *)tableView:(UITableView *)tableView cellForObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    cell.textLabel.text = object;
    return cell;
}

@end
