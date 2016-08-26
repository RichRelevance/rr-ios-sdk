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

#import "NSObject+RCHImport.h"
#import "NSObject+RCHImport_Private.h"
#import <objc/runtime.h>

static NSString *const kRCHImportISO8601DateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";

//
//  Private Utility Macros/Functions
//

#define LOGGING_ENABLED 0

#if LOGGING_ENABLED

#if (DEBUG)
#define RCHILogDebug(msg, ...) NSLog((@"[RCHImport : DEBUG] " msg), ##__VA_ARGS__)
#else
#define RCHILogDebug(...)
#endif

#define RCHILogError(msg, ...) NSLog((@"[RCHImport : ERROR] " msg), ##__VA_ARGS__);

#else

#define RCHILogDebug(...)
#define RCHILogError(...)

#endif

#define RCHINSNullToNil(x) ([x isEqual:[NSNull null]] ? nil : x)

static objc_property_t rch_getProperty(NSString *name, Class class)
{
    objc_property_t property = class_getProperty(class, [name UTF8String]);

    if (property == NULL) {
        // check base classes
        Class baseClass = class_getSuperclass(class);
        while (baseClass != Nil && property == NULL) {
            property = class_getProperty(baseClass, [name UTF8String]);
            baseClass = class_getSuperclass(baseClass);
        }
    }

    return property;
}

static RCHIPropertyInfo *rch_propertyInfoForProperty(NSString *propertyName, Class aClass)
{
    RCHIPropertyInfo *propertyInfo = [[RCHIPropertyInfo alloc] init];

    propertyInfo.propertyName = propertyName;

    objc_property_t property = rch_getProperty(propertyName, aClass);
    if (property == nil) {
        propertyInfo.dataType = RCHImportDataTypeUnknown;
        return propertyInfo;
    }

    char *typeEncoding = nil;
    typeEncoding = property_copyAttributeValue(property, "T");

    if (typeEncoding == NULL) {
        propertyInfo.dataType = RCHImportDataTypeUnknown;
        return propertyInfo;
    }

    switch (typeEncoding[0]) {
        // Object class
        case _C_ID: {
            NSUInteger typeLength = (NSUInteger)strlen(typeEncoding);

            if (typeLength > 3) {
                NSString *typeString = [[NSString stringWithUTF8String:typeEncoding] substringWithRange:NSMakeRange(2, typeLength - 3)];

                Class propertyClass = NSClassFromString(typeString);

                propertyInfo.propertyClass = propertyClass;
                propertyInfo.dataType = rch_dataTypeFromClass(propertyClass);
            }
        } break;

        // Primitive type
        case _C_CHR:
        case _C_UCHR:
        case _C_INT:
        case _C_UINT:
        case _C_SHT:
        case _C_USHT:
        case _C_LNG:
        case _C_ULNG:
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        case _C_FLT:
        case _C_DBL:
        case _C_BOOL:
            propertyInfo.dataType = RCHImportDataTypePrimitive;
            break;

        default:
            break;
    }

    if (typeEncoding) {
        free(typeEncoding), typeEncoding = NULL;
    }

    return propertyInfo;
}

static NSArray *rch_propertyNamesForClass(Class aClass)
{
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList(aClass, &count);

    NSMutableArray *names = [NSMutableArray array];

    for (unsigned int i = 0; i < count; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if (propertyName) {
            [names addObject:propertyName];
        }
    }

    if (properties) {
        free(properties), properties = NULL;
    }

    return names;
}

static SEL rch_setterForProperty(Class aClass, NSString *propertyName)
{
    NSString *setterString = nil;
    objc_property_t property = rch_getProperty(propertyName, aClass);
    if (property) {
        char *setterCString = property_copyAttributeValue(property, "S");

        if (setterCString) {
            setterString = [NSString stringWithUTF8String:setterCString];
            free(setterCString);
        }
        else {
            setterString = [NSString stringWithFormat:@"set%@:", [propertyName stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[[propertyName substringToIndex:1] capitalizedString]]];
        }
    }

    return setterString ? NSSelectorFromString(setterString) : nil;
}

//
//  Private Header Implementations

NSString *rch_normalizedKey(NSString *key)
{
    if (key == nil) {
        return nil;
    }
    return [[key lowercaseString] stringByReplacingOccurrencesOfString:@"_" withString:@""];
}

RCHImportDataType rch_dataTypeFromClass(Class objClass)
{
    if (objClass == Nil) {
        return RCHImportDataTypeUnknown;
    }

    RCHImportDataType type = RCHImportDataTypeOtherObject;

    if ([objClass isSubclassOfClass:[NSString class]]) {
        type = RCHImportDataTypeNSString;
    }
    else if ([objClass isSubclassOfClass:[NSNumber class]]) {
        type = RCHImportDataTypeNSNumber;
    }
    else if ([objClass isSubclassOfClass:[NSDate class]]) {
        type = RCHImportDataTypeNSDate;
    }
    else if ([objClass isSubclassOfClass:[NSArray class]]) {
        type = RCHImportDataTypeNSArray;
    }
    else if ([objClass isSubclassOfClass:[NSDictionary class]]) {
        type = RCHImportDataTypeNSDictionary;
    }
    else if ([objClass isSubclassOfClass:[NSSet class]]) {
        type = RCHImportDataTypeNSSet;
    }

    return type;
}

@implementation RCHIPropertyInfo

// Implementation is empty on purpose - just a simple POD class.

@end

//
//  Category Implementation
//

@implementation NSObject (RCHImport)

#pragma mark - Static

+ (NSSet *)s_rch_ignoredClasses
{
    static NSSet *s_ignoredClasses = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_ignoredClasses = [NSSet setWithArray:@[
            @"NSObject",
            @"NSManagedObject"
        ]];
    });
    return s_ignoredClasses;
}

+ (NSNumberFormatter *)s_rch_numberFormatter
{
    static NSNumberFormatter *s_numberFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_numberFormatter = [[NSNumberFormatter alloc] init];
        s_numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;

        // !!!: The locale is mandated to be US, so JSON API responses will parse correctly regardless of locality.
        //      If other localization is required, custom import blocks must be used.
        s_numberFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    });
    return s_numberFormatter;
}

+ (NSDateFormatter *)s_rch_dateFormatter
{
    static NSDateFormatter *s_dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_dateFormatter = [[NSDateFormatter alloc] init];
        s_dateFormatter.dateFormat = kRCHImportISO8601DateFormat;

        // !!!: The time zone is mandated to be GMT for parsing string dates.
        //      Any timezone offsets should be encoded into the date string or handled on the display level.
        s_dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];

        // !!!: The locale is mandated to be US, so JSON API responses will parse correctly regardless of locality.
        //      If other localization is required, custom import blocks must be used.
        s_dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    });
    return s_dateFormatter;
}

#pragma mark - Public

+ (instancetype)rch_objectFromDictionary:(NSDictionary *)dict
{
    return [self rch_objectFromDictionary:dict withMappings:nil];
}

+ (instancetype)rch_objectFromDictionary:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    NSParameterAssert(dict);

    id object = nil;

    if ([self respondsToSelector:@selector(rch_existingObjectForDict:)]) {
        Class<RCHImportable> thisClass = self;
        object = [thisClass rch_existingObjectForDict:dict];
    }

    if (object == nil) {
        object = [[self alloc] init];
    }

    [object rch_importValuesFromDict:dict withMappings:mappings];

    return object;
}

+ (NSArray *)rch_objectsFromArray:(NSArray *)array
{
    return [self rch_objectsFromArray:array withMappings:nil];
}

+ (NSArray *)rch_objectsFromArray:(NSArray *)array withMappings:(NSDictionary *)mappings
{
    NSParameterAssert(array);

    NSMutableArray *objects = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSAssert([obj isKindOfClass:[NSDictionary class]], @"Array passed to rch_objectsFromArray: must only contain NSDictionary instances");
        if ([obj isKindOfClass:[NSDictionary class]]) {
            id importedObj = [self rch_objectFromDictionary:obj withMappings:mappings];
            if (importedObj) {
                [objects addObject:importedObj];
            }
        }
    }];

    return [NSArray arrayWithArray:objects];
}

- (void)rch_importValuesFromDict:(NSDictionary *)dict
{
    [self rch_importValuesFromDict:dict withMappings:nil];
}

- (void)rch_importValuesFromDict:(NSDictionary *)dict withMappings:(NSDictionary *)mappings
{
    BOOL canOverrideImports = [self respondsToSelector:@selector(rch_shouldImportValue:forKey:)];

    NSSet *ignoredKeys = [[self class] rch_cachedIgnoredKeys];

    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {

        if (canOverrideImports && ![ignoredKeys containsObject:key]) {
            if (![(id<RCHImportable>)self rch_shouldImportValue:value forKey:key]) {
                return;
            }
        }

        [self rch_importValue:value forKey:key withMappings:mappings ignoredKeys:ignoredKeys];
    }];
}

#pragma mark - Private Header

// For runtime locating of property info
+ (RCHIPropertyInfo *)rch_propertyInfoForExternalKey:(NSString *)key withMappings:(NSDictionary *)extraMappings
{
    __block RCHIPropertyInfo *propInfo = nil;
    [self rch_performBlockAtomicallyAndWait:YES block:^{

        // First check overridden mappings
        NSString *propName = [extraMappings objectForKey:key];
        if (propName) {
            propInfo = [self rch_cachedPropertyInfoForPropertyName:propName];
        }
        else {
            NSDictionary *importMappings = [self rch_importMappings];

            // check cache for raw key
            propInfo = [importMappings objectForKey:key];

            // check cache for normalized key
            if (propInfo == nil) {
                propInfo = [importMappings objectForKey:rch_normalizedKey(key)];
            }
        }
    }];

    return propInfo;
}

#pragma mark - Private

- (void)rch_importValue:(id)value forKey:(NSString *)key withMappings:(NSDictionary *)mappings ignoredKeys:(NSSet *)ignoredKeys
{
    if ([ignoredKeys containsObject:key]) {
        return;
    }

    RCHIPropertyInfo *propDescriptor = [[self class] rch_propertyInfoForExternalKey:key withMappings:mappings];

    if (propDescriptor != nil) {
        value = RCHINSNullToNil(value);
        [self rch_setValue:value fromKey:key forPropertyDescriptor:propDescriptor];
    }
    else if ([value isKindOfClass:[NSDictionary class]]) {
        [self rch_importValuesFromNestedDict:value withKeyPathPrefix:key mappings:mappings ignoredKeys:ignoredKeys];
    }
    else {
        [[self class] rch_logUnknownKeyWarningForKey:key];
    }
}

- (void)rch_importValuesFromNestedDict:(NSDictionary *)dict withKeyPathPrefix:(NSString *)keypathPrefix mappings:(NSDictionary *)mappings ignoredKeys:(NSSet *)ignoredKeys
{
    NSParameterAssert(dict);
    NSParameterAssert(keypathPrefix);

    [dict enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
        NSString *keyPath = [NSString stringWithFormat:@"%@.%@", keypathPrefix, key];
        [self rch_importValue:value forKey:keyPath withMappings:mappings ignoredKeys:ignoredKeys];
    }];
}

+ (void)rch_performBlockAtomicallyAndWait:(BOOL)wait block:(void (^)())block
{
    static dispatch_queue_t s_serialQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_serialQueue = dispatch_queue_create("com.rchmport.syncQueue", DISPATCH_QUEUE_SERIAL);
    });

    if (block) {
        if (wait) {
            dispatch_sync(s_serialQueue, block);
        }
        else {
            dispatch_async(s_serialQueue, block);
        }
    }
}

+ (NSSet *)rch_cachedIgnoredKeys
{
    static void *kRCHIIgnoredKeysAssocKey = &kRCHIIgnoredKeysAssocKey;
    __block NSSet *ignoredKeys = nil;
    [self rch_performBlockAtomicallyAndWait:YES block:^{
        ignoredKeys = objc_getAssociatedObject(self, kRCHIIgnoredKeysAssocKey);
        if (ignoredKeys == nil) {
            if ([self respondsToSelector:@selector(rch_ignoredKeys)]) {
                Class<RCHImportable> thisClass = self;
                ignoredKeys = [NSSet setWithArray:[thisClass rch_ignoredKeys]];
            }
            else {
                // !!!: empty set so cache does not fault again
                ignoredKeys = [NSSet set];
            }
            objc_setAssociatedObject(self, kRCHIIgnoredKeysAssocKey, ignoredKeys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
    return ignoredKeys;
}

+ (NSSet *)rch_cachedNestedKeys
{
    static void *kRCHINestedKeysAssocKey = &kRCHINestedKeysAssocKey;
    __block NSSet *nestedKeys = nil;
    [self rch_performBlockAtomicallyAndWait:YES block:^{
        nestedKeys = objc_getAssociatedObject(self, kRCHINestedKeysAssocKey);
        if (nestedKeys == nil) {
            if ([self respondsToSelector:@selector(rch_nestedObjectKeys)]) {
                Class<RCHImportable> thisClass = self;
                nestedKeys = [NSSet setWithArray:[thisClass rch_nestedObjectKeys]];
            }
            else {
                // !!!: empty set so cache does not fault again
                nestedKeys = [NSSet set];
            }
            objc_setAssociatedObject(self, kRCHINestedKeysAssocKey, nestedKeys, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }];
    return nestedKeys;
}

// !!!: this method is not threadsafe
+ (NSDictionary *)rch_importMappings
{
    static void *kRCHIImportMappingAssocKey = &kRCHIImportMappingAssocKey;
    __block NSDictionary *mapping = objc_getAssociatedObject(self, kRCHIImportMappingAssocKey);

    if (mapping == nil) {
        NSMutableDictionary *mutableMapping = [NSMutableDictionary dictionary];

        // Get mappings from the normalized property names
        [mutableMapping addEntriesFromDictionary:[self rch_normalizedPropertyMappings]];

        // Get any mappings from the RCHImportable protocol
        if ([self respondsToSelector:@selector(rch_customMappings)]) {
            Class<RCHImportable> thisClass = self;
            NSDictionary *customMappings = [thisClass rch_customMappings];

            [customMappings enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *propName, BOOL *stop) {
                RCHIPropertyInfo *propInfo = [self rch_cachedPropertyInfoForPropertyName:propName];
                if (propInfo) {
                    [mutableMapping setObject:propInfo forKey:key];
                }
            }];
        }

        mapping = [NSDictionary dictionaryWithDictionary:mutableMapping];
        objc_setAssociatedObject(self, kRCHIImportMappingAssocKey, mapping, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    return mapping;
}

// !!!: this method is not threadsafe
+ (NSDictionary *)rch_normalizedPropertyMappings
{
    NSMutableDictionary *mappings = [NSMutableDictionary dictionary];

    Class currentClass = self;
    while (currentClass != Nil) {
        NSString *className = NSStringFromClass(currentClass);

        if (![[self s_rch_ignoredClasses] containsObject:className]) {
            NSArray *classPropNames = rch_propertyNamesForClass(currentClass);
            [classPropNames enumerateObjectsUsingBlock:^(NSString *classPropName, NSUInteger idx, BOOL *stop) {
                RCHIPropertyInfo *propInfo = [self rch_cachedPropertyInfoForPropertyName:classPropName];
                if (propInfo != nil) {
                    [mappings setObject:propInfo forKey:rch_normalizedKey(classPropName)];
                }
            }];
        }

        currentClass = class_getSuperclass(currentClass);
    }

    return [NSDictionary dictionaryWithDictionary:mappings];
}

// For cache management
// !!!: this method is not threadsafe
+ (RCHIPropertyInfo *)rch_cachedPropertyInfoForPropertyName:(NSString *)propName
{
    static void *kRCHIClassPropInfoAssocKey = &kRCHIClassPropInfoAssocKey;
    NSMutableDictionary *classPropInfo = objc_getAssociatedObject(self, kRCHIClassPropInfoAssocKey);
    if (classPropInfo == nil) {
        classPropInfo = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, kRCHIClassPropInfoAssocKey, classPropInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }

    RCHIPropertyInfo *propInfo = [classPropInfo objectForKey:propName];
    if (propInfo == nil) {
        propInfo = rch_propertyInfoForProperty(propName, self);
        [classPropInfo setObject:propInfo forKey:propName];
    }

    return propInfo;
}

+ (void)rch_logUnknownKeyWarningForKey:(NSString *)key
{
    [self rch_performBlockAtomicallyAndWait:NO block:^{

        static NSMutableSet *s_cachedUnknownKeySet = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            s_cachedUnknownKeySet = [NSMutableSet set];
        });

        NSString *cacheKeyString = [NSString stringWithFormat:@"%@:%@", NSStringFromClass(self), key];

        if (![s_cachedUnknownKeySet containsObject:cacheKeyString]) {
            [s_cachedUnknownKeySet addObject:cacheKeyString];
            RCHILogDebug(@"No property found in class \"%@\" for key \"%@\". Create a custom mapping to import a value for this key, or add it to the ignored keys to suppress this warning.", NSStringFromClass(self), key);
        }
    }];
}

- (void)rch_setNilForPropertyNamed:(NSString *)propName
{
    SEL setter = rch_setterForProperty([self class], propName);
    if (setter == nil) {
        RCHILogError(@"Setter not available for property named %@", propName);
        return;
    }

    NSMethodSignature *methodSig = [self methodSignatureForSelector:setter];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];

    [invocation setTarget:self];
    [invocation setSelector:setter];

    // The buffer is copied so this is OK even though it will go out of scope
    id nilValue = nil;
    [invocation setArgument:&nilValue atIndex:2];
    [invocation invoke];
}

- (void)rch_setValue:(id)value fromKey:(NSString *)originalKey forPropertyDescriptor:(RCHIPropertyInfo *)propDescriptor
{
    @try {
        if (value == nil) {
            [self rch_setNilForPropertyNamed:propDescriptor.propertyName];
        }
        else {
            id convertedValue = nil;

            if ([value isKindOfClass:[NSNumber class]]) {
                switch (propDescriptor.dataType) {
                    case RCHImportDataTypeNSNumber:
                    case RCHImportDataTypePrimitive:
                        convertedValue = value;
                        break;

                    case RCHImportDataTypeNSString:
                        convertedValue = [value stringValue];
                        break;

                    case RCHImportDataTypeNSDate: {
                        // Assume it's a unix timestamp
                        convertedValue = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];

                        RCHILogDebug(@"Received a number for key [%@] matching property [%@] of class [%@]. Assuming unix timestamp.",
                                     originalKey,
                                     propDescriptor.propertyName,
                                     NSStringFromClass([self class]));
                    } break;

                    default:
                        break;
                }
            }
            else if ([value isKindOfClass:[NSString class]]) {
                switch (propDescriptor.dataType) {
                    case RCHImportDataTypePrimitive:
                    case RCHImportDataTypeNSNumber: {
                        __block NSNumber *number = nil;
                        [[self class] rch_performBlockAtomicallyAndWait:YES block:^{
                            number = [[[self class] s_rch_numberFormatter] numberFromString:value];
                        }];
                        convertedValue = number;
                    } break;

                    case RCHImportDataTypeNSString:
                        convertedValue = value;
                        break;

                    case RCHImportDataTypeNSDate: {
                        // Check for a date format from the object. If not provided, use ISO-8601.
                        __block NSDate *date = nil;
                        [[self class] rch_performBlockAtomicallyAndWait:YES block:^{

                            NSString *dateFormat = nil;
                            NSDateFormatter *dateFormatter = [[self class] s_rch_dateFormatter];

                            if ([[self class] respondsToSelector:@selector(rch_dateFormatForKey:)]) {
                                Class<RCHImportable> thisClass = [self class];
                                dateFormat = [thisClass rch_dateFormatForKey:originalKey];
                            }

                            if (dateFormat == nil) {
                                dateFormat = kRCHImportISO8601DateFormat;
                            }

                            dateFormatter.dateFormat = dateFormat;
                            date = [dateFormatter dateFromString:value];
                        }];
                        convertedValue = date;

                    } break;

                    default:
                        break;
                }
            }
            else if ([value isKindOfClass:[NSDate class]]) {
                // This will not occur in raw JSON deserialization,
                // but the conversion may have already happened in an external method.
                if (propDescriptor.dataType == RCHImportDataTypeNSDate) {
                    convertedValue = value;
                }
            }
            else if ([value isKindOfClass:[NSDictionary class]]) {
                NSSet *nestedKeys = [[self class] rch_cachedNestedKeys];
                if ([nestedKeys containsObject:propDescriptor.propertyName]) {
                    convertedValue = [propDescriptor.propertyClass rch_objectFromDictionary:value];
                }
            }

            if (convertedValue) {
                NSObject *currentValue = [self valueForKey:propDescriptor.propertyName];
                if ([currentValue isEqual:convertedValue] == NO) {
                    [self setValue:convertedValue forKey:propDescriptor.propertyName];
                }
            }
            else {
                RCHILogError(@"Could not convert value of type %@ for key \"%@\" to correct type for property \"%@\" of class %@",
                             NSStringFromClass([value class]),
                             originalKey,
                             propDescriptor.propertyName,
                             NSStringFromClass([self class]));
            }
        }
    }
    @catch (NSException *exception) {
        RCHILogError(@"Could not set value %@ for property %@ of class %@", value, propDescriptor.propertyName, NSStringFromClass([self class]));
    }
}

+ (NSString *)rch_propertyNameForExternalKey:(NSString *)key;
{
    NSString *result = key;
    RCHIPropertyInfo *info = [[self class] rch_propertyInfoForExternalKey:key withMappings:nil];
    if (info != nil) {
        result = info.propertyName;
    }

    return result;
}

@end
