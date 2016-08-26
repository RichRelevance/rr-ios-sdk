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

/**
 *  Private category methods, enums, and utility classes.
 *  NOT INTENDED FOR PUBLIC USAGE.
 */

@import Foundation;

@class RCHIPropertyInfo;

/**
 *  These are merely the data types the importer can manage.
 *  Unknown data types for matching keys will log an error if automatic conversion
 *  is not possible.
 */
typedef NS_ENUM(NSInteger, RCHImportDataType) {
    RCHImportDataTypeUnknown = -1,
    RCHImportDataTypePrimitive = 0,
    RCHImportDataTypeNSNumber,
    RCHImportDataTypeNSString,
    RCHImportDataTypeNSDate,
    RCHImportDataTypeNSDictionary,
    RCHImportDataTypeNSArray,
    RCHImportDataTypeNSSet,
    RCHImportDataTypeOtherObject
};

/**
 *  Returns the RCHImportDataType based off the class of an object
 *
 *  @param objClass the class that we are requesting the type for
 *
 *  @return the data type.
 */
OBJC_EXTERN RCHImportDataType rch_dataTypeFromClass(Class objClass);

/**
 *  Returns a normalized verison of the key argument
 *  by removing all underscores and making lowercase.
 *
 *  @param key Key to normalize.
 *
 *  @return Normalized key.
 */
OBJC_EXTERN NSString *rch_normalizedKey(NSString *key);

@interface NSObject (RCHImport_Private)

+ (RCHIPropertyInfo *)rch_propertyInfoForExternalKey:(NSString *)key withMappings:(NSDictionary *)extraMappings;
- (void)rch_setNilForPropertyNamed:(NSString *)propName;

@end

// ===============================================
//           Propery Info Class
// ===============================================

@interface RCHIPropertyInfo : NSObject

@property (nonatomic, copy) NSString *propertyName;
@property (nonatomic, assign) RCHImportDataType dataType;
@property (nonatomic, assign) Class propertyClass;

@end
