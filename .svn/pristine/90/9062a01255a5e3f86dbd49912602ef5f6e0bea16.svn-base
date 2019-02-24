//
//  LLNotificationCenterEntry.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

@interface LLNotificationCenterEntry : LLObject {
    NSString *name; // name of entry we want, nil means all
    id source;      // source id we want, nil means all
    id target;      // target object
    SEL selector;   // selector at target
    bool useLocks;
    bool mainLoop;
    id userData;
}

- (id) initWithNotificationName:(NSString*) notification source:(id) src target:(id) targ 
                       selector:(SEL)sel useLocks:(bool)protect useMainLoop:(bool)useMainLoop;
//- (id) initWithNotificationName:(NSString*) notification source:(id) src target:(id) targ selector:(SEL)sel; 
- (NSString *)name;
- (id) source;
- (id) target;
- (SEL) selector;
- (bool) useLocks;
- (bool) useMainLoop;
- (void) setUserData:(id)data;
- (id) userData;

@end
