//-------------------------------------------
// File:  MetaServerParser.m
// Class: MetaServerParser
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
 
#import "MetaServerParser.h"

 
@implementation MetaServerParser

- (NSMutableArray *) readFromMetaServer:(NSString *) server atPort:(int)port {
		
    NSMutableArray *entries = nil;
    
	LLLog(@"MetaServerParser.readFromMetaServer %@", server);
	
    // connect and create a stream
    LLTCPSocket *socket = [[LLTCPSocket alloc] init];
    LLHost *hostName = [LLHost hostWithName:server];
	//[socket setBlocking:NO];  // dont wait when connecting to server
    [socket connectToHost:hostName port:port];
    LLSocketStream *stream = [LLSocketStream streamWithSocket:socket];
	[stream setBlocking:YES]; // we want to wait ???

	entries = [self parseInputFromStream:stream];
    
    return entries;
}
	
- (NSMutableArray *) parseInputFromStream:(LLSocketStream *) stream  {
    
    NSMutableArray *entries = [[NSMutableArray alloc] init];
    
	// add the default server
	MetaServerEntry *entry = [[MetaServerEntry alloc] init]; 
	
	/* debug only
    [entry setAddress: @"192.168.1.6"];
    [entry setPort:    2592];
    [entry setStatus:  DEFAULT];
    [entry setGameType:    BRONCO];	
    [entries addObject:entry];  */
	LLLog(@"MetaServerParser.parseInputFromStream started");
	
    NSString *line = nil;
	
	@try {
		line = [stream readLine];
	}
	@catch (NSException * e) {
		LLLog(@"MetaServerParser.parseInputFromStream: error %@", [e reason]);
		line = nil;
	}
	
    while (line != nil) {
        // make sure this is a line with server info on it
		//LLLog(@"MetaServerParser.parseInputFromStream: [%@], size %d", line, [line length]);
        if ([line length] == 79 && 
            [[line substringWithRange:NSMakeRange(0,3)] isEqualToString:@"-h "] && 
            [[line substringWithRange:NSMakeRange(40, 3)] isEqualToString:@"-p "]) {
            
			entry = [[[MetaServerEntry alloc] init] autorelease];
			[entry setAddress: [line substringWithRange:NSMakeRange(3, 36)]];
            
            // !! strip off trailing spaces
            NSMutableString *address = [NSMutableString stringWithString:[entry address]];
            [address replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [address length])];
            [entry setAddress:address];
            
			// TODO: Handle NumberFormatExceptions
            [entry setPort: [[line substringWithRange:NSMakeRange(43, 5)] intValue]];
            [entry setTime: [[line substringWithRange:NSMakeRange(49, 3)] intValue]];
                
            [entry setStatus: CANNOT_CONNECT];
            [entry setStatusWithString:[line substringWithRange:NSMakeRange(54, 17)]];

            if ([entry status] == CANNOT_CONNECT) {
                // break the while loop
				line = nil;
                continue;
            }

			// parse the number of players if this server has any players
            
			if ([entry status] == OPEN || [entry status] == WAIT) {
				// TODO: Handle FormatErrors here too
                [entry setPlayers:[[line substringWithRange:NSMakeRange(59, 3)] intValue]];
			}        

			// read the flags
            [entry setHasRSA: NO];
            if ([[line substringWithRange:NSMakeRange(74,1)] isEqualToString: @"R"]) {
                [entry setHasRSA: YES];
            }
			[entry setGameTypeWithString: [line substringWithRange:NSMakeRange(78,1)]];
				
			// don't list paradise servers
			if (([entry gameType] != PARADISE) && ([entry status] != TIME_OUT)){
                [entries addObject:entry]; 

			}			
		}
		
		@try {
			line = [stream readLine];
		}
		@catch (NSException * e) {
			LLLog(@"MetaServerParser.parseInputFromStream: error %@", [e reason]);
			line = nil;
		}
    }
	return entries;

}
 
@end
