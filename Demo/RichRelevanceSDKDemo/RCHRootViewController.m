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

#import "RCHRootViewController.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "RCHAppearance.h"

@interface RCHRootViewController ()

@end

@implementation RCHRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self styleViews];
}

- (void)styleViews
{
    UIImage *headerImage = [UIImage imageNamed:@"rr-header"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:headerImage];
    self.navigationItem.titleView = imageView;
}

#pragma mark - TableView

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.textColor = [UIColor rch_primaryTextColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cellSelected = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cellSelected.reuseIdentifier  isEqual: @"searchCell"]) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SearchDemo" bundle:nil];
        [self presentViewController:[storyboard instantiateViewControllerWithIdentifier:@"tabBarController"] animated:YES completion:nil];
    }
}

@end
