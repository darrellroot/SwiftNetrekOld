//
//  LLTCPSocket.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "LLTCPSocket.h"


@implementation LLTCPSocket

//
// Create a TCP Socket
//
- (id) init {
	self = [super init];
	if (self != nil) {
		// use seperate lock for writing
		mutexWrite = [[NSLock alloc] init];
		
		// Create TCP socket	
		if ( (socketfd = socket(AF_INET, SOCK_STREAM, 0)) < 0 )
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
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLTCPSocket.listenOnPort lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    if ( listen(socketfd, maxPendingConnections) < 0 )
        [NSException raise:SOCKET_EX_LISTEN_FAILED 
					format:SOCKET_EX_LISTEN_FAILED_F, strerror(errno)];
	
    listening = YES;
	
	[mutex unlock];
}

//
// Accept a connection on this socket, if it is listening.  May block if
// no connections are pending.  The existing listening socket will be destroyed, and
// replaced with the socket that is connected to the remote host.
//
// If you want to keep the listening socket around, try acceptConnectionAndKeepListening
//
- (void)acceptConnection {
	
    struct sockaddr_in acceptAddr;
    int socketfd2 = SOCKET_INVALID_DESCRIPTOR;
    unsigned int addrSize = sizeof(acceptAddr);
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLTCPSocket.acceptConnection lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created, not connected, and listening    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
    if ( connected )
        [NSException raise:SOCKET_EX_ALREADY_CONNECTED 
					format:SOCKET_EX_ALREADY_CONNECTED];
	
    if ( !listening )
        [NSException raise:SOCKET_EX_NOT_LISTENING 
					format:SOCKET_EX_NOT_LISTENING];
	
    // Accept a remote connection.  Raise on failure    
    socketfd2 = accept(socketfd, (struct sockaddr*)&acceptAddr, &addrSize);
    
    if ( socketfd2 < 0 )
        [NSException raise:SOCKET_EX_ACCEPT_FAILED 
					format:SOCKET_EX_ACCEPT_FAILED_F, strerror(errno)];
    
    // Replace existing socket descriptor with newly obtained one    
    [self _close];
	
    remotePort = acceptAddr.sin_port;
    remoteHostName = [[self _dottedIPFromAddress:&acceptAddr.sin_addr] retain];
    
    socketfd = socketfd2;
    connected = YES;
    listening = NO;
	
	[mutex unlock];
}

//
// Accept a connection on this socket, if it is listening.  May block if
// no connections are pending.  
//
// This variant of acceptConnection will return the connection to the remote host
// to you as a new Socket.  Meanwhile, this existing Socket will continue to 
// listen for connections.
//
- (LLTCPSocket*)acceptConnectionAndKeepListening {
	
    struct sockaddr_in acceptAddr;
    int socketfd2 = SOCKET_INVALID_DESCRIPTOR;
    unsigned int addrSize = sizeof(acceptAddr);
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLTCPSocket.acceptConnectionAndKeepListening lock timeout");
		return nil; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created, not connected, and listening    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
    if ( connected )
        [NSException raise:SOCKET_EX_ALREADY_CONNECTED 
					format:SOCKET_EX_ALREADY_CONNECTED];
	
    if ( !listening )
        [NSException raise:SOCKET_EX_NOT_LISTENING 
					format:SOCKET_EX_NOT_LISTENING];
	
    // Accept a remote connection.  Raise on failure    
    socketfd2 = accept(socketfd, (struct sockaddr*)&acceptAddr, &addrSize);
    
    if ( socketfd2 < 0 )
        [NSException raise:SOCKET_EX_ACCEPT_FAILED 
                    format:SOCKET_EX_ACCEPT_FAILED_F, strerror(errno)];
    
	[mutex unlock];
	
    return [[[LLTCPSocket alloc] _initWithFD:socketfd2 remoteAddress:&acceptAddr] autorelease];
}


//
// Returns whether the socket is connected
//
- (BOOL)isConnected {
	
    return connected;
}

//
// Append any available data from the socket to the supplied buffer.
// Returns number of bytes received.  (May be 0)
//
- (int)readData:(NSMutableData*)data {
    ssize_t count;
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLTCPSocket.readData lock timeout");
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
	
    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
					format:SOCKET_EX_NOT_CONNECTED];
    
    // Request a read of as much as we can.  Should return immediately if no data.	
    count = recv(socketfd, readBuffer, readBufferSize, 0);
    
    if ( count > 0 )
    {
        // Got some data, append it to user's buffer		
        [data appendBytes:readBuffer length:count];
    }
    else if ( count == 0 )
    {
        // Other side has disconnected, so close down our socket
		LLLog(@"LLTCPSocket.readData other side closed socket");
        [self _close];
		[NSException raise:SOCKET_EX_NOT_CONNECTED 
					format:SOCKET_EX_NOT_CONNECTED];
		return -1;
    }
    else if ( count < 0 )
    {
        // recv() returned an error. 		
        if ( errno == EAGAIN )
        {
            // No data available to read (and socket is non-blocking)
			LLLog(@"LLTCPSocket.readData no data read, but non blocking");
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
    
	if (![mutexWrite lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLTCPSocket.writeData lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created and connected    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
					format:SOCKET_EX_NOT_CONNECTED];
    
    // Send the data    
    while ( len > 0 )
    {
        sent = send(socketfd, bytes, len, 0);
        
        if ( sent < 0 )
            [NSException raise:SOCKET_EX_SEND_FAILED 
						format:SOCKET_EX_SEND_FAILED_F, strerror(errno)];    
        
        bytes += sent;
        len -= sent;
    }
	
	[mutexWrite unlock];
}

//
// Writes the given string to the socket
//
- (void)writeString:(NSString*)string {
	
    if ( [string length] > 0 ) 
        [self writeData:[string dataUsingEncoding:NSUTF8StringEncoding]]; 
}

@end
