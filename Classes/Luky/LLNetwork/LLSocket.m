//
//  LLSocket.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "LLSocket.h"


@implementation LLSocket


//
// Internal utility function.  You should not call this from client code.
//
- (void)allocReadBuffer {
    // Allocate readBuffer    
    if ( readBuffer == NULL )     {
        readBuffer = malloc(readBufferSize);
        if ( readBuffer == NULL )
            [NSException raise:SOCKET_EX_MALLOC_FAILED format:SOCKET_EX_MALLOC_FAILED];
    }
}

//
// Default initializer
//
- (id)init {    
    if ( ![super init] )
		return nil;
	
    connected = NO;
    listening = NO;
	blocking  = YES; // default
    readBuffer = NULL;
    readBufferSize = SOCKET_DEFAULT_READ_BUFFER_SIZE;
    remoteHostName = NULL;
    remotePort = SOCKET_INVALID_PORT;
	socketfd = SOCKET_INVALID_DESCRIPTOR;
	mutex = [[NSLock alloc] init];
	timeOut = SOCKET_DEFAULT_CONCURRENCY_TIMEOUT;
	
    [self allocReadBuffer];
    
    return self;
}

//
// Returns whether or not data is available at the Socket for reading
//
- (BOOL)isReadable {
	
	return [self waitForReadableWithTimeout:0.0];
}

- (BOOL)waitForReadableWithTimeout:(NSTimeInterval) waittime {
	
    int count;
    fd_set readfds;
    struct timeval timeout;
    
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLSocket.waitForReadableWithTimeout lock timeout");
		return NO; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created and connected    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
					format:SOCKET_EX_NOT_CONNECTED];
	
    // Create a file descriptor set for just this socket	
    FD_ZERO(&readfds);
    FD_SET(socketfd, &readfds);
	
    // Create a timeout or zero (don't wait)	
    timeout.tv_sec = (int) waittime;
    timeout.tv_usec = (int)(((double)(waittime * 1000000)) - ((double)(timeout.tv_sec * 1000000.0)));
	
    // Check socket for data	
    count = select(socketfd + 1, &readfds, NULL, NULL, &timeout);
    
    // Return value of less than 0 indicates error	
    if ( count < 0 )
        [NSException raise:SOCKET_EX_SELECT_FAILED 
					format:SOCKET_EX_SELECT_FAILED_F, strerror(errno)];
    
	[mutex unlock];
    // select() returns number of descriptors that matched, so 1 == has data, 0 == no data    
    return (count == 1);
}

//
// Returns whether or not the Socket can be written to
//
- (BOOL)isWritable {
	
    int count;
    fd_set writefds;
    struct timeval timeout;
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {		
		LLLog(@"LLSocket.isWritable lock timeout");
		return NO; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created and connected    
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
	
    if ( !connected )
        [NSException raise:SOCKET_EX_NOT_CONNECTED 
					format:SOCKET_EX_NOT_CONNECTED];
	
    // Create a file descriptor set for just this socket
	
    FD_ZERO(&writefds);
    FD_SET(socketfd, &writefds);
	
    // Create a timeout of zero (don't wait)	
    timeout.tv_sec = 0;
    timeout.tv_usec = 0;
	
    // Check socket for data	
    count = select(socketfd + 1, NULL, &writefds, NULL, &timeout);
    
    // Return value of less than 0 indicates error	
    if ( count < 0 )
        [NSException raise:SOCKET_EX_SELECT_FAILED 
					format:SOCKET_EX_SELECT_FAILED_F, strerror(errno)];
    
	[mutex unlock];
	
    // select() returns number of descriptors that matched, so 1 == write OK    
    return (count == 1);
}

//
// Returns the remote hostname that the socket is connected to,
// or NULL if the socket is not connected.
//
- (LLHost*)remoteHost {
	
    return [LLHost hostWithName:remoteHostName];
}

//
// Returns the remote port number that the socket is connected to, 
// or 0 if not connected.
//
- (unsigned short)remotePort {
	
    return remotePort;
}

// 
// Query function for programmers with amnesia
//
- (BOOL)blocking {
	return blocking;
}

//
// Switch the socket to blocking or non-blocking mode
//
- (void)setBlocking:(BOOL)shouldBlock {
	
    int flags;
    int result;
    
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {		
		LLLog(@"LLSocket.setBlocking lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    flags = fcntl(socketfd, F_GETFL, 0);
	
    if ( flags < 0 )
        [NSException raise:SOCKET_EX_FCNTL_FAILED 
					format:SOCKET_EX_FCNTL_FAILED_F, strerror(errno)];
	
    if ( shouldBlock )
    {
        // Set it to blocking...
        result = fcntl(socketfd, F_SETFL, flags & ~O_NONBLOCK );
    }
    else
    {
        // Set it to non-blocking...
        result = fcntl(socketfd, F_SETFL, flags | O_NONBLOCK);
    }
	
    if ( result < 0 )
        [NSException raise:SOCKET_EX_FCNTL_FAILED 
					format:SOCKET_EX_FCNTL_FAILED_F, strerror(errno)];
	
	blocking = shouldBlock;
	
	[mutex unlock];
}

//
// Change the size of the read buffer at runtime
//
- (void)setReadBufferSize:(unsigned int)size {
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLSocket.setReadBufferSize lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    readBufferSize = size;
	
    if ( readBuffer ) 
    {
        free(readBuffer);
        readBuffer = NULL;
    }
    
    [self allocReadBuffer];

	[mutex unlock];
}

//
// Returns this Socket's readBuffer size
//
- (unsigned int)readBufferSize {
	
    return readBufferSize;
}

//
// Utility function that returns a dotted IP address string from a
// 32-bit network address
//
- (NSString*)_dottedIPFromAddress:(struct in_addr*)address; {
	return [NSString stringWithCString:inet_ntoa(*address) encoding:NSASCIIStringEncoding];
}

//
// Connect the socket to the host specified by hostAddress, on the requested port.
//
- (void)connectToHost:(LLHost*)host port:(unsigned short)port  {
	[self connectToHost:host port:port force:NO];
}

- (void)connectToHost:(LLHost*)host port:(unsigned short)port force:(BOOL)force {
	
	NSString *hostAddress = [host address];
    struct hostent* remoteHost;
    struct sockaddr_in remoteAddr;
	
	if (hostAddress == nil) {
		LLLog(@"LLSocket.connectToHost no address for %@", [host hostname]);		
		return; // no lock obtained, so no need to unlock
	}
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLSocket.connectToHost lock timeout");		
		return; // no lock obtained, so no need to unlock
	}
	
    // Socket must be created, and not already connected	
    if ( socketfd == SOCKET_INVALID_DESCRIPTOR )
        [NSException raise:SOCKET_EX_BAD_SOCKET_DESCRIPTOR 
					format:SOCKET_EX_BAD_SOCKET_DESCRIPTOR];
    
	// check for connection unless we are forcing our way in
    if ( connected && !force)
        [NSException raise:SOCKET_EX_ALREADY_CONNECTED 
					format:SOCKET_EX_ALREADY_CONNECTED];
    
    // Look up host  
    if ( (remoteHost = gethostbyname([hostAddress UTF8String])) == NULL )
        [NSException raise:SOCKET_EX_HOST_NOT_FOUND 
					format:SOCKET_EX_HOST_NOT_FOUND_F, strerror(errno)];
    
    // Copy host address and port into socket address structure    
    bzero((char*)&remoteAddr, sizeof(remoteAddr));
    remoteAddr.sin_family = AF_INET;
    bcopy((char*)remoteHost->h_addr, (char*)&remoteAddr.sin_addr.s_addr, remoteHost->h_length);
    remoteAddr.sin_port = htons(port);
	
    // Request connection, raise on failure    
    if ( (connect(socketfd, (struct sockaddr*)&remoteAddr, sizeof(remoteAddr)) < 0) )
        [NSException raise:SOCKET_EX_CONNECT_FAILED 
					format:SOCKET_EX_CONNECT_FAILED_F, strerror(errno)];
	
    // Note successful connection    
    remoteHostName = [[NSString alloc] initWithString:hostAddress];
    remotePort = port;
	
    connected = YES;
	
	[mutex unlock];
}

//
// Inits a Socket with an existing, connected socket file descriptor.  This is really
// only intended for internal use (see -acceptConnectionAndKeepListening) 
//
- (id)_initWithFD:(int)fd remoteAddress:(struct sockaddr_in*)remoteAddress {
	
    if ( ![super init] )
		return nil;
	
    connected = YES;
    listening = NO;
    readBuffer = NULL;
    readBufferSize = SOCKET_DEFAULT_READ_BUFFER_SIZE;
    remoteHostName = [[self _dottedIPFromAddress:&remoteAddress->sin_addr] retain];
    remotePort = remoteAddress->sin_port;
    socketfd = fd;    
	
    [self allocReadBuffer];
	
    return self;
}

//
// Bind an address to this socket.  You normally do not need to
// call this method.  See listenOnPort instead.
//
- (void)_bindTo:(u_int32_t)address port:(unsigned short)port {
	
    struct sockaddr_in localAddr;
    int on = 1;
	
	if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
		LLLog(@"LLSocket._bindTo lock timeout");
		return; // no lock obtained, so no need to unlock
	}
	
    // Set a flag so that this address can be re-used immediately after the connection
    // closes.  (TCP normally imposes a delay before an address can be re-used.)    
    if ( setsockopt(socketfd, SOL_SOCKET, SO_REUSEADDR, (void*)&on, sizeof(on)) < 0 )
        [NSException raise:SOCKET_EX_SETSOCKOPT_FAILED 
					format:SOCKET_EX_SETSOCKOPT_FAILED_F, strerror(errno)];
	
    // Bind the address to the socket
	bzero(&localAddr, sizeof(localAddr));
    localAddr.sin_family      = AF_INET;
    localAddr.sin_addr.s_addr = htonl(address);
    localAddr.sin_port        = htons(port);
	
    if ( bind(socketfd, (struct sockaddr*)&localAddr, sizeof(localAddr)) < 0 )
		[NSException raise:SOCKET_EX_BIND_FAILED 
					format:SOCKET_EX_BIND_FAILED_F, strerror(errno)];
	
	[mutex unlock];
}

//
// Closes the socket.  You generally do not need to call this, as the socket
// will be automatically closed when it is released.
//
- (void)_close {
	
	// no need for locks, we are called internally
	
    if ( socketfd != SOCKET_INVALID_DESCRIPTOR ) {
        close(socketfd);
        socketfd = SOCKET_INVALID_DESCRIPTOR;
    }
    
    if ( remoteHostName != NULL ) {
        [remoteHostName release];
        remoteHostName = NULL;
    }
	
    connected = NO;
    listening = NO;
    remotePort = SOCKET_INVALID_PORT;
}

- (BOOL) isBusy {
	// if we are busy we can not get a lock
	if ([mutex tryLock]) {
		[mutex unlock];
		return NO;
	} else {
		return YES;
	}
}

//
// Should be subclassed is i do not know how (TCP/UDP)
//
- (int)readData:(NSMutableData*)data {
	[NSException raise:SOCKET_EX_RECV_FAILED 
				format:SOCKET_EX_RECV_FAILED_F, strerror(errno)];
	return 0;
}

//
// Should be subclassed is i do not know how (TCP/UDP)
//
- (void)writeData:(NSData*)data {
	[NSException raise:SOCKET_EX_SEND_FAILED 
				format:SOCKET_EX_SEND_FAILED_F, strerror(errno)];
}

//
// Do not call this method directly!  Use retain & release.
//
- (void)dealloc {
	
    [self _close];
	
    if ( readBuffer )
    {
        free(readBuffer);
        readBuffer = NULL;
    }
    
    [super dealloc];
}

@end
