//
//  RCHUserManagementViewController.m
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 9/28/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

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
