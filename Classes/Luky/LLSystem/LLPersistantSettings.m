//
//  LLPersistantSettings.m
//  MacTrek
//
//  Created by Aqua on 20/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLPersistantSettings.h"


@implementation LLPersistantSettings

LLPersistantSettings* defaultSettings;

- (id) init {
    self = [super init];
    if (self != nil) {
        
        NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
        pathToSettings = [NSString stringWithFormat:@"%@/settings.xml", pathToResources];
        [pathToSettings retain];
        
        // load settings
        settings = [[NSMutableDictionary alloc] initWithContentsOfFile:pathToSettings];
              
        if ([settings count] == 0) {
            // something went wrong ?
            LLLog(@"LLPersistantSettings.init WARNING: settings file is empty");
            settings = [[NSMutableDictionary alloc] init];
        } 
    }
    return self;
}

+ (LLPersistantSettings*) defaultSettings {
    if (defaultSettings == nil) {
        defaultSettings = [[LLPersistantSettings alloc] init];
    }
    return defaultSettings;
}

- (void)update {
    // we could check if something really changed..
    if (![settings writeToFile:pathToSettings atomically:YES]) {
        LLLog(@"LLPersistantSettings.update WARNING: settings file is corrupt");
    }
}

- (void)removeAllObjects {
    [settings removeAllObjects];
    [self update];
}

- (void)removeObjectForKey:(id)aKey {
    [settings removeObjectForKey:aKey];
    [self update];
}

- (void)setObject:(id)anObject forKey:(id)aKey {
    [settings setObject:anObject forKey:aKey];
    [self update];
}

- (void)setValue:(id)value forKey:(NSString *)key {
    [settings setValue:value forKey:key];
    [self update];
}

- (void)setLazyObject:(id)anObject forKey:(id)aKey {
    [settings setObject:anObject forKey:aKey];
}

- (void)setLazyValue:(id)value forKey:(NSString *)key{
    [settings setValue:value forKey:key];
}

- (NSArray *)allKeys {
    return [settings allKeys];
}

- (NSArray *)allValues {
    return [settings allValues];
}

- (unsigned)count {
    return [settings count];
}

- (NSEnumerator *)keyEnumerator {
    return [settings keyEnumerator];
}

- (NSEnumerator *)objectEnumerator {
    return [settings objectEnumerator];
}

- (id)objectForKey:(id)aKey {
    return [settings objectForKey:aKey];
}

- (id)valueForKey:(NSString *)key {
    return [settings valueForKey:key];
}

- (void)setProperties {
	// set all settings we have to the properties object
	// this object is global accessable in all LLObject
	[properties addEntriesFromDictionary:settings];
}

@end
