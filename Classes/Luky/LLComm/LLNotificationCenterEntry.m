//
//  LLNotificationCenterEntry.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLNotificationCenterEntry.h"


@implementation LLNotificationCenterEntry

//- (id) initWithNotificationName:(NSString*) notification source:(id) src target:(id) targ selector:(SEL)sel { 
//    return [self initWithNotificationName:notification source:src target:targ selector:sel useLocks:NO];
//}

- (id) initWithNotificationName:(NSString*) notification source:(id) src target:(id) targ 
                       selector:(SEL)sel useLocks:(bool)protect useMainLoop:(bool)useMainLoop{
        
    self = [super init];
    if (self != nil) {
        name = notification;
        source = src; 
        target = targ;
        selector = sel;
        useLocks = protect;
        mainLoop = useMainLoop;
    }
    return self; 
} 

- (id) init {
    self = [super init];
    if (self != nil) {
        name = nil;
        source = nil;
        target = nil;
        selector = nil;
        mainLoop = NO;
        useLocks = NO;
        userData = nil;
    }
    return self;
}

- (NSString *)name {
    return name;
}

- (SEL) selector {
    return selector;
}

- (id) target {
    return target;
}

- (id) source {
    return source;
}

- (bool) useLocks {
    return useLocks;
}

- (bool) useMainLoop {
    return mainLoop;
}

- (void) setUserData:(id)data {
    userData = data;
}

- (id) userData {
    return userData;
}

@end
