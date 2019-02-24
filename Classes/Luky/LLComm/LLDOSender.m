//
//  LLDOSender.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLDOSender.h"


@implementation LLDOSender

id theProxy = nil;
NSAutoreleasePool *pool;

- (id) init {
    self = [super init];
    if (self != nil) {
	// $$ might need my own pool in this thread
	//pool = [[NSAutoreleasePool alloc] init];

	theProxy = [[NSConnection rootProxyForConnectionWithRegisteredName:@"LLDOServer" host:nil] retain];
	[theProxy setProtocolForProxy:@protocol(LLDOProxy)];
    }
    return self;
}

- (void) invokeRemoteObjectWithUserData:(id)data {

	if (theProxy != nil) {
		//LLLog(@"LLDOSender.invokeRemoteObjectWithUserData called");
		[theProxy invokeWithUserData:data];
	} else {
		 LLLog(@"LLDOSender.invokeRemoteObjectWithUserData called without proxy object");
	}
}

- (void) destroy {

	[pool release];
    // $$ hmm how to ensure this is called?
	//[super destroy];
}

@end
