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
#import "RCHImportable.h"

/**
 *  Automatically map key/value pairs from dictionary to properties
 *  on an object instance. Handles correct type conversion when possible.
 *  
 *  This category is useful when deserializing model objects from webservice
 *  JSON responses, plists, or anything else that can be deserialized into a
 *  dictionary or array.
 *
 *  Automatic mapping will occur between keys and properties that are a case-insensitive
 *  string match, regardless of underscores. For example, a property named "lastName" will
 *  match any of the following keys in a provided dictionary:
 *  
 *  @code 
 *  @"lastName"
 *  @"lastname" 
 *  @"last_name" 
 *  @endcode
 *
 *  Optionally implement @p RCHImportable on the object class to manage
 *  object uniqueness, relationships, and other configuration options.
 *
 *  Inferred mappings are cached for performance when repeatedly importing the
 *  same type of object. If performance is a major concern, you can always implement
 *  the RCHImportable protocol and provide a pre-defined mapping.
 */
@interface NSObject (RCHImport)

/**
 *  Return an instance of the calling class initialized with the values in the dictionary.
 *
 *  If the calling class implements RCHImportable, it is given the opportunity
 *  to return an existing unique instance of the object that is represented by
 *  the dictionary.
 *
 *  @param dict Dictionary from which to create the object instance.
 *
 *  @return An object instance initialized with the values in the dictionary.
 */
+ (instancetype)rch_objectFromDictionary:(NSDictionary *)dict;

/**
 *  Return an instance of the calling class initialized with the values in the dictionary,
 *  with optional extra key/property mappings.
 *
 *  If the calling class implements RCHImportable, it is given the opportunity
 *  to return an existing unique instance of the object that is represented by
 *  the dictionary.
 *
 *  @param dict     Dictionary from which to create the object instance.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RCHImportable.
 *
 *  @return An object instance initialized with the values in the dictionary.
 */
+ (instancetype)rch_objectFromDictionary:(NSDictionary *)dict withMappings:(NSDictionary *)mappings;

/**
 *  Return an array of instances of the calling class initialized with the
 *  values in the dicitonaries in the provided array.
 *
 *  The array parameter should contain only @p NSDictionary instances.
 *
 *  If the calling class implements RCHImportable, it is given the opportunity
 *  to return an existing unique instance of an object that is represented by
 *  each dictionary.
 *
 *  @param array An array of @p NSDictionary instances objects to import.
 *
 *  @return An array of objects initiailized with the respective values in each dictionary in the array.
 */
+ (NSArray *)rch_objectsFromArray:(NSArray *)array;

/**
 *  Return an array of instances of the calling class initialized with the
 *  values in the dicitonaries in the provided array, with optional extra key/property mappings.
 *
 *  The array parameter should contain only @p NSDictionary instances.
 *
 *  If the calling class implements RCHImportable, it is given the opportunity
 *  to return an existing unique instance of an object that is represented by
 *  each dictionary.
 *
 *  @param array    An array of @p NSDictionary instances objects to import.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RCHImportable.
 *
 *  @return An array of objects initiailized with the respective values in each dictionary in the array.
 */
+ (NSArray *)rch_objectsFromArray:(NSArray *)array withMappings:(NSDictionary *)mappings;

/**
 *  Import the values from the provided dictionary into this object.
 *  Uses the implicit key/property mapping and the optional mapping overrides
 *  provided by RCHImportable.
 *
 *  @param dict Dictionary of values to import.
 */
- (void)rch_importValuesFromDict:(NSDictionary *)dict;

/**
 *  Import the values from the provided dictionary into this object with optional extra
 *  key/property mappings.
 *
 *  @param dict     Dictionary of values to import.
 *  @param mappings An optional dictionary of extra mappings from keys to property names to
 *                  use in the import. These will override/supplement implicit mappings and mappings
 *                  provided by @p RCHImportable.
 */
- (void)rch_importValuesFromDict:(NSDictionary *)dict withMappings:(NSDictionary *)mappings;

/*!
 *  Get the normalized property name for the external key.
  */
+ (NSString *)rch_propertyNameForExternalKey:(NSString *)key;

@end
