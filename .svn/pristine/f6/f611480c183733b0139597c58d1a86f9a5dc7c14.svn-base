//
//  LLSocketStream.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LLSocket.h"
#import "LLMutableDataExtension.h"

// based upon:
//
//
// BufferedSocket.h
// BufferedSocket
//
// Created by Rainer Kupke (rkupke@gmx.de) on Thu Jul 26 2001.
// Copyright (c) 2001 Rainer Kupke.
//
// Additional modifications by Steven Frank (stevenf@panic.com)
//
// This software is provided 'as-is', without any express or implied 
// warranty. In no event will the authors be held liable for any damages 
// arising from the use of this software.
//
// Permission is granted to anyone to use this software for any purpose, 
// including commercial applications, and to alter it and redistribute it 
// freely, subject to the following restrictions:
//
//     1. The origin of this software must not be misrepresented; you must 
//        not claim that you wrote the original software. If you use this 
//        software in a product, an acknowledgment in the product 
//        documentation (and/or about box) would be appreciated but is not 
//        required.
//
//     2. Altered source versions must be plainly marked as such, and must
//        not be misrepresented as being the original software.
//
//     3. This notice may not be removed or altered from any source 
//        distribution.
//        

// Usage:
//
//		Create or init a stream with a socket
//		the socket will be set to non-blocking, change this if you want
//		by calling setBlocking
//
//		read from the stream

@interface LLSocketStream : LLObject {
	LLSocket *sock;
	bool blocking;
	NSMutableData* buffer;
}

// init
+ streamWithSocket:(LLSocket *)newSocket;
- (id) initWithSocket:(LLSocket*)newSocket;

// behaviour
- (void) setBlocking:(bool)block;
- (bool) blocking;

// Reading and writing data
- (NSMutableData*)readData: (int)n;
- (NSMutableData*)readDataUpToData:(NSData*) d;
- (NSMutableData*)readDataUpToString:(NSString*) s;
- (NSMutableData*)readDataWithMaxLength: (int)n;
- (NSString*)readLine;

@end
