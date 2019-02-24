//
//  LLDOProxy.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>

// classes that implement this protocol 
// should have a method as declared blow
// which can be invoked by a remote object
@protocol LLDOProxy 

- (void) invokeWithUserData:(id)data;

@end
