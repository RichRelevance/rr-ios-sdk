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

#import "RCHUserManagementViewController.h"
#import "RCHRootViewController.h"
#import "RCHAPIClientConfig.h"
#import "RCHSDK.h"
#import "RCHStringConstants.h"

@interface RCHUserManagementViewController ()

@property (weak, nonatomic) IBOutlet UITextField *displayNameField;
@property (weak, nonatomic) IBOutlet UITextField *apiKeyField;

@end

@implementation RCHUserManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)saveSelected:(id)sender {
    
    NSString *clientName = self.displayNameField.text;
    NSString *apiKey = self.apiKeyField.text;
    [self.view endEditing:YES];
    
    NSString *currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:kRCHUserDefaultKeyCurrentUser];
    
    // Configure the new API client
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"showcaseparent"
                                                               APIClientKey:apiKey
                                                                   endpoint:RCHEndpointProduction
                                                                   useHTTPS:YES];
    config.APIClientSecret = @"r5j50mlag06593401nd4kt734i";
    config.userID = currentUser;
    config.sessionID = [[NSUUID UUID] UUIDString];
    
    [[RCHSDK defaultClient] configure:config];
    
    // Save the client info locally
    [[NSUserDefaults standardUserDefaults] setObject:clientName forKey:kRCHUserDefaultKeyClientName];
    [[NSUserDefaults standardUserDefaults] setObject:apiKey forKey:kRCHUserDefaultKeyApiKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Success", nil) message:NSLocalizedString(@"Client Saved", nil) preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault
                                                          handler:nil];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
