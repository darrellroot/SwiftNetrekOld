//
//  LLPersistantSettings.h
//  MacTrek
//
//  Created by Aqua on 20/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

@interface LLPersistantSettings : LLObject {
    NSMutableDictionary *settings;
    NSString *pathToSettings;
}

+ (LLPersistantSettings*) defaultSettings;
- (void)update;
- (void)removeAllObjects;
- (void)removeObjectForKey:(id)aKey;
- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)setValue:(id)value forKey:(NSString *)key;
- (void)setLazyObject:(id)anObject forKey:(id)aKey;
- (void)setLazyValue:(id)value forKey:(NSString *)key;
- (NSArray *)allKeys;
- (NSArray *)allValues;
- (unsigned)count;
- (NSEnumerator *)keyEnumerator;
- (NSEnumerator *)objectEnumerator;
- (id)objectForKey:(id)aKey;
- (id)valueForKey:(NSString *)key;
- (void)setProperties;

@end
