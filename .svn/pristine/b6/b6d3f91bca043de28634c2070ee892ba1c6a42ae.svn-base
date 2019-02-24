//
//  LLHost.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "LLHost.h"


@implementation LLHost

// don't call this
- (id) init {
	self = [super init];
	if (self != nil) {
		name = nil;
	}
	return self;
}

- (id) initWithHostName:(NSString *)hostname {
	self = [super init];
	if (self != nil) {
		name = [hostname retain];
	}
	return self;
}

- (id) initWithAddress:(NSString *)address {
	self = [super init];
	if (self != nil) {
		NSHost *host = [NSHost hostWithAddress:address];
		if (host == nil) {
			return nil;
		}
		name = [[host name] retain];
	}
	return self;
}

+ (LLHost *)hostWithName:(NSString *)hostname {
		
	return [[LLHost alloc] initWithHostName:hostname];
}

+ (LLHost *)hostWithAddress:(NSString *)address {
	
	return [[LLHost alloc] initWithAddress:address];
}

- (NSString *)hostname {
	return name;
}

- (NSArray *)addresses {
	if (name == nil) {
		return nil;
	}
	return [[NSHost hostWithName:name] addresses];
}

- (NSString *)address {
	
	NSArray *addresses = [self addresses];
	if (addresses == nil) {
		return nil;
	}
	
	unsigned int i, count = [addresses count];
	NSString *address;
	for (i = 0; i < count; i++) {
		address = [addresses objectAtIndex:i];
		//LLLog(@"LLHost.address %@ becomes %@", name, address);
		NSRange r = [address rangeOfString:@":"]; // ip6 names
		if (r.location == NSNotFound) {
			// must be ip4
			return address;
		}
	}
	
	return nil; // no ip4 found
}

- (NSData *)firstAddressData {
	// should return 4 bytes containing the network address
	NSString *addressString = [[self address] stringByAppendingString:@"."]; // append a final dot
	
	// keep looking for the bit before the dot, then cut it off
	NSMutableData *result = [[[NSMutableData alloc] init] autorelease];
	NSString *tuple;
	NSRange tupleRange;
	
	for (int i=0; i < 4; i++) {
		// find the tuple
		tupleRange = NSMakeRange(0, [addressString rangeOfString:@"."].location);
		// some sanity checks
		if (tupleRange.length == NSNotFound) {
			return nil;
		}
		if (tupleRange.length > [addressString length]) {
			return nil;
		}
		// cut in two pieces
		tuple = [addressString substringWithRange:tupleRange];
		addressString = [addressString substringFromIndex:tupleRange.length + 1]; // including dot
		// get the value
		int intValue = [tuple intValue];
		char value = intValue & 0xFF;
		// store it
		[result appendBytes:&value length:1];
	}
	
	return result;
}

@end
