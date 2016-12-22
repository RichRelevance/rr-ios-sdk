# Overview

The Rich Relevance SDK is a native Objective-C interface to the Rich Relevance API v1.0. 

## Installation
The Rich Relevance SDK is available through [CocoaPods](http://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod 'RichRelevanceSDK'
```
## Directory Structure

Below is a brief overview of the directory structure for this project:

 * Demo: A basic project that demonstrates a subset of the SDK's functionality.
 * RichRelevance: The top-level workspace that includes schemes to build both the demo project and packaged SDK.
 * SDK: The SDK project is contained here. 

## Build, Run, Test, & Package
 
The SDK project uses Cocoapods for dependency management, however, at this time, the Pods directory is checked into version control, thus you are not required to run ```pod install``` to get started. Simply open the parent workspace, select the ```BuildAll``` scheme and run. The project uses [appledoc](https://github.com/tomaz/appledoc) to generate documentation. If you'd like to include documentation in a build, install ```appledoc``` using [Homebrew](http://brew.sh):

```sh
brew install appledoc
```

### Schemes

The top-level workspace has several schemes, they are briefly described below:

 * ```RichRelevanceSDK-BuildAll``` Builds both SDK versions and runs the universal SDK packaging steps. Runs unit tests, does not run integration tests that hit the live API.
 * ```RichRelevanceSDKDemo``` Builds and runs the demo app.
 * ```RichRelevanceSDK``` Builds the SDK framework for the currently selected device/simulator and runs both unit and integration tests.
 * ```RichRelevanceSDK-Static``` Builds a static version of the SDK framework for the currently selected device/simulator.
 * ```BuildUniversal``` Builds and packages universal "fat" SDK frameworks, static and dynamic, that can be run against any iOS architecture. 

### Dependencies

As stated, Cocoapods is used for managing dependencies within the SDK subproject. It is of note however, that this project does not produce a pod itself, this would be a recommended future improvement. As such, Cocoapods is only used for managing  testing utilities for the SDK project. 

Also note that the SDK itself includes a handful of third party components that have been namespaced to prevent conflicts with consuming code. These source files retain their original source codelicenses and are all MIT/BSD license. These components are:

 * [AFNetworking](https://github.com/AFNetworking/AFNetworking): Used only for HTTP query parameters and network reachability.
 * [TDOAuth](https://github.com/tweetdeck/TDOAuth): Used for OAuth 1.0 request creation.
 * [RZImport](https://github.com/Raizlabs/RZImport): Used for automatic mapping of API JSON responses to model objects. 

### Packaging

The SDK is configured to produce both static and dynamic frameworks for iOS. The default Xcode framework template builds frameworks for the currently selected architecture only. For this reason, there is a ```BuildUniversal``` aggregate target in the SDK project that invokes a "Run Script" phase that does the following for both the static and dynamic versions of the framework:

 * Builds the framework for both iOS device (arm) and simulator.
 * Uses the ```lipo``` command line tool to produce a "fat" framework containing both slices. 
 * Executes ```appledoc``` against public headers in order to create API documentation.
 * Packages all artifacts into a .zip and places that .zip in the ```build``` directory at the root of the project. 

# Usage Examples

Basic SDK Usage (Objective-C):

```objc
    // First create a configuration and use it to configure the default client.

    RCHAPIClientConfig *config = [[RCHAPIClientConfig alloc] initWithAPIKey:@"showcaseparent"
                                                               APIClientKey:@"bccfa17d092268c0"
                                                                   endpoint:RCHEndpointProduction
                                                                   useHTTPS:NO];
    config.APIClientSecret = @"r5j50mlag06593401nd4kt734i";
    config.userID = @"RZTestUser";
    config.sessionID = [[NSUUID UUID] UUIDString];;
    [[RCHSDK defaultClient] configure:config];

    // Set the log level to debug so we can observe the API traffic

    [RCHSDK setLogLevel:RCHLogLevelDebug];

    // Create a "recsForPlacements" builder for the "add to cart" placement type.

    RCHRequestPlacement *placement = [[RCHRequestPlacement alloc] initWithPageType:RCHPlacementPageTypeAddToCart name:@"prod1"];
    RCHPlacementRecsBuilder *builder = [RCHSDK builderForRecsWithPlacement:placement];

    // Execute the request, process the results, and track a view of the first product returned.

    __block RCHRecommendedProduct *product;
    [[RCHSDK defaultClient] sendRequest:[builder build] success:^(id responseObject) {

        RCHPlacementsResult *result = responseObject;
        RCHPlacement *placement = result.placements[0];
        product = placement.recommendedProducts[0];

        [product trackProductView];
    } failure:^(id responseObject, NSError *error){
        NSLog(@"Error encountered: %@", error);
    }];
```

Search (Swift):

```swift
    func searchForProducts(searchTerm: String, searchFilter: RCHSearchFacet, currentPage: Int) {
        let placement: RCHRequestPlacement = RCHRequestPlacement(pageType: .search, name: "find")
        let searchBuilder: RCHSearchBuilder = RCHSDK.builder(forSearch: placement, withQuery: searchTerm)

        searchBuilder.setPageStart(currentPage * 20)

        searchBuilder.addFilter(from: searchFilter)
        searchBuilder.addSortOrder("product_release_date", ascending: true) // Results will be sorted by product release date.

        RCHSDK.defaultClient().sendRequest(searchBuilder.build(), success: { (responseObject) in
            guard let searchResult = responseObject as? RCHSearchResult else {
                /*
                 Handle error
                 */
                return
            }
            /*
             Handle results
             */
        }) { (responseObject, error) in
            /*
             Handle error
             */
        }
    }

```

Autocomplete (Swift):

```swift
    func autocomplete(withQuery text: String) {
        let autocompleteBuilder: RCHAutocompleteBuilder = RCHSDK.builderForAutocomplete(withQuery: text)

        RCHSDK.defaultClient().sendRequest(autocompleteBuilder.build(), success: { (responseObject) in
            guard let responseAutocompleteSuggestions = responseObject as? [RCHAutocompleteSuggestion] else {
                /*
                 Handle error
                 */
                return
            }
            /*
             Handle suggestions
             */
        }) { (responseObject, error) in
            /*
             Handle error
             */
        }
    }
```

Add to Cart (Swift):

```swift
    @IBAction func addToCartSelected(_ sender: AnyObject) {
        let placement = RCHRequestPlacement(pageType: .addToCart, name: "prod1")
        let builder = RCHSDK.builderForRecs(with: placement)
        builder.addParametersFromLastSearchResult()

        RCHSDK.defaultClient().sendRequest(builder.build(), success: { (result) in
            /*
             Handle success
             */
        }) { (responseObject, error) in
            /*
             Handle error
             */
        }
    }
```

# Architecture

Below is a high-level architecture for the SDK, detailed in some cases at the class-level. 

## SDK Central (RCHSDK)

There is a central SDK class (```RCHSDK```) that is the entrypoint for all SDK interactions. It includes the following functionality:

 * Configure logging
 * Access default API client
 * Request builder factory methods

## Constructing API Requests (Builders)

All API requests are constructed using an implementation of the builder pattern. There are several request builders that provide API endpoint abstractions. The builders are as follow:

 * ```RCHRequestBuilder```: base class for all builders. Includes common functionality as well as the ability to add any arbitrary key/value pairs to a request.  
 * ```RCHPlacementRecsBuilder```: "recsForPlacements" builder
 * ```RCHStrategyRecsBuilder```: "recsUsingStrategy" builder
 * ```RCHUserPrefsBuilder```: "user/preferences" read/write builder
 * ```RCHUserProfileBuilder```: "UserProfile" builder
 * ```RCHPersonalizeBuilder```: Builder for personalize calls
 * ```RCHGetProductsBuilder```: Builder for getProducts calls
 * ```RCHAutocompleteBuilder```: Builder for autocomplete calls
 * ```RCHSearchBuilder```: Builder for search calls


Each builder has type-safe methods for setting relevant values and a “build” method that produces a map of key/value pairs to be sent as the final request. There are also helper methods for common use cases that create pre-configured builders (see next section).

### Builder “Helper” Methods

The ```RCHSDK``` class contains several "factory" methods that vend pre-configured request builders for common API use cases. These methods are separated into two groups, one for fetches and one for tracking. The former includes requests that expect responses such as recommended products, while the latter includes tracking requests that are essentially fire and forget. 

## Networking

The network operations performed by this SDK are, at this time, not diverse enough to warrant inclusion of any third-party libraries such as AFNetworking. All calls are HTTP GET, all payloads are JSON, and there are only a handful of endpoints and paths. In the future, more granular, REST-style API changes might warrant the introduction of such a library. With that said, some sub-components of AFNetworking are used for utility-style tasks such as creating properly encoded query parameters and managing network reachability. 

### Session Configuration

The SDK uses its own instance of NSURLSession to perform all network operations. In this way, the SDK's network traffic is not handled in the same operation queue as the containing app's, allowing for fine-grained session configuration specific only to the SDK traffic.

The session is configured via the ```RCHAPIClientConfig``` class. This class includes all relevant authentication information as well as helper methods for creating pre-configured ```NSURLSession``` configurations.

### API Client

```RCHAPIClient``` is the workhorse class of the SDK. It handles all API interactions at the HTTP-level, consuming request information, asynchronously executing HTTP calls, and responding with parsed domain objects. It is possible to create a standalone instance of this class, but more advisable to use the ```defaultClient``` found on the ```RCHSDK``` class. 

### Requests

API requests originate from request builders (see above) as raw ```NSDictionary``` objects and are passed to one of the ```sendRequest``` variants in ```RCHAPIClient```. 

Each request dictionary contains two sub-dictionaries under ```kRCHAPIBuilderParamRequestParameters```, representing HTTP parameters to be sent directly as part of the request, and ```kRCHAPIBuilderParamRequestInfo```, representing metadata for the request such as path, response parser, and auth. type. 

### Response

A response parser for a given request can be specified via the request info dictionary discussed in the previous section. Parser objects must conform to the ```RCHAPIResponseParser``` protocol and should typically deserialize JSON objects into domain-specific model objects. There are default parsers present for all currently supported API paths. Those parsers are automatically specified by the path-specific builders. 

### Connectivity

In scenarios with low or no network connectivity, the SDK does not queue or retry the majority of failed requests. If no network is present and concretely detectable, requests will not be attempted at all and appropriate errors will be reported to calling code. 

The exception to this rule is for click tracking (product view tracking). Failed click tracking requests are queued in memory only and retried upon network restoration. See the ```trackProductView``` method on ```RCHAPIClient``` for more information.

## Logging

The SDK logs to the console via NSLog and is configurable with the standard log levels (TRACE, DEBUG, INFO, WARN, ERROR, OFF). By default, logging is set to OFF to avoid logging overhead for production releases. All logging logic lives in the ```RCHLog``` class. 

## Error conditions and handling

### Runtime Errors

All SDK calls that make remote requests provide error feedback as part of completion handlers. A best effort has been made to ensure that any SDK thrown exceptions prevent the hosting app from crashing while still maintaining integrity of the SDK. See ```RCHErrors``` for a list of possible error codes. 

### API Response Validation

Despite the fact that the API is stable and well-documented, assumptions are not made about the presence of fields in API responses. Expected fields are validated and calls fail gracefully in the face of unexpected API behavior. 

### Input Validation

All assumptions regarding SDK inputs (arguments passed to SDK methods by the parent app) are validated directly and handled accordingly. If the method consumes an error handler, the handler is invoked with an appropriate error code. Otherwise the operation is aborted and an error is logged. 

## Security

All SDK requests are performed over HTTPS by default and include API authentication parameters to ensure the maximum level of security. In situations where the API supports it, OAuth 1.0 is used to sign requests. The SDK does not store any data to disk, therefore on-disk encryption is not a concern at this time. 

## Testing Strategy

There is a comprehensive set of unit tests that covers all SDK functionality via mocking out the API (web layer). Additionally, there is a small set of happy path integration tests that hit the live API with a set of test credentials. 

## License

The Rich Relevance iOS SDK is available under the Apache 2.0 license. See the LICENSE.txt file for more information. 

