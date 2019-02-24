//
//  LLSocketStream.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "LLSocketStream.h"


@implementation LLSocketStream

+ streamWithSocket:(LLSocket *)newSocket {
	return [[[self alloc] initWithSocket:newSocket] autorelease];
}

- (id) init {
	self = [super init];
	if (self != nil) {
		sock = nil;
		blocking = NO;
		buffer = [[NSMutableData alloc] init];
	}
	return self;
}

- (id) initWithSocket:(LLSocket*)newSocket {
	self = [self init];
	if (self != nil) {
		sock = newSocket;
		[sock retain];
		[sock setBlocking:blocking]; // pass on blocking setting
	}
	return self;
}

- (void) setBlocking:(bool)block {
	blocking = block;
	[sock setBlocking:block];
}

- (bool) blocking {
	return blocking;
}

//
// Destructor, do not call.  Use -release instead
//
- (void) dealloc {
	
    [buffer release];
	[sock release];
    [super dealloc];
}

- (NSMutableData*)readData:(int)n
{
    while ( [buffer length] < n )
    {
        int len;
        len = [sock readData:buffer];
		
        if ( len == 0 ) 
			return nil; // socket closed or nonblocking socket && not enough data
    }
    
    return [buffer getBytes:n];
}


- (NSMutableData*)readDataUpToData:(NSData*)d
{
    while ( ![buffer containsData:d] )
    {
        int len;
        len = [sock readData:buffer];
		
        if ( len == 0 ) 
			return nil; // socket closed or nonblocking socket && not enough data   
    }
    
    return [buffer getBytesUpToData:d];
}

- (NSMutableData*)readDataUpToString:(NSString*)s
{
    return [self readDataUpToData:[s dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData*)readDataWithMaxLength:(int)n
{
	if ([buffer length] == 0) {
		// we have nothing, get something
		int len;
        len = [sock readData:buffer];
		
        if ( len == 0 ) 
			return nil; // socket closed or nonblocking socket && not enough data
	}
	
	// we have something, but maybe too much
    if ( [buffer length] > n ) {
		// we have too much
		return [buffer getBytes:n];				
	} else {
		// it is enough, return all we have
		return [buffer getBytes: [buffer length]];
	}
}

- (NSString*)readLine {
	
	NSMutableData *temp = [self readDataUpToData:[NSData dataWithBytes:"\n" length:1]];
	
	if (temp == nil) {
		return nil;
	}
	// close the string by replacing last character
	[temp replaceBytesInRange:NSMakeRange([temp length] - 1, 1) withBytes:"\0"];
	// return it
	return [NSString stringWithCString:[temp bytes] encoding:NSASCIIStringEncoding];
}

@end
