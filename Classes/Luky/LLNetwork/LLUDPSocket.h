//
//  LLUDPSocket.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LLSocket.h"

@interface LLUDPSocket : LLSocket {

}

// Usage:
//
//		As Server:
//			- call listenOnPort to start listening for connections
//			- read data (this will set the remoteHost upon reception)
//			- write data (wil use this remote host)
//
//		As Client:
//			- call connectToHost to establish a connection
//			- write data to tell the host who you are
//			- read data 

	// Making connections
//- (void)connectToHost:(LLHost*)host port:(unsigned short)port;  moved to super class

	// Receiving connections
- (void)listenOnPort:(unsigned short)port;
- (void)listenOnPort:(unsigned short)port maxPendingConnections:(unsigned int)maxPendingConnections;

	// Reading and writing
- (int) readData:(NSMutableData*)data;
- (void)writeData:(NSData*)data;
- (void)writeString:(NSString*)string;

@end
