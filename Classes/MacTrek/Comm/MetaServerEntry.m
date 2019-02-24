//-------------------------------------------
// File:  MetaServerEntry.m
// Class: MetaServerEntry
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
 
#import "MetaServerEntry.h"

@implementation MetaServerEntry

- (id) init {
	self = [super init];
	if (self != nil) {
		statusStrings = [[NSArray alloc] initWithObjects:    
			@"OPEN:", 
			@"Wait queue:", 
			@"Nobody", 
			@"Timed out", 
			@"No connection",
			@"Active", 
			@"CANNOT CONNECT", 
			@"DEFAULT SERVER",
			@"Flooding",
			nil];
		
	}
	return self;
}

// setters
- (void) setAddress:(NSString*) newAddress {
	[address release];
	address = newAddress;
	[address retain];
}

- (void) setPort:(int)newPort {
	port = newPort;
}    

- (void) setTime:(int)newTime {
	time = newTime;
}

- (void) setPlayers:(int)newPlayers {
	players = newPlayers;
}

- (void) setStatus:(enum ServerStatusType)newStatus {
	status = newStatus;
}

- (enum ServerGameType) setGameTypeWithString:(NSString *) line {
    
    if ([line isEqualToString:@"P"]) {
        [self setGameType: PARADISE];
    } else if ([line isEqualToString:@"B"]) {
        [self setGameType:  BRONCO];
    } else if ([line isEqualToString:@"H"]) {
        [self setGameType:  HOCKEY];
    } else {
        [self setGameType: UNKNOWN];
    }
    
    return [self gameType];
}

- (enum ServerStatusType) setStatusWithString:(NSString *) line {
	
	for (int i = 0; i < [statusStrings count]; ++i) {
		NSRange range = [line rangeOfString:[statusStrings objectAtIndex:i]];
		
		// look for substring which will catch leading * thingies
		if (range.location != NSNotFound) {
			[self setStatus: i];
			return [self status];
		}
	}
	LLLog(@"MetaServerEntry.setStatusWithString extracting status from [%@] failed", line);
	return ERROR;
}

- (void) setGameType:(enum ServerGameType)newType {
	type = newType;
}

- (void) setHasRSA:(bool)newRsa {
	rsa = newRsa;
}

// getters
- (NSString*) address {
	return address;
}

- (int) port {
	return port;
}

- (int) time {
	return time;
}

- (int) players {
	return players;
}

- (enum ServerStatusType) status {
	return status;
}

- (NSString*) statusString {
	
    switch (status) {
        case OPEN:
            return @"Open";
            break;
        case WAIT:
            return @"Wait";
            break;
        case NOBODY:
            return @"Nobody";
            break;
        case TIME_OUT:
            return @"Time Out";
            break;
        case NO_CONNECT:
            return @"No Connection";
            break;
        case NO_VALUE:
            return @"No Value";
            break;
        case DEFAULT:
            return @"DEFAULT";
            break;
        case CANNOT_CONNECT:
            return @"Cannot Connect";
            break;  
		case RENDEZVOUS:
            return @"RENDEZVOUS";
            break; 
        default:
            return @"ERROR";
            break;
    }
}

- (NSString*) gameTypeString {
	
    switch (type) {
		case BRONCO:
			return @"Bronco";
			break;
		case PARADISE:
			return @"Paradise";
			break;
		case HOCKEY:
			return @"Hockey";
			break;        
		default:
			return @"Unknown";
			break;
    }
}

- (enum ServerGameType) gameType {
	return type;
}

- (bool) hasRSA {
	return rsa;
}

@end
