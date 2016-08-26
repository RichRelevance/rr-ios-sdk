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

@import Foundation;

/**
 *  Optional protocol for model objects to import in order to customize
 *  the behavior of RCHImport.
 */
@protocol RCHImportable <NSObject>

@optional

/**
 *  Implement to provide dictionary of custom mappings from dictionary keys/keypaths to properties.
 *
 *  @note Keypaths are supported in custom mappings for access to values within nested dictionaries.
 *
 *  @return A dictionary containing mappings from dictionary keys/keypaths to property names.
 */
+ (NSDictionary *)rch_customMappings;

/**
 *  Implement to ignore a specific set of keys or keypaths.
 *  When performing an import, these keys will be ignored in the dictionary being imported.
 *
 *  @note To ignore all keypaths in a nested dictionary, return its root key here.
 *
 *  @return An array of NSString objects representing keys to ignore during import.
 */
+ (NSArray *)rch_ignoredKeys;

/**
 *  Implement to provide a list of keys in dictionaries being imported whose values should be imported as nested objects.
 *  These keys should represent nested dictionaries in the dictionary being imported and should have valid mappings to 
 *  properties on this class which are other importable model objects.
 *
 *  @return An array of NSString objects representing keys whose values should be imported as other model objects.
 */
+ (NSArray *)rch_nestedObjectKeys;

/**
 *  Implement to provide a custom date format string for a particular key or keys.
 *  Will only be called if the inferred property is an NSDate type and the dict value is a string.
 *
 *  @param key Unmodified key from the dictionary being imported.
 *
 *  @return A date format to use for importing this key, otherwise nil to use the default (ISO-8601).
 */
+ (NSString *)rch_dateFormatForKey:(NSString *)key;

/**
 *  Implement to return an existing object for the provided dictionary representation. 
 *  Use this method to enforce object uniqueness.
 *
 *  @param dict Dictionary representation of object being imported.
 *
 *  @return An existing object instance represented by the dict, or nil if one does not exist.
 */
+ (id)rch_existingObjectForDict:(NSDictionary *)dict;

/**
 *  Implement to optionally prevent import for particular key/value pairs.
 *  Can be used to validate imported value or override automatic import to perform custom logic.
 *  In order to support custom import logic for certain attributes, his is called by @p RCHImport
 *  prior to mapping the dictionary key to a property name, so the key here may not match a property 
 *  name in this class.
 *
 *  @param value Unmodified value from dictionary being imported
 *  @param key   Unmodified key from dictionary being imported
 *
 *  @return YES if RCHImport should proceed with automatic import for the key/value pair
 *          NO if the key/value pair should not be imported or will be handled within this method.
 */
- (BOOL)rch_shouldImportValue:(id)value forKey:(NSString *)key;

@end
