//
//  MTKeyMapEntry.h
//  MacTrek
//
//  Created by Aqua on 21/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"

@interface MTKeyMapEntry : BaseClass {
    int action;
    char key;
    unsigned int modifierFlags;
    char defaultKey;
    unsigned int defaultModifierFlags;
    NSString *description;
}

- (id) initWithDictionairy:(NSDictionary*)dict;
- (NSDictionary*) asDictionary;
- (id) initAction:(int) action 
          withKey:(char)key 
    modifierFlags:(unsigned int) modifierFlags
      description:(NSString*)description;
- (int) action;
- (char) key;
- (unsigned int) modifierFlags;
- (char) defaultKey;
- (unsigned int) defaultModifierFlags;
- (NSString *)description;
- (void) setAction:(int) action;
- (void) setKey:(char) key;
- (void) setModifierFlags:(unsigned int) modifierFlags;

@end
