# -*- coding: utf-8 -*-
Pod::Spec.new do |s|
s.name         = "RichRelevanceSDK"
s.version      = "1.1.1"
s.summary      = "A native Objective-C interface to the Rich Relevance API."

s.description  = <<-DESC
The Rich Relevance SDK is a native Objective-C interface to the Rich Relevance API featuring:

- Interaction with the Rich Relevance API using native Objective-C objects.
- Construction of API requests using the builder pattern.
- Parsing of API responses.
- Input validation.
DESC

s.homepage     = "https://github.com/RichRelevance/rr-ios-sdk"
s.license      = { :type => 'Apache 2.0', :file => 'LICENSE.txt' }
s.author       = { "Nick Bonatsakis" => "nick.bonatsakis@raizlabs.com", "Chris Ahlering" => "cahlering@richrelevance.com" }
s.platform     = :ios, 8.3
s.source       = { :git => "https://github.com/RichRelevance/rr-ios-sdk.git", :tag => s.version }
s.requires_arc = true

s.source_files = "SDK/RichRelevanceSDK/**/*.{h,m}"
s.public_header_files = "SDK/RichRelevanceSDK/**/*.h"
s.private_header_files = "SDK/RichRelevanceSDK/Private/*.h", "SDK/RichRelevanceSDK/Import/NSObject+RCHImport.h", "SDK/RichRelevanceSDK/Import/Private/*.h"
end
