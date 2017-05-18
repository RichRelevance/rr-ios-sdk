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

#import "RCHSDK.h"
#import "RCHLog.h"
#import "RCHAPIClient.h"
#import "RCHPlacementRecsBuilder.h"
#import "RCHStrategyRecsBuilder.h"
#import "RCHUserProfileBuilder.h"
#import "RCHUserPrefBuilder.h"
#import "RCHPersonalizeBuilder.h"
#import "RCHGetProductsBuilder.h"
#import "RCHAutocompleteBuilder.h"
#import "RCHSearchBuilder.h"

@interface RCHSDK ()

@end

@implementation RCHSDK

#pragma mark - Logging

+ (void)setLogLevel:(RCHLogLevel)logLevel
{
    [RCHLog defaultLogger].logLevel = logLevel;
}

#pragma mark - API Client

+ (RCHAPIClient *)defaultClient
{
    static RCHAPIClient *defaultClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultClient = [[RCHAPIClient alloc] init];
    });

    return defaultClient;
}

#pragma mark - Fetching

+ (RCHStrategyRecsBuilder *)builderForRecsWithStrategy:(RCHStrategy)strategy
{
    RCHStrategyRecsBuilder *builder = [[RCHStrategyRecsBuilder alloc] init];
    [builder setStrategy:strategy];

    return builder;
}

+ (RCHPlacementRecsBuilder *)builderForRecsWithCategoryID:(NSString *)categoryID
                                                placement:(RCHRequestPlacement *)placement
{
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder setCategoryID:categoryID];
    [builder addPlacement:placement];

    return builder;
}

+ (RCHPlacementRecsBuilder *)builderForRecsWithSearchTerm:(NSString *)searchTerm
                                                placement:(RCHRequestPlacement *)placement
{
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder setSearchTerm:searchTerm];
    [builder addPlacement:placement];

    return builder;
}

+ (RCHPlacementRecsBuilder *)builderForRecsWithPlacement:(RCHRequestPlacement *)placement
{
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder addPlacement:placement];

    return builder;
}

+ (RCHUserPrefBuilder *)builderForUserPrefFieldType:(RCHUserPrefFieldType)fieldType
{
    RCHUserPrefBuilder *builder = [[RCHUserPrefBuilder alloc] init];
    [builder addFetchPreference:fieldType];

    return builder;
}

+ (RCHUserProfileBuilder *)builderForUserProfileFieldType:(RCHUserProfileFieldType)fieldType
{
    RCHUserProfileBuilder *builder = [[RCHUserProfileBuilder alloc] init];
    [builder addFieldType:fieldType];

    return builder;
}

+ (RCHPersonalizeBuilder *)builderForPersonalizeWithPlacement:(RCHRequestPlacement *)placement
{
    RCHPersonalizeBuilder *builder = [[RCHPersonalizeBuilder alloc] init];
    [builder addPlacement:placement];

    return builder;
}

+ (RCHGetProductsBuilder *)builderForGetProducts:(NSArray *)productIDs
{
    RCHGetProductsBuilder *builder = [[RCHGetProductsBuilder alloc] init];
    [builder setProductIDs:productIDs];

    return builder;
}

#pragma mark - Tracking

+ (RCHPlacementRecsBuilder *)builderForTrackingProductViewWithPlacement:(RCHRequestPlacement *)placement
                                                              productID:(NSString *)productID
{
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder addPlacement:placement];
    if (productID != nil) {
        [builder setProductIDs:@[ productID ]];
    }

    return builder;
}


+ (RCHPlacementRecsBuilder *)builderForTrackingProductViewWithProductID:(NSString *)productID
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithListeningPageType:RCHPlacementPageTypeItem];
    return [self builderForTrackingProductViewWithPlacement:placement productID:productID];
}

+ (RCHPlacementRecsBuilder *)builderForTrackingPurchaseWithPlacement:(RCHRequestPlacement *)placement
                                                             orderID:(NSString *)orderID
                                                             product:(RCHRequestProduct *)product
{
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder addPlacement:placement];
    [builder setOrderID:orderID];
    [builder addPurchasedProduct:product];
    
    return builder;
}

+ (RCHPlacementRecsBuilder *)builderForTrackingPurchaseWithOrderID:(NSString *)orderID product:(RCHRequestProduct *)product
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithListeningPageType:RCHPlacementPageTypePurchaseComplete];
    return [self builderForTrackingPurchaseWithPlacement:placement orderID:orderID product:product];
}

+ (RCHPlacementRecsBuilder *)builderForTrackingCategoryViewWithCategoryID:(NSString *)categoryID
{
    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithListeningPageType:RCHPlacementPageTypeCategory];
    RCHPlacementRecsBuilder *builder = [[RCHPlacementRecsBuilder alloc] init];
    [builder addPlacement:placement];
    [builder setCategoryID:categoryID];
    return builder;
}

+ (RCHUserPrefBuilder *)builderForTrackingPreferences:(NSArray *)preferences
                                           targetType:(RCHUserPrefFieldType)targetType
                                           actionType:(RCHUserPrefActionType)actionType
{
    RCHUserPrefBuilder *builder = [[RCHUserPrefBuilder alloc] init];
    [builder setPreferences:preferences];
    [builder setTargetType:targetType];
    [builder setActionType:actionType];

    return builder;
}

+ (RCHAutocompleteBuilder *)builderForAutocompleteWithQuery:(NSString *)query
{
    RCHAutocompleteBuilder *builder = [[RCHAutocompleteBuilder alloc] init];
    [builder setLocale:self.defaultClient.clientConfig.locale];
    [builder setQuery:query];

    return builder;
}

+ (RCHSearchBuilder *)builderForSearchPlacement:(RCHRequestPlacement *)placement withQuery:(NSString *)query
{
    RCHSearchBuilder *builder = [[RCHSearchBuilder alloc] init];
    [builder setLocale:self.defaultClient.clientConfig.locale];
    [builder setChannel:self.defaultClient.clientConfig.channel];
    [builder setPlacement:placement];
    [builder setQuery:query];

    return builder;
}

@end
