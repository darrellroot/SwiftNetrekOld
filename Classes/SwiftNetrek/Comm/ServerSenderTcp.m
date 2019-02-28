//
//  ServerSenderTcp.m
//  MacTrek
//
//  Created by Aqua on 13/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "ServerSenderTcp.h"


@implementation ServerSenderTcp

- (id) initWithSocket:(LLTCPSocket*) newSocket {
        
    self = [super init];
    if (self != nil) {
        socket = newSocket;
    }
    return self;
}

- (bool) sendBuffer:(char*) buffer length:(int)size {
    
	// clutters too much
    //LLLog(@"ServerSenderTcp.sendBuffer message: %@ (%d) size: %d", [pktConv clientPacketString:buffer[0]], buffer[0], size);
    [pktConv printPacketInBuffer:buffer size:size];
	
    NSData *packet = [[NSData alloc] initWithBytes:buffer length:size];
    // should test for some error in the writing?
    @try {
        if (socket != nil) {
            [socket writeData:packet];
        } else {
            LLLog(@"ServerSenderTcp.sendBuffer cannot send message, socket was closed");
        }        
    }
    @catch (NSException * e) {
        LLLog(@"ServerSenderTcp.sendBuffer cannot send message, should close!");
        [packet release];
        return NO;
    }
    
    [packet release];
    return YES;
}

- (void) close {
    if (socket != nil) {
      // [socket release]; 
    }
	 
    socket = nil;
}

- (LLHost*) serverHost {
    if (socket == nil) {
		return nil; 
    }
	
	return [socket remoteHost];
}

- (int) serverPort {
    if (socket == nil) {
		return -1; 
    }
	
	return [socket remotePort];
}


@end
