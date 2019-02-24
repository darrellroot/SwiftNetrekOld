//
//  ServerReaderUdp.m
//  MacTrek
//
//  Created by Aqua on 06/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "ServerReaderUdp.h"


@implementation ServerReaderUdp

- (id) init {
    self = [super init];
    if (self != nil) {
        udpSocket = nil; // very bad if it stays that way
        udpStats = nil;
		sequenceCheck = YES;
    }
    return self;
}

- (id)initWithUniverse:(Universe*)newUniverse communication:(Communication*)comm socket:(LLUDPSocket *)socket udpStats:(UdpStats*)stats{
    self = [self initWithUniverse:newUniverse communication:comm];
    if (self != nil) {
        udpStats = stats;
        udpSocket = socket;
		[udpSocket setReadBufferSize:SRV_UDP_MAX_DATA_LENGTH];
		sequenceCheck = YES; // twice since i am not sure init is called
    }
    return self;
}

- (void) setSequenceCheck:(bool)newValue {
	sequenceCheck = newValue;
}

- (void) close {
    [udpSocket release];
    udpSocket = nil;
}

-(UdpStats*)udpStats {
    return udpStats;
}

- (LLUDPSocket *)udpSocket {
	return udpSocket;
}

- (NSData *) doRead {
    // read what ever is there max 1300 bytes
    // needs to be retained/released after processing !
    NSMutableData *data = [[NSMutableData dataWithLength: SRV_UDP_MAX_DATA_LENGTH] autorelease];
    // Have to set the data to its maximum length.  Otherwise,
    // when we come around this loop multiple times, the setLength:
    // below might be lengthening the data which would cause NSData
    // to zero out all of the bytes between the old length and the
    // new length.
    [data setLength: SRV_UDP_MAX_DATA_LENGTH];
	
    // try to read
	// wait with timeout if needed
    if (timeOut > 0.0) {
		if ([udpSocket waitForReadableWithTimeout:timeOut] == NO) {
			// there might simply be no data
			//LLLog(@"ServerReaderUdp.doRead TIMEOUT! more than %f sec passed", timeOut);
			return nil;
		}
	}	
		
	// actual read
    @try {        
        int length = [udpSocket readData:data];
        [data setLength: length]; 
    }
    @catch (NSException * e) {
        LLLog(@"ServerReaderUdp.doRead: Timed out waiting for UDP response from server");
        // error, switch to TCP just like when the server asks us to
        [communication setCommMode: COMM_TCP];
        [communication setCommStatus: STAT_CONNECTED];
        LLLog(@"ServerReaderUdp.doRead: Should connected to server's TCP port");
        [notificationCenter postNotificationName:@"SP_UDP_SWITCHED_TO_TCP" object:self userInfo:nil];
        
        return nil;
    }
    
    // debug
    LLLog([NSString stringWithFormat: @"ServerReaderUpd.doRead got packet from %@:%d:\n", 
        [udpSocket remoteHost], [udpSocket remotePort]]);
    
    return data;
}

- (bool) handlePacket:(int)ptype withSize:(int)size inBuffer:(char *)buffer {

	LLLog(@"ServerReaderUDP.handlePacket: %d", ptype);
    [communication increasePacketsReceived];
    return [super handlePacket:ptype withSize:size inBuffer:buffer];
}


- (void) handleSequence:(char *) buffer {
    [udpStats increaseUdpTotalBy:1];
    [udpStats increaseRecentCountBy:1];
    
    // update percent display every 256 updates (~50 seconds usually)
    if (([udpStats udpTotal] & 0xFF) == 0) {
        [notificationCenter postNotificationName:@"SRU_UDP_STATS_CHANGED" 
                                          object:self userInfo:udpStats];
    }
    
    // it's in my parent but not declared..... 
    // thus a warning
    int new_sequence = shortFromPacket(buffer, 2);
    
    if ([udpStats sequence] > 65000 && new_sequence < 1000) {
        // we rolled, set new_sequence = 65536 + sequence and accept it
        [udpStats setSequence: (([udpStats sequence] + 65536) & 0xFFFF0000) | new_sequence];
    }
    else {
        // adjust new_sequence and do compare
        new_sequence |= ([udpStats sequence] & 0xFFFF0000);
        
		if (sequenceCheck == NO) {
			// put this here so that turning seq check on and off doesn't
			// make us think we lost a whole bunch of packets.
			[udpStats setSequence:new_sequence];
			return;			
		}
		
        if (new_sequence > [udpStats sequence]) {
            // accept
            if (new_sequence != [udpStats sequence] + 1) {
                int diff = (new_sequence - [udpStats sequence]) - 1;
                [udpStats increaseUdpDroppedBy:diff];
                [udpStats increaseUdpTotalBy:diff];		// want TOTAL packets
                [udpStats increaseRecentDroppedBy:diff];
                [udpStats increaseRecentCountBy:diff];
                [notificationCenter postNotificationName:@"SRU_UDP_STATS_LOST_SOME" 
                                                  object:self userInfo:udpStats];
            }
            [udpStats setSequence: new_sequence];
            // S_P2
            if ([communication shortVersion] == COMM_SHORTVERSION && [communication receiveShort]) {
                Player *me = [universe playerThatIsMe];
                [me setFlags: ([me flags] & 0xFFFF00FF) | (buffer[1] & 0xFF) << 8];
            }            
            else {
                // reject
                /*
                if (buffer[0] == SP_SC_SEQUENCE) {
                    if(Communications.UDP_DIAG) 
                        System.out.println("(ignoring repeat " + new_sequence + ')');
                }
                 else {
                     if(Communications.UDP_DIAG) 
                         System.out.println("sequence=" + sequence + ", new_sequence=" + new_sequence + ", ignoring transmission");
                 } */
                // the remaining packets will be dropped and we shouldn't count the SP_SEQUENCE packet either
                [communication decreasePacketsReceived];
                LLLog(@"ServerReaderUdp.handleSequence: rejected out of sequence packet");
            }
        }
        if ([udpStats recentCount] > UDP_RECENT_INTR) {
            // once a minute (at 5 upd/sec), report on how many were dropped
            // during the last UDP_RECENT_INTR updates 
            [udpStats setUdpRecentDropped:[udpStats recentDropped]];
            [udpStats setRecentCount:0];
            [udpStats setRecentDropped:0];
            [notificationCenter postNotificationName:@"SRU_UDP_STATS_CHANGED" 
                                              object:self userInfo:udpStats];
        }
    }
}


@end
