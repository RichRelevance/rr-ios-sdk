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

#import "AppDelegate.h"
#import "RCHAppearance.h"
#import <RichRelevanceSDK/RichRelevanceSDK.h>
#import "RCHStringConstants.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [RCHAppearance configureAppearance];

    [self configureRRSDK];

    return YES;
}

- (void)configureRRSDK
{
    // Pull saved client or default if none
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:@"199c81c05e473265", kRCHUserDefaultKeyApiKey, nil]];
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys:@"RZTestUser", kRCHUserDefaultKeyCurrentUser, nil]];
    NSString *apiClientKey = [[NSUserDefaults standardUserDefaults] objectForKey:kRCHUserDefaultKeyApiKey];
    
//    [[NSUserDefaults standardUserDefaults] setObject:@"199c81c05e473265" forKey:kRCHUserDefaultKeyApiKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    // Create a configuration and use it to configure the default client.
    
    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"showcaseparent"
                                                               APIClientKey:apiClientKey
                                                                   endpoint:RCHEndpointProduction
                                                                   useHTTPS:YES];
    config.APIClientSecret = @"r5j50mlag06593401nd4kt734i";
    config.userID = @"RZTestUser";
    config.sessionID = [[NSUUID UUID] UUIDString];
    
    [[RCHSDK defaultClient] configure:config];

    // Set the log level to debug so we can observe the API traffic

    [RCHSDK setLogLevel:RCHLogLevelDebug];
}

@end
