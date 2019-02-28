//
//  MTKeyMapEntry.m
//  MacTrek
//
//  Created by Aqua on 21/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MTKeyMapEntry.h"


@implementation MTKeyMapEntry

- (id) init {
    self = [super init];
    if (self != nil) {
        action = 0;
        key = 0;
        modifierFlags = 0;
        description = nil;
        defaultKey = 0;
        defaultModifierFlags = 0;
    }
    return self;
}

- (id) initAction:(int) newAction 
          withKey:(char)newKey 
    modifierFlags:(unsigned int) newModifierFlags
      description:(NSString*)newDescription {
    
    self = [self init];
    
    action = newAction;
    key = newKey;
    modifierFlags = newModifierFlags;
    description = newDescription;
    [description retain];
    defaultKey = newKey;
    defaultModifierFlags = newModifierFlags; 
    
    return self;
}

- (id) initWithDictionairy:(NSDictionary*)dict {
    
    int          _action = [[dict valueForKey:@"action"] intValue]; // NSNumber
    char         _key    = [[dict valueForKey:@"key"] charValue];   // NSNumber
    unsigned int _flags  = [[dict valueForKey:@"flags"] intValue];  // NSNumber
    NSString    *_descr  = [dict valueForKey:@"description"];
    
    return [self initAction:_action 
                    withKey:_key 
              modifierFlags:_flags
                description:_descr];
}

- (NSDictionary*) asDictionary {
    return [NSDictionary dictionaryWithObjectsAndKeys: 
        [NSNumber numberWithInt:action], @"action",
        [NSNumber numberWithChar:key], @"key",
        [NSNumber numberWithInt:modifierFlags], @"flags",
        description, @"description",
        nil];
}

- (int) action {
    return action;
}

- (char) key {
    return key;
}

- (unsigned int) modifierFlags {
    return modifierFlags;
}

- (char) defaultKey {
    return defaultKey;
}
- (unsigned int) defaultModifierFlags {
    return defaultModifierFlags;
}

- (NSString *)description {
    return description;
}

- (void) setAction:(int) newAction {
    action = newAction;
}

- (void) setKey:(char) newKey {
    key = newKey;
}

- (void) setModifierFlags:(unsigned int) newModifierFlags{
    modifierFlags = newModifierFlags;
}


@end
