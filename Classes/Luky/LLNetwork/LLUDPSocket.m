//
//  LLUDPSocket.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "LLUDPSocket.h"


@implementation LLUDPSocket

//
// Create a UDP Socket
//
- (id) init {
	self = [super init];
	if (self != nil) {
		
		// Create UDP socket	
		if ( (socketfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 )
			[NSException raise:SOCKET_EX_CANT_CREATE_SOCKET 
						format:SOCKET_EX_CANT_CREATE_SOCKET_F, strerror(errno)];
	}
	return self;
}

//
// Start the socket listening on the given local port number
//
- (void)listenOnPort:(unsigned short)port {
    [self listenOnPort:port maxPendingConnections:SOCKET_MAX_PENDING_CONNECTIONS];
}

//
// Start the socket listening on the given local port number,
// with the given maximum number of pending connections.
//
- (void)listenOnPort:(unsigned short)port maxPendingConnections:(unsigned int)maxPendingConnections {
	
    [self _bindTo:INADDR_ANY port:port];
	
	// for UDP we do not actually listen, just bind to the port	
    listening = YES;
	// must set connected too otherwise some otherwise waitForReadableWithTimeout won't work
	connected = YES; 
	[remoteHostName release];
	remoteHostName = nil; // reset remote host
}

//
// Connect the socket to the host specified by hostName, on the requested port.
//
- (void)connectToHost:(LLHost*)host port:(unsigned short)port {
	
	LLLog(@"LLUDPSocket.connectToHost setup connection but ignoring connect");
	LLLog(@"LLUDPSocket.connectToHost old value %@:%d", remoteHostName, remotePort);
	// we do not actually connect in UDP but setup the remote address
	[remoteHostName release];
	remoteHostName = [host address]; // need dotted notation
	remotePort = port;	
	LLLog(@"LLUDPSocket.connectToHost new value %@:%d", remoteHostName, port);
}

//
// Append any available data from the socket to the supplied buffer.
// Returns number of bytes received.  (May be 0)
//
- (int)readData:(NSMutableData*)data {
	
    ssize_t count;
	struct sockaddr_in remoteAddress;
	unsigned int length;
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLUDPSocket.readData lock timeout");
		return 0; // no lock obtained, so no need to unlock
	}
	
	// data must not be null ptr	
	if ( data == NULL )
		[NSException raise:SOCKET_EX_INVALID_BUFFER 
					format:SOCKET_EX_INVALID_BUFFER];
	
    // Socket must be created and connected    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
    if ( !listening )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
					format:SOCKET_EX_NOT_CONNECTED];
	
	// translate the remote hostname to byte order
	struct in_addr address;
	
	if (listening == NO) {
		// i am client of a remote host
		if ( inet_aton([remoteHostName UTF8String], &address) == 0 ) 
			[NSException raise:SOCKET_EX_HOST_NOT_FOUND 
						format:SOCKET_EX_HOST_NOT_FOUND_F, strerror(errno)];
	} else {
		 // i am server
		address.s_addr = INADDR_ANY;
	}

	// build the target address
	bzero(&remoteAddress, sizeof(remoteAddress));
    remoteAddress.sin_family      = AF_INET;
    remoteAddress.sin_addr.s_addr = htonl(address.s_addr);
    remoteAddress.sin_port        = htons(remotePort);	
	
    // Request a read of as much as we can.  Should return immediately if no data.
    count = recvfrom(socketfd, readBuffer, readBufferSize, 0, (struct sockaddr *)&remoteAddress, &length);
    	
    if ( count > 0 )
    {
        // Got some data, append it to user's buffer		
        [data appendBytes:readBuffer length:count];
		
		// all went well, update the address of the host we received something from
		// for debugging purpose (and we can directly reply with write)
		[remoteHostName release];
		remoteHostName = [[self _dottedIPFromAddress:&remoteAddress.sin_addr] retain];
		remotePort = remoteAddress.sin_port;
    }
    else if ( count == 0 )
    {
        // Other side has disconnected, so close down our socket		
        [self _close];
    }
    else if ( count < 0 )
    {
        // recv() returned an error. 		
        if ( errno == EAGAIN )
        {
            // No data available to read (and socket is non-blocking)
            count = 0;
        }
        else
            [NSException raise:SOCKET_EX_RECV_FAILED 
						format:SOCKET_EX_RECV_FAILED_F, strerror(errno)];
    }
    
	[mutex unlock];
	
    return count;
}

//
// Writes the given data to the socket
//
- (void)writeData:(NSData*)data {
	
    const char* bytes = [data bytes];    
    int len = [data length];
    int sent;
	struct sockaddr_in remoteAddress;
    
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLUDPSocket.writeData lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created and connected    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
	if (remoteHostName == nil) {
		LLLog(@"LLUDPSocket.writeData ERROR no remote host set");
		return; 
	}
	
	// translate the remote hostname to byte order
	struct in_addr address;
	if ( inet_aton([remoteHostName UTF8String], &address) == 0 ) 
		[NSException raise:SOCKET_EX_HOST_NOT_FOUND 
					format:SOCKET_EX_HOST_NOT_FOUND_F, strerror(errno)];
		
	// build the target address
	bzero(&remoteAddress, sizeof(remoteAddress));
    remoteAddress.sin_family      = AF_INET;
    remoteAddress.sin_addr.s_addr = htonl(address.s_addr);
    remoteAddress.sin_port        = htons(remotePort);	
	
	LLLog(@"LLUDPSocket.writeData with len %d to %@:%d", len, remoteHostName, remotePort);
	
    // Send the data    
    while ( len > 0 )
    {
        sent = sendto(socketfd, bytes, len, 0, (struct sockaddr *)&remoteAddress, sizeof(remoteAddress));
        
        if ( sent < 0 ) {
			LLLog(@"LLUDPSocket.writeData ERROR %d %s", errno, strerror(errno));
            [NSException raise:SOCKET_EX_SEND_FAILED 
						format:SOCKET_EX_SEND_FAILED_F, strerror(errno)];    
        }
        bytes += sent;
        len -= sent;
    }
	
	[mutex unlock];
}

//
// Writes the given string to the socket
//
- (void)writeString:(NSString*)string {
	
    if ( [string length] > 0 ) 
        [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding]]; 
}


@end
