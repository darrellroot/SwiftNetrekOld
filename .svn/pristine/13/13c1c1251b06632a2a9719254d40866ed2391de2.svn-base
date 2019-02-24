//
//  LLDOReceiver.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLDOProxy.h"
#import "LLObject.h"


@interface LLDOReceiver : LLObject <LLDOProxy> {
	id  target;
	SEL selector;
	NSConnection *theConnection;
}

// this is the target that will be called upon reception
// of a remote call
- (void) setTarget:(id) newTarget withSelector:(SEL)selector;

@end
