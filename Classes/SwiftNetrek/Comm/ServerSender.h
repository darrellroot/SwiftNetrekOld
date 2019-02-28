//
//  ServerSender.h
//  MacTrek
//
//  Created by Aqua on 13/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "LLNetwork.h"
#import "PacketTypesDebug.h"
#import "BaseClass.h"

@interface ServerSender : BaseClass {
    PacketTypesDebug *pktConv;
}

- (id)   initWithSocket:(LLSocket*) socket;
- (bool) sendBuffer:(char*) buffer length:(int)size;
- (void) close;

@end
