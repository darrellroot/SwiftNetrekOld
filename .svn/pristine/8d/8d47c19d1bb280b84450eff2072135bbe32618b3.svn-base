//
//  LLDOReceiver.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLDOReceiver.h"


@implementation LLDOReceiver

- (id) init {
    self = [super init];
    if (self != nil) {
		target = nil;
		selector = nil;
		theConnection = [NSConnection defaultConnection];
		[theConnection setRootObject:self];
		// we are the receiver, thus objects can call us.
		// to do this, we register as a server DO object
		
		if ([theConnection registerName:@"LLDOServer"] == NO) {
			LLLog(@"LLDOReceiver.init failed, cannot obtain the default connection for this thread ");
			theConnection = nil;
			return nil;
		} else {
			LLLog(@"LLDOReceiver.init success, obtained the default connection for this thread ");
		}
		// nothing more to do,
		// the sender will declare a protocol and try to use it.
		// we support only the LLDOProxy Protocol.
    }
    return self;
}

- (void) setTarget:(id)newTarget withSelector:(SEL)newSelector {
	target = newTarget;
	selector = newSelector;
}

- (void) invokeWithUserData:(id)data {
	if ((target != nil) && (selector != nil)) {
		//LLLog(@"LLDOReceiver.invokeWithUserData called");
        [target performSelector:selector withObject:data];
	} else {
		LLLog(@"LLDOReceiver.invokeWithUserData called but have no target or selector");
	}
}

@end
