//-------------------------------------------
// File:  MetaServerEntry.h
// Class: MetaServerEntry
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
 
#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"

// enum type of the different stati
enum ServerStatusType {
    OPEN = 0, 
    WAIT = 1,    
    NOBODY = 2,
    TIME_OUT = 3,
    NO_CONNECT = 4,
    NO_VALUE = 5,  
    CANNOT_CONNECT = 6, 
    DEFAULT = 7,
    ERROR = 8, 
	RENDEZVOUS = 9
};

enum ServerGameType {
    BRONCO = 0,
    PARADISE = 1,
    HOCKEY = 2,
    UNKNOWN = 3
};

@interface MetaServerEntry: SimpleBaseClass {
   
    // array of possible return values, matches ServerStatusType
    NSArray *statusStrings;
    
    // my data
    NSString *address;
    int port;
    int time;
    int players;
    enum ServerStatusType status;
    bool rsa;
    enum ServerGameType type; 
} 

// setters
- (void) setAddress:(NSString*) address;
- (void) setPort:(int)port;
- (void) setTime:(int)time;
- (void) setPlayers:(int)players;
- (void) setStatus:(enum ServerStatusType)status;
- (void) setGameType:(enum ServerGameType)type;
- (enum ServerStatusType) setStatusWithString:(NSString *) line;
- (enum ServerGameType) setGameTypeWithString:(NSString *) line;
- (void) setHasRSA:(bool)rsa;

// getters
- (NSString*) address;
- (int) port;
- (int) time;
- (int) players;
- (enum ServerStatusType) status;
- (NSString*) statusString;
- (enum ServerGameType) gameType;
- (NSString*) gameTypeString;
- (bool) hasRSA;

@end
