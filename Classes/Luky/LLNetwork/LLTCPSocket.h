//
//  LLTCPSocket.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LLSocket.h"

@interface LLTCPSocket : LLSocket {
	NSLock			*mutexWrite;
}

// Usage:
//
//		As Server:
//			- call listenOnPort to start listening for connections
//		    - call acceptConnection to wait for an incomming request
//			- read data or write data
//
//		As Client:
//			- call connectToHost to establish a connection
//			- read data or write data 

	// Connection management
- (BOOL)isConnected;

	// Making connections
//- (void)connectToHost:(LLHost*)host port:(unsigned short)port; moved to superclass

	// Receiving connections
- (void)listenOnPort:(unsigned short)port;
- (void)listenOnPort:(unsigned short)port maxPendingConnections:(unsigned int)maxPendingConnections;
- (void)acceptConnection;
- (LLTCPSocket*)acceptConnectionAndKeepListening;

	// Reading and writing
- (int)readData:(NSMutableData*)data;
- (void)writeData:(NSData*)data;
- (void)writeString:(NSString*)string;

@end
