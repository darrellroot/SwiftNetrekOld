//
//  LLDOSender.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLDOProxy.h"
#import "LLObject.h"

@interface LLDOSender : LLObject {
}

// this is the message that will be sent to the remote target
- (void) invokeRemoteObjectWithUserData:(id)data;

@end
