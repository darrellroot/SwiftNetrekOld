//-------------------------------------------
// File:  ServerReader.m
// Class: ServerReader
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
 
#import "ServerReader.h"
#import "PacketTypesDebug.h"
 
 
@implementation ServerReader

// some globals
int NUMOFBITS[256] = {
    0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6, 
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7, 
    4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
};  
// sizes of variable torpbuffers 
int VTSIZE[] = {
    4, 8, 8, 12, 12, 16, 20, 20, 24
};        
// 4 byte Header + torpdata
int VTISIZE[] = {
    4, 7, 9, 11, 13, 16, 18, 20, 22
};
//-
int PACKET_SIZES[] = {
    0,		// NULL
    84,		// SP_MESSAGE
    4,		// SP_PLAYER_INFO
    8,		// SP_KILLS
    12,		// SP_PLAYER
    8,		// SP_TORP_INFO
    12,		// SP_TORP
    16,		// SP_PHASER
    8,		// SP_PLASMA_INFO
    12,		// SP_PLASMA
    84,		// SP_WARNING
    84,		// SP_MOTD
    32,		// SP_YOU
    4,		// SP_QUEUE
    28,		// SP_STATUS
    12,		// SP_PLANET
    4,		// SP_PICKOK
    104,		// SP_LOGIN
    8,		// SP_FLAGS
    4,		// SP_MASK
    4,		// SP_PSTATUS
    4,		// SP_BADVERSION
    4,		// SP_HOSTILE
    56,		// SP_STATS
    52,		// SP_PL_LOGIN
    20,		// SP_RESERVED
    28,		// SP_PLANET_LOC
    0,		// SP_SCAN
    8,		// SP_UDP_REPLY
    4,		// SP_SEQUENCE
    4,		// SP_SC_SEQUENCE
    36,		// SP_RSA_KEY
    12,		// SP_MOTD_PIC
    0,		// 33
    0,		// 34
    0,		// 35
    0,		// 36
    0,		// 37
    0,		// 38
    60,		// SP_SHIP_CAP
    8,		// SP_S_REPLY
    -1,		// SP_S_MESSAGE
    -1,		// SP_S_WARNING
    12,		// SP_S_YOU
    12,		// SP_S_YOU_SS
    -1,		// SP_S_PLAYER
    8,		// SP_PING
    -1,		// SP_S_TORP
    -1,		// SP_S_TORP_INFO
    20,		// SP_S_8_TORP
    -1,		// SP_S_PLANET
    0,		// 51
    0,		// 52
    0,		// 53
    0,		// 54
    0,		// 55
    0,		// SP_S_SEQUENCE
    -1,		// SP_S_PHASER
    -1,		// SP_S_KILLS
    36,		// SP_S_STATS
    88,		// SP_FEATURE
    524		// SP_BITMAP
};

PacketTypesDebug *pktConv;
NSMutableData *leftOverPacket;

- (id) init {
    self = [super init];
    if (self != nil) {
        // packet debugger
        pktConv = [[PacketTypesDebug alloc] init];
        [pktConv setDebugPackets:YES]; // set to yes to see a dump of all packets 
        leftOverPacket = nil;
        // number of bits per byte

        // parsing message of the day
        motd_done = NO;
    }
    return self;
}

- (id)initWithUniverse:(Universe*)newUniverse communication:(Communication*)comm {
    self = [self init];
    if (self != nil) {
        universe = newUniverse;
        [universe retain];
        communication = comm;
    }
    return self;
}

- (void) close {
    LLLog(@"ServerReader.close this should have been overwritten");
}

- (NSData *) doRead {
    LLLog(@"ServerReader.doRead this should have been overwritten");
    return nil;
}

- (void) readFromServer {
    
    NSData *dataReceived = [self doRead];	 
    if (dataReceived == nil) {  
		//LLLog(@"ServerReader.readFromServer nil bytes");
        return;
    }
	//LLLog(@"ServerReader.readFromServer %d bytes", [dataReceived length]);
    
    int count = 0;
    char *buffer = nil;
    
    // check for leftovers
    if (leftOverPacket != nil) {
        //LLLog(@"ServerReader.readFromServer pre-pending %d bytes", [leftOverPacket length]);
        [leftOverPacket appendData:dataReceived];
        
        count = [leftOverPacket length];
        buffer = (char*)[leftOverPacket bytes];

    } else {
        count = [dataReceived length];
        buffer = (char*)[dataReceived bytes];
    }
  
    while(count > 0)  {
        // the first char in the buffer should tell us the type of the message
        int ptype = buffer[0] & 0xFF;
        if(ptype < 1 || ptype > SP_BITMAP) {
            
            // debug THIS we want to see!
            LLLog(@"ServerReader.readFromServer received message: %@ (%d), count: %d", 
                  [pktConv serverPacketString:buffer[0]], buffer[0], count);
            bool oldSetting = [pktConv debugPackets];
            [pktConv setDebugPackets:YES];
            [pktConv printPacketInBuffer:buffer size:count];
            [pktConv setDebugPackets:oldSetting];
            
            // continue
            LLLog(@"ServerReader.readFromServer: Unknown packet type. Flushing packet buffer & input stream.");
            LLLog([NSString stringWithFormat:@"ServerReader.readFromServer: Last packet type: %d", ptype]);
            // flush
            count = 0;
            buffer = nil;
            [leftOverPacket release];
            return;
        }
        
        int size = PACKET_SIZES[ptype];
        // ------
		// DEBUG (generates lots of data !)
		// ------
        //LLLog(@"ServerReader.readFromServer received message: %@ (%d), size %d buffer size: %d", [pktConv serverPacketString:buffer[0]], buffer[0], size, count);
        //[pktConv printPacketInBuffer:buffer size:size];
        // ------
		
        // handle variable buffer packets first
        // determine the size of the packet before we can handle it
		if (size == -1) {
            if(count < 4) {
                LLLog(@"ServerReader.readFromServer: variable buffer too small");
				return;
            }
            
            switch(ptype) {
				case SP_S_MESSAGE:
					size = buffer[4] & 0xFF;
					break;
				case SP_S_WARNING:
					if(buffer[1] == STEXTE_STRING ||
                       buffer[1] == SHORT_WARNING) { 						
						size = buffer[3] & 0xFF;
					} 
					else {
						size = 4;	// Normal Packet
					}
					break;
				case SP_S_PLAYER:
					if((buffer[1] & 0x80) != 0) { 
						// Small + extended Header
						size = (buffer[1] & 0x3F) * 4 + 4;							
					} 
					else if((buffer[1] & 0x40) != 0) {	
						// Small Header
						if ([communication shortVersion] == SHORTVERSION) {
							size = (buffer[1] & 0x3F) * 4 + 4 + (buffer[2] & 0xFF) * 4;
						}
						else {
							size = (buffer[1] & 0x3F) * 4 + 4;
						}
					} 
					else {  
						// Big Header
						size = (buffer[1] & 0xFF) * 4 + 12;
					}
					break;
				case SP_S_TORP:
					size = VTSIZE[NUMOFBITS[buffer[1] & 0xFF]];
					break;
				case SP_S_TORP_INFO :
					size = VTISIZE[NUMOFBITS[buffer[1] & 0xFF]] + NUMOFBITS[buffer[3] & 0xFF];
					break;
				case SP_S_PLANET:
					size = (buffer[1] & 0xFF) * 6 + 2;
					break;
				case SP_S_PHASER:	// S_P2
					switch(buffer[1] & 0x0F) {
					case PHASER_FREE :
					case PHASER_HIT :
					case PHASER_MISS :
					   size = 4;
					   break;
					case PHASER_HIT2 :
					   size = 8;
					   break;
					default:
					   size = 12;
					   break;
					}
					break;
				case SP_S_KILLS :
					size = (buffer[1] & 0xFF) * 2 + 2;
					break;
				default:					
					LLLog([NSString stringWithFormat:@"ServerReader.readFromServer: Unknown variable buffer: %c", ptype]);
					return;
            }
            // stuff some bits to make it fit in an integer
			if ((size % 4) != 0) {
                size += (4 - (size % 4));
            }
            if (size <= 0) {
                LLLog([NSString stringWithFormat:@"ServerReader.readFromServer: bad size: %d", size]);
				LLLog([NSString stringWithFormat:@"ServerReader.readFromServer: for packet type: %c", ptype]);
				return;
            }
        }
        
        // we have the size and the packettype, now handle it
        if(count < size) {
            //LLLog(@"ServerReader.readFromServer message %d only %d of %d bytes in buffer, preserving", ptype, count, size);
            [leftOverPacket release];
            leftOverPacket = [NSMutableData dataWithBytes:buffer length:count];
            [leftOverPacket retain];
			return;
        }		
        
        // during the handling we cannot allow others to modify or access
        // the universal data
		if ([[universe synchronizeAccess] lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
			// directly unlock, we wait for the painter, but the painter does not wait for us
			[[universe synchronizeAccess] unlock];
		}

        bool result = [self handlePacket:ptype withSize:size inBuffer:buffer];
        
        if (result) {
            // successfull? then on to the next
            count -= size;
            
            // move on!
            buffer += size;
        } else {
            LLLog(@"ServerReader.readFromServer packet %d was not handled correctly", buffer[0]);
        }
        
        // exact fit in frame, no leftover
		if (leftOverPacket != nil) {
			[leftOverPacket release];
		}        
        leftOverPacket = nil;
    }
	
	// report end of read cycle, COW will redraw screen now
	[notificationCenter postNotificationName:@"SERVER_READER_READ_SYNC"];
}


/*******************************************/
/* support functions, direct copy from COW */
/*******************************************/

/** intFromPacket */
int intFromPacket(char *buffer, int offset) {
	return (buffer[offset] & 0xFF) << 24 | (buffer[offset + 1] & 0xFF) << 16 
    | (buffer[offset + 2] & 0xFF) << 8 | buffer[offset + 3] & 0xFF;
}

/** shortFromPacket */
int shortFromPacket(char *buffer, int offset) {	
	return (buffer[offset] & 0xFF) << 8 | buffer[offset + 1] & 0xFF;
}

/** newFlags */
-(void) newFlags:(int)dat target:(int)which {
    int status;
    int new_flags_set;
    Player *player;
    for(int pnum = which * 16; pnum < (which + 1) * 16 && pnum < [universe playerCount]; ++pnum) {
        
        new_flags_set = dat & 0x03;
        dat >>= 2;
        
        player = [universe playerWithId: pnum];
        if([player status] == PLAYER_FREE) {
            continue;
        }
        
        switch(new_flags_set) {
			case 0 :	// DEAD/EXPLODE
				status = PLAYER_EXPLODE;
				[player setFlags: [player flags] & ~PLAYER_CLOAK];
				break;
			case 1 :	// ALIVE & CLOAK
				status = PLAYER_ALIVE;
				[player setFlags: [player flags] | PLAYER_CLOAK];
				break;
			case 2 :	// ALIVE & SHIELD
				status = PLAYER_ALIVE;
				[player setFlags: [player flags] | PLAYER_SHIELD];
				[player setFlags: [player flags] & ~PLAYER_CLOAK];
				break;
			case 3 :	// ALIVE & NO shields
				status = PLAYER_ALIVE;
				[player setFlags: [player flags] & ~(PLAYER_SHIELD | PLAYER_CLOAK)];
				break;
			default:
				status = 0;
				break;
        }
        
        if ([player status] == status) {
            continue;
        }
        
        if (status == PLAYER_EXPLODE) {
            if ([player status] == PLAYER_ALIVE) {
                [player setExplode: 0];
                [player setStatus: status];
            }
        } 
        else {
            if([player isMe]) {
                // Wait for PLAYER_OUTFIT $$
				// i wonder if this is correct! PLAYER_OUTFIT should generate a 
				// [notificationCenter postNotificationName:@"CC_GO_OUTFIT"	object:self userInfo:nil];
				// to get the outfit panel again
                if ([player status] == PLAYER_OUTFIT || [player status] == PLAYER_FREE) {
                    [player setStatus: PLAYER_ALIVE];
                }
            }
            else {
                [player setStatus: status];			
            }
        }
    }
}	


// too big to be in switch
-(void) handleUdpReply:(char*) buffer {
    
    LLLog([NSString stringWithFormat:@"ServerReader.handleUdpReply: UDP: Received UDP reply %d", (buffer[1])]);
    
    switch (buffer[1] & 0xFF) {
        case SWITCH_TCP_OK:
            if ([communication commMode] == COMM_TCP) {
                LLLog(@"ServerReader.handleUdpReply: Got SWITCH_TCP_OK while in TCP mode; ignoring");
            }
            else {
                [communication setCommMode: COMM_TCP];
                [communication setCommStatus: STAT_CONNECTED];
                LLLog(@"ServerReader.handleUdpReply: Connected to server's TCP port");
				// close UDP in comm
                [notificationCenter postNotificationName:@"SP_UDP_SWITCHED_TO_TCP" object:self userInfo:nil];
            }
            break;
        case SWITCH_UDP_OK:
            if ([communication commMode] == COMM_UDP) {
                LLLog(@"ServerReader.handleUdpReply: Got SWITCH_UDP_OK while in UDP mode; ignoring");
            }
            else {
                // the server is forcing UDP down our throat?
                if ([communication commModeRequest] != COMM_UDP) {
                    LLLog(@"ServerReader.handleUdpReply: Got unsolicited SWITCH_UDP_OK; ignoring");
                }
                else {
                    
                    [communication setCommMode: COMM_UDP];
                    [communication setCommStatus: STAT_VERIFY_UDP];    
                    int port = intFromPacket(buffer, 4);
					[communication connectToServerUdpAtPort:port];
					LLLog(@"ServerReader.handleUdpReply: Connected to server's UDP port %d", port);

					//[communication sendUdpVerify:self];  use a notification for taht
                    
					[notificationCenter postNotificationName:@"SP_TCP_SWITCHED_TO_UDP" 
                                                      object:self 
                                                    userInfo:[NSNumber numberWithInt:port]];
                }
            }
            break;
        case SWITCH_DENIED:     
            // look for some scary bits in the reason byte
            if (intFromPacket(buffer, 4) == 0) {
                LLLog(@"ServerReader.handleUdpReply: Switch to UDP failed (different version)");
            }
            else {
                LLLog(@"ServerReader.handleUdpReply: Switch to UDP denied");
            }
            // reset mode request to org mode
            [communication setCommModeRequest:[communication commMode]];
            [communication setCommStatus: STAT_CONNECTED];
            /* communication should close the udp on reception of the event
            actually, it is strange because you do not know if you switched to TCP or UDP.....
            comm.closeUdpConn(); */
            [notificationCenter postNotificationName:@"SP_SWITCHED_DENIED" object:self userInfo:nil];            
            break;
        case SWITCH_VERIFY:
            [notificationCenter postNotificationName:@"SP_SWITCH_VERIFY" object:self userInfo:nil];
            LLLog(@"ServerReader.handleUdpReply: Received UDP verification");
            // This is here because I noticed player stats weren't being 
            // updated unless I sent this request manually
            [notificationCenter postNotificationName:@"SP_ASK_FOR_COMM_UPDATE" object:self userInfo:nil];
			break;
        default:
            LLLog([NSString stringWithFormat: @"ServerReader.handleUdpReply: Got funny reply (%c) in UDP_REPLY packet",
                (buffer[1])]);
            break;
    }
}


// way too big for switch
// even too big for one method, moved some to newFlags
-(void) handleVPlayer:(char *)buffer {
    int x, y, player_index, save;
    Player *player;
    int numofplayers = buffer[1] & 0x3F;
    
    int pos = 0;
    
    // $$$ CORRUPTED_PACKETS
    // should do something clever here - jmn if(pl_no < 0 || pl_no >= MAXPLAYER){ return; }
    
    // $$ MAXPLAYER > 32 WAS HERE
    if ((buffer[1] & 0x40) != 0) {								// Short Header
        if ([communication shortVersion] == SHORTVERSION) {				// flags S_P2
            if (buffer[2] == 2) {
                [self newFlags: intFromPacket(buffer, 4) target:buffer[3] & 0xFF];
                [self newFlags: intFromPacket(buffer, 8) target: 0];
                pos += 8;
            }
            else if (buffer[2] == 1) {
                [self newFlags: intFromPacket(buffer, 4) target: buffer[3] & 0xFF];
                pos += 4;
            }
        }
        pos += 4;
        for(int p = 0; p < numofplayers; p++) {
            player_index = buffer[pos] & 0x1F;
            if(player_index >= [universe playerCount]) {
                continue;
            }
            save = buffer[pos];
            pos++;
            player = [universe playerWithId:player_index];
            
            // SPEED
            [player setSpeed: (buffer[pos] & 0x0F)];
            // freaky bit stuff
            FeatureList *fList = [communication featureList];                
            if([player isMe] && [fList valueForFeature: FEATURE_LIST_CLOAK_MAXWARP] != FEATURE_OFF) {
                if([player speed] == 0xF) {
                    [player setFlags: [player flags] | PLAYER_CLOAK];
                }
                else if(([player flags] & PLAYER_CLOAK) != 0) {
                    [player setFlags: [player flags] & ~PLAYER_CLOAK];
                }
            }
            
            // realDIR
            [player setNetrekFormatCourse: ((buffer[pos] & 0xFF) >> 4) * 16];
            pos++;
            x = buffer[pos] & 0xFF;
            pos++;
            y = buffer[pos] & 0xFF;
            pos++;
            
            // The lower 8 Bits are saved
            // Now we must preprocess the coordinates
            NSPoint position;
            if((save & 0x40) != 0) {
                x |= 0x100;
            }
            if((save & 0x80) != 0) {
                y |= 0x100;
            }
            // Now test if it's galactic or local coord
            if((save & 0x20) != 0) { 
                // It's galactic
                if (x == 501 || y == 501) {
                    x = -500;
                    y = -500;
                }
                
                // galactic coordinates are global
                position.x = x * (UNIVERSE_PIXEL_SIZE / SPWINSIDE);
                position.y = y * (UNIVERSE_PIXEL_SIZE / SPWINSIDE);
            }
            else { 
                // Local coordinates are relative to my position
                // recalculate to galactic
                Player *me = [universe playerThatIsMe];
                NSPoint myPos = [me position];
                position.x = myPos.x + ((x - SPWINSIDE / 2) * UNIVERSE_SCALE);
                position.y = myPos.y + ((y - SPWINSIDE / 2) * UNIVERSE_SCALE);
            }            
            [player setPosition:position];
            /*
             Point point = Rotate.rotateCoord(
                                              player.x,
                                              player.y,
                                              data.rotate,
                                              Universe.HALF_PIXEL_SIZE,
                                              Universe.HALF_PIXEL_SIZE);
             
             player.x = point.x;
             player.y = point.y;
             
             player.dir = Rotate.rotateDir(player.dir, data.rotate);
             */
            [notificationCenter postNotificationName:@"SP_V_PLAYER" object:self userInfo:player];     
        }
    }
    else { // Big Packet
        
        player = [universe playerThatIsMe];
        [player setNetrekFormatCourse:buffer[2] & 0xFF];
        [player setSpeed: buffer[3] & 0xFF];
        
        // freaky bit stuff
        FeatureList *fList = [communication featureList];                
        if([fList valueForFeature: FEATURE_LIST_CLOAK_MAXWARP] != FEATURE_OFF) {
            if([player speed] == 0xF) {
                [player setFlags: [player flags] | PLAYER_CLOAK];
            }
            else if(([player flags] & PLAYER_CLOAK) != 0) {
                [player setFlags: [player flags] & ~PLAYER_CLOAK];
            }
        }
        
        NSPoint position;
        if ([communication shortVersion] == SHORTVERSION) {	// S_P2            
            position.x = UNIVERSE_SCALE * shortFromPacket(buffer, 4);
            position.y = UNIVERSE_SCALE * shortFromPacket(buffer, 6);            
            [self newFlags: intFromPacket(buffer, 8) target: 0];
        }
        else {	// OLDSHORTVERSION
            position.x = intFromPacket(buffer, 4);
            position.y = intFromPacket(buffer, 8);
        }
        [player setPosition:position];
        
        /*
         Point point = Rotate.rotateCoord(
                                          player.x,
                                          player.y,
                                          data.rotate,
                                          Universe.HALF_PIXEL_SIZE,
                                          Universe.HALF_PIXEL_SIZE);
         
         player.x = point.x;
         player.y = point.y;
         
         player.dir = Rotate.rotateDir(player.dir, data.rotate); 
         */
        
        if (buffer[1] == 0) {
            return;
        }
        pos += 12;
        
        // Now the small packets
        for(int p = 0; p < [universe playerCount]; ++p) {
            player_index = buffer[pos] & 0x1F;
            if (player_index >= [universe playerCount]) {
                continue;
            }
            save = buffer[pos];
            pos++;
            player = [universe playerWithId:player_index];
			
            // SPEED
            [player setSpeed: buffer[pos] & 0xFF];
            
            // freaky bit stuff
            FeatureList *fList = [communication featureList];                
            if([player isMe] && [fList valueForFeature: FEATURE_LIST_CLOAK_MAXWARP] != FEATURE_OFF) {
                if([player speed] == 0xF) {
                    [player setFlags: [player flags] | PLAYER_CLOAK];
                }
                else if(([player flags] & PLAYER_CLOAK) != 0) {
                    [player setFlags: [player flags] & ~PLAYER_CLOAK];
                }
            }
            
            // realDIR
            [player setNetrekFormatCourse: ((buffer[pos] & 0xFF) >> 4) * 16];
            pos++;
            x = buffer[pos] & 0xFF;
            pos++;
            y = buffer[pos] & 0xFF;
            pos++;
            
            // The lower 8 Bits are saved
            // Now we must preprocess the coordinates
            NSPoint position;
            if((save & 0x40) != 0) {
                x |= 0x100;
            }
            if((save & 0x80) != 0) {
                y |= 0x100;
            }
            // Now test if it's galactic or local coord
            if((save & 0x20) != 0) { 
                // It's galactic
                if (x == 501 || y == 501) {
                    x = -500;
                    y = -500;
                }
                
                // galactic coordinates are global
                position.x = x * (UNIVERSE_PIXEL_SIZE / SPWINSIDE);
                position.y = y * (UNIVERSE_PIXEL_SIZE / SPWINSIDE);
            }
            else { 
                // Local coordinates are relative to my position
                // recalculate to galactic
                Player *me = [universe playerThatIsMe];
                NSPoint myPos = [me position];
                position.x = myPos.x + ((x - SPWINSIDE / 2) * UNIVERSE_SCALE);
                position.y = myPos.y + ((y - SPWINSIDE / 2) * UNIVERSE_SCALE);
            }            
            [player setPosition:position];
            /*
             Point point = Rotate.rotateCoord(
                                              player.x,
                                              player.y,
                                              data.rotate,
                                              Universe.HALF_PIXEL_SIZE,
                                              Universe.HALF_PIXEL_SIZE);
             
             player.x = point.x;
             player.y = point.y;
             
             player.dir = Rotate.rotateDir(player.dir, data.rotate);
             */
            [notificationCenter postNotificationName:@"SP_V_PLAYER" object:self userInfo:player];   
        } 
    }
}

/** handleVTorp */
-(void) handleVTorp:(char*)buffer {
    
    int torp_index = 0;
    int bitset;						// bit=1 that torp is in packet
    int dx;
    int dy;
    int shiftvar;
    int torp_data_pos;
    
    if(buffer[0] == SP_S_8_TORP) { // MAX packet
        bitset = 0xFF;
        torp_index = (buffer[1] & 0xFF) * 8;
        torp_data_pos = 2;
    }       
    else { // Normal packet
        bitset = buffer[1];
        torp_index = (buffer[2] & 0xFF) * 8;
        torp_data_pos = 3;
    }
    
    int shift = 0;
    Torp *torp;
    
    for(int t = 0; t < 8; ++t, ++torp_index, bitset >>= 1) {
        torp = [universe torpWithId:torp_index];
        
        if((bitset & 0x01) != 0) {
            // extract the x coordinates from the bits
            dx = ((buffer[torp_data_pos] & 0xFF) >> shift);
            shiftvar = (buffer[++torp_data_pos] & 0xFF) << (8 - shift);
            dx |= (shiftvar & 0x1FF);
            shift++;
            
            // extract the y coordinates from the bits
            dy = ((buffer[torp_data_pos] & 0xFF) >> shift);
            shiftvar = (buffer[++torp_data_pos] & 0xFF) << (8 - shift);
            dy |= (shiftvar & 0x1FF);
            shift++;
            
            if (shift == 8) {
                shift = 0;
                ++torp_data_pos;
            }
            
            // This is necessary because TORP_FREE/TORP_MOVE is now encoded in the bitset
            if ([torp status] == TORP_FREE) {
                // guess
                [torp setStatus: TORP_MOVE];
            }
            else if ([[torp owner] isMe] && [torp status] == TORP_EXPLODE) {
                [torp setStatus: TORP_MOVE];
            }
            
            NSPoint pos;
            // Check if torp is visible
            if (dx > SPWINSIDE || dy > SPWINSIDE) { // Not visible
                pos.x = -100000;
                pos.y = -100000;
            }
            else { // visible
                   // Rotate coordinates
                /*
                 Point point = Rotate.rotateCoord(
                                                  my_x + ((dx - SPWINSIDE / 2) * UNIVERSE_SCALE),
                                                  my_y + ((dy - SPWINSIDE / 2) * UNIVERSE_SCALE),
                                                  data.rotate,
                                                  Universe.HALF_PIXEL_SIZE,
                                                  Universe.HALF_PIXEL_SIZE);
                 
                 torp.x = point.x;
                 torp.y = point.y;
                 */
                pos.x = dx;
                pos.y = dy;
            }
        }
        else { // We got a TORP_FREE
            if([torp status] != TORP_FREE && [torp status] != TORP_EXPLODE) {
                [torp setStatus: TORP_FREE];
            }
        }
        [notificationCenter postNotificationName:@"SP_V_TORP" object:self userInfo:torp];   
    }
    
}

/** handleVTorpInfo */
- (void) handleVTorpInfo:(char*) buffer {
    int torp_index = 0;
    
    int dx;
    int dy;
    int shiftvar;
    int status;
    char war;
    
    int bitset = buffer[1] & 0xFF;
    torp_index = (buffer[2] & 0xFF) * 8;
    int infobitset = buffer[3] & 0xFF;
    
    int torp_data_pos = 4;
    int info_data_pos = VTISIZE[NUMOFBITS[bitset]];
    
    int shift = 0;	// How many torps are extracted (for shifting)
    
    Torp *torp;
    
    for(int t = 0; t < 8; ++t, ++torp_index, bitset >>= 1, infobitset >>= 1) {
        torp = [universe torpWithId:torp_index];
        
        if((bitset & 0x01) != 0) {
            // extract the x coordinates from the bits
            dx = ((buffer[torp_data_pos] & 0xFF) >> shift);
            shiftvar = (buffer[++torp_data_pos] & 0xFF) << (8 - shift);
            dx |= (shiftvar & 0x1FF);
            shift++;
            
            // extract the y coordinates from the bits
            dy = ((buffer[torp_data_pos] & 0xFF) >> shift);
            shiftvar = (buffer[++torp_data_pos] & 0xFF) << (8 - shift);
            dy |= (shiftvar & 0x1FF);
            shift++;
            
            if (shift == 8) {
                shift = 0;
                ++torp_data_pos;
            }
            
            // Check for torp with no TorpInfo ( In case we missed a n updateAll)
            if ((infobitset & 0x01) == 0) {
                if([torp status] == TORP_FREE) {
                    // guess
                    [torp setStatus: TORP_MOVE];
                } else if ([[torp owner] isMe] && [torp status] == TORP_EXPLODE) {
                    [torp setStatus: TORP_MOVE];
                }
            }
            NSPoint pos;
            // Check if torp is visible
            if (dx > SPWINSIDE || dy > SPWINSIDE) { // Not visible
                pos.x = -100000;
                pos.y = -100000;
            }
            else { // visible
                   // Rotate coordinates
                /*
                 Point point = Rotate.rotateCoord(
                                                  my_x + ((dx - SPWINSIDE / 2) * UNIVERSE_SCALE),
                                                  my_y + ((dy - SPWINSIDE / 2) * UNIVERSE_SCALE),
                                                  data.rotate,
                                                  Universe.HALF_PIXEL_SIZE,
                                                  Universe.HALF_PIXEL_SIZE);
                 
                 torp.x = point.x;
                 torp.y = point.y;
                 */
                pos.x = dx;
                pos.y = dy;
            }
        }
        else { // Got a TFREE ?
            if ((infobitset & 0x01) == 0) {	
                // No other TorpInfo for this Torp
                if([torp status] != TORP_FREE && [torp status] != TORP_EXPLODE) {
                    [torp setStatus: TORP_FREE];
                }
            }
        }
        // Now the TorpInfo
        if((infobitset & 0x01) != 0) {
            war = (char)(buffer[info_data_pos] & 0xF0);
            status = (buffer[info_data_pos] & 0xF0) >> 4;
            info_data_pos++;
            
            if (status == TORP_EXPLODE && [torp status] == TORP_FREE) {
                // FAT: redundant explosion; don't update p_ntorp
                continue;
            }
            [torp setWar:war];
            if(status != [torp status]) {
                // FAT: prevent explosion reset
                [torp setStatus: status];
            }
        }
        [notificationCenter postNotificationName:@"SP_V_TORP_INFO" object:self userInfo:torp];
    }
}

-(void) handleVPlanet:(char*)buffer {
    int planet_index = 0;
    bool redraw = NO;
    int numofplanets = buffer[1] & 0xFF;
    int ownerId;
    int info;
    int flags;
    int armies;
    Team *owner;
    
    Planet *planet;
    for(int pos = 2, p = 0; p < numofplanets; ++p, pos += 2) {
        planet_index = buffer[pos] & 0xFF;
        planet = [universe planetWithId: planet_index];
        redraw = NO;
        
        @try {
            // get the owner
            ownerId = buffer[++pos] & 0xFF;
            owner = [universe teamWithId:[universe remappedTeamIdWithId: ownerId]];
            if ([planet owner] != owner) {
                redraw = YES;
                [universe movePlanet:planet toTeam:owner];
                [owner addPlanet:planet];
            }
        }
        @catch (NSException * e) {
            LLLog([NSString stringWithFormat: @"ServerReader.handleVPlanet: planet owner out of bounds: ", ownerId]);
            LLLog([NSString stringWithFormat: @"ServerReader.handleVPlanet: planet : ", planet_index]);
            [universe movePlanet:planet toTeam:[universe teamWithId:TEAM_NOBODY]];
        }
        
        // get the info
        info = buffer[++pos] & 0xFF;
        if ([planet info] != info) {
            [planet setInfo: info];
            if([planet info] == 0) {
                [universe movePlanet:planet toTeam:[universe teamWithId:TEAM_NOBODY]];
            }
            redraw = YES;
        }
        
        // get the armies
        armies = buffer[++pos] & 0xFF;
        if ([planet armies] != armies
            // don't redraw when armies change unless it crosses the '4' * army limit. 
            // Keeps people from watching for planet 'flicker' when players are beaming
            && (([planet armies] < 5 && armies > 4) || ([planet armies] > 4 && armies < 5))) {
            redraw = YES;
        }
        [planet setArmies: armies];
        
        // get the flags
        flags = shortFromPacket(buffer, ++pos);
        if ([planet flags] != flags) {
            [planet setFlags: flags];
            redraw = YES;
        }
        
        if (redraw) {
            [planet setFlags: ([planet flags] | PLANET_REDRAW)];
        }
        [notificationCenter postNotificationName:@"SP_V_PLANET" object:self userInfo:planet];
    }
    
}

-(void) handleVPhaser:(char *)buffer {
    
    int pnum = buffer[2] & 0x3F;
    int x = 0;
    int y = 0;
    int dir = 0;
    int target = 0;   
    
    int status = buffer[1] & 0x0F;   
    
    Phaser *phaser = [universe phaserWithId:pnum];
    [phaser setStatus: status];
    
    switch(status) {
        case PHASER_FREE:
            break;
        case PHASER_HIT:
            target =  buffer[3] & 0x3F;
            break;
        case PHASER_MISS:
            dir = buffer[3] & 0xFF;
            break;
        case PHASER_HIT2:
            x = UNIVERSE_SCALE * shortFromPacket(buffer, 4);
            y = UNIVERSE_SCALE * shortFromPacket(buffer, 6);
            target = buffer[3] & 0x3F;
            break;
        default:
            x = UNIVERSE_SCALE * shortFromPacket(buffer, 4);
            y = UNIVERSE_SCALE * shortFromPacket(buffer, 6);
            target = buffer[3] & 0x3F;
            dir = buffer[8] & 0xFF;
            break;
    }
    
    NSPoint pos;				
    pos.x = x;
    pos.y = y;
    [phaser setPosition:pos];
    [phaser setNetrekFormatCourse:dir];    
    
    if (status != PHASER_FREE) {
        // normalized maxfuse
        Ship *ship = [universe shipWithPhaserId:pnum];
        [phaser setMaxFuse:[ship maxPhaserFuse]];
    }
    
    [phaser setTarget:[universe playerWithId:target]];
    [phaser setFuse:0];
    
    [notificationCenter postNotificationName:@"SP_V_PHASER" object:self userInfo:phaser];
    
    /* 
        Point point = Rotate.rotateCoord(
                                         x,
                                         y,
                                         data.rotate,
                                         Universe.HALF_PIXEL_SIZE,
                                         Universe.HALF_PIXEL_SIZE);
     phaser.dir = Rotate.rotateDir(dir, data.rotate); */
    
    
}

- (void) handleSequence:(char *) buffer {
    LLLog(@"ServerReader.handleSequence: SP_SEQUENCE not implemented");
}

	/** handlePacket */
- (bool) handlePacket:(int)ptype withSize:(int)size inBuffer:(char *)buffer {
        
    // check some timeing
    //NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];   
    
    //bool result = NO;
		// call the appropriate buffer handler.
		switch(ptype) {
		case SP_MESSAGE :
            @try {
                NSString *message = [self stringFromBuffer:buffer startFrom:4 maxLength:80];
                NSNumber *flags   = [NSNumber numberWithInt: buffer[1] & 0xFF];
                NSNumber *from    = [NSNumber numberWithInt: buffer[3] & 0xFF];
                NSNumber *to      = [NSNumber numberWithInt: buffer[2] & 0xFF]; 
                NSDictionary *obj = [NSDictionary dictionaryWithObjectsAndKeys:
                    message, @"message", flags, @"flags", from, @"from", to, @"to", nil];
				LLLog(@"ServerReader.handlePacket: SP_MESSAGE %@ from %@ to %@ flags %@", message, from, to, flags);
				
				// if flags are 5 it means it is an RCD and should not be parsed as string,
				// it means that message will be nil BUG 1684823 to be fixed code is in dmessage.c in cow, not in JTREK
				
				/* aha! A new type distress/macro call came in. parse it appropriately */
				if ([flags intValue] == (MTEAM | MDISTR | MVALID))  { 
					// buffer contains data not a string
					LLLog(@"ServerReader.handlePacket: SP_MESSAGE decoding [%@]", message);
					MTDistress *distress = [[[MTDistress alloc] initWithSender:[universe playerThatIsMe] buffer: (buffer+4)] autorelease];
					NSString *rcmMessage = [distress parsedMacroString]; // string in default macro format
					LLLog(@"ServerReader.handlePacket: SP_MESSAGE decoded %@ ", rcmMessage);
					obj = [NSDictionary dictionaryWithObjectsAndKeys:
						rcmMessage, @"message", flags, @"flags", from, @"from", to, @"to", nil];
				} 
				
                [notificationCenter postNotificationName:@"SP_MESSAGE" object:self userInfo:obj];  
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_MESSAGE error: %@: %@", [e name], [e reason]);
            }        
			break; 
		case SP_PLAYER_INFO :
            @try {
                int playerId = buffer[1]; // this player
                Player *player = [universe playerWithId:playerId];
                int shipType = buffer[2]; // flies this ship
                Ship *ship = [universe shipOfType:shipType];
                [player setShip:ship];
                int teamId = [universe remappedTeamIdWithId: buffer[3]]; // and is with this team
                if (teamId > TEAM_MAX) {
                    LLLog(@"ServerReader.handlePacket: SP_PLAYER_INFO error team %d unknown", teamId);
                    break;
                }
                Team *team = [universe teamWithId:teamId];
                [player setTeam:team];  // player is on this team
                [universe movePlayer:player toTeam:team]; // so move it from the old one if needed
                [notificationCenter postNotificationName:@"SP_PLAYER_INFO" object:self userInfo:player];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLAYER_INFO error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_KILLS :
            @try {
                int playerId = buffer[1]; // this player
                Player *player = [universe playerWithId:playerId];
                [player setKills: ((float)intFromPacket(buffer, 4) / 100)];	
                //[notificationCenter postNotificationName:@"SP_KILLS" object:self userInfo:player];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_KILLS error"); 
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_PLAYER :
            @try {                
                int playerId = buffer[1]; // this player
                Player *player = [universe playerWithId:playerId];
                
                NSPoint pos;
                pos.x = intFromPacket(buffer, 4);
                pos.y = intFromPacket(buffer, 8);
                
                /*
                 // Rotate direction and coordinates
                 player.dir = Rotate.rotateDir(buffer[2] & 0xFF, data.rotate);
                 Point point = Rotate.rotateCoord(x, y, data.rotate,
                                                  Universe.HALF_PIXEL_SIZE, Universe.HALF_PIXEL_SIZE);
                 
                 player.x = point.x;
                 player.y = point.y;
                 */
                [player setNetrekFormatCourse: (buffer[2] & 0xFF)];
                [player setPosition:pos];
                [player setSpeed: (buffer[3] & 0xFF)];
                //[notificationCenter postNotificationName:@"SP_PLAYER" object:self userInfo:player];     
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLAYER error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_TORP_INFO :
            @try {
                Torp *torp = [universe torpWithId:shortFromPacket(buffer, 4)];
                int status = buffer[2];
                if(status != [torp status]) {
                    if(status == TORP_EXPLODE && [torp status] == TORP_FREE) {
                        return YES;
                    }

                    [torp setStatus: status];
                }
                int war = buffer[1];
                [torp setWar: war];
                //[notificationCenter postNotificationName:@"SP_TORP_INFO" object:self userInfo:torp];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_TORP_INFO error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_TORP :
            @try {
                Torp *torp = [universe torpWithId:shortFromPacket(buffer, 2)];
                
                NSPoint pos;
                pos.x = intFromPacket(buffer, 4);
                pos.y = intFromPacket(buffer, 8);
                    /*
                // Rotate direction and coordinates
                torp.dir = Rotate.rotateDir(buffer[1] & 0xFF, data.rotate);
                Point point = Rotate.rotateCoord(intFromPacket(4), intFromPacket(8),
                                                 data.rotate, Universe.HALF_PIXEL_SIZE, Universe.HALF_PIXEL_SIZE);
                     */
                [torp setNetrekFormatCourse: (buffer[1] & 0xFF)];
                [torp setPosition: pos];
                //[notificationCenter postNotificationName:@"SP_TORP" object:self userInfo:torp];         
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_TORP error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_PHASER :
            @try {
             
                int phaserId = buffer[1];
                Phaser *phaser = [universe phaserWithId:phaserId];
                
                int playerId = intFromPacket(buffer, 12);
                Player *target = [universe playerWithId:playerId];
                
                [phaser setTarget: target];
                int status = buffer[2];
                [phaser setStatus: status];
                
                if(status != PHASER_FREE) {
                    // normalized maxfuse
                    Ship *ship = [universe shipWithPhaserId:phaserId];
                    [phaser setMaxFuse:[ship maxPhaserFuse]];
                }
                
                    /*
                // Rotate coordinates
                phaser.dir = Rotate.rotateDir(buffer[3] & 0xFF, data.rotate);
                Point point = Rotate.rotateCoord(intFromPacket(4), intFromPacket(8),
                                                 data.rotate, Universe.HALF_PIXEL_SIZE, Universe.HALF_PIXEL_SIZE);
                */
                    
                NSPoint pos;
                pos.x = intFromPacket(buffer, 4);
                pos.y = intFromPacket(buffer, 8);
                [phaser setPosition: pos];
                    
                [phaser setNetrekFormatCourse: (buffer[3] & 0xFF)];                   
                    
                [phaser setFuse: 0];  
                //[notificationCenter postNotificationName:@"SP_PHASER" object:self userInfo:phaser];  
                    
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PHASER error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_PLASMA_INFO :
            @try {
                Plasma *plasma = [universe plasmaWithId:shortFromPacket(buffer, 4)];
                    int status = buffer[2];
                    if(status != [plasma status]) {
                        if(status == PLASMA_EXPLODE && [plasma status] == PLASMA_FREE) {
                            return YES;
                        }
                        [plasma setStatus: status];
                    }
                    int war = buffer[1];
                    [plasma setWar: war];
                    //[notificationCenter postNotificationName:@"SP_PLASMA_INFO" object:self userInfo:plasma];  
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLASMA_INFO error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_PLASMA :
            @try {
                
                Plasma *plasma = [universe plasmaWithId:shortFromPacket(buffer, 2)];
                    
                NSPoint pos;
                pos.x = intFromPacket(buffer, 4);
                pos.y = intFromPacket(buffer, 8);
                    /*
                     // Rotate direction and coordinates
                     torp.dir = Rotate.rotateDir(buffer[1] & 0xFF, data.rotate);
                     Point point = Rotate.rotateCoord(intFromPacket(4), intFromPacket(8),
                                                      data.rotate, Universe.HALF_PIXEL_SIZE, Universe.HALF_PIXEL_SIZE);
                     */
                [plasma setNetrekFormatCourse: (buffer[1] & 0xFF)];
                [plasma setPosition: pos];
                //[notificationCenter postNotificationName:@"SP_PLASMA" object:self userInfo:plasma];         
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLASMA error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_WARNING :
            @try {
                NSString *warning = [self stringFromBuffer:buffer startFrom:4 maxLength:80];
                [notificationCenter postNotificationName:@"SP_WARNING" object:self userInfo:warning];    
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_WARNING error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_MOTD :
            @try {
                NSString *line = [self stringFromBuffer:buffer startFrom:4 maxLength:80];
                if([line hasPrefix:@"\t@@@"]) {
                    motd_done = YES;
                } 
                else if(!motd_done) { // part of the message of the day
                    //LLLog(@"ServerReader.handlePacket: SP_MOTD: %@", line);
                    //[notificationCenter postNotificationName:@"SP_MOTD" object:self userInfo:line];
                }
                else {                // server info message
                    //LLLog(@"ServerReader.handlePacket: SP_MOTD: %@", line);
                    //[notificationCenter postNotificationName:@"SP_MOTD_SERVER_INFO" object:self userInfo:line];
                }                
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_MOTD error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_YOU :
            @try {
                int ghostSlot = ([communication ghostSlot] == -1) ? buffer[1] : [communication ghostSlot];
                Player *me;
                if (ghostSlot == -1) {
                    int playerId = buffer[1]; // this player
                    me = [universe playerWithId:playerId];
                } else {
                    me = [universe playerWithId:ghostSlot];
                }

                [me updateHostile: buffer[2]
                        stickyWar: buffer[3]
                           armies: buffer[4]
                            flags: intFromPacket(buffer, 8)
                           damage: intFromPacket(buffer, 12)
                   shieldStrenght: intFromPacket(buffer, 16)
                             fuel: intFromPacket(buffer, 20)
                       engineTemp: (short)shortFromPacket(buffer, 24)
                      weaponsTemp: (short)shortFromPacket(buffer, 26)
                          whyDead: (short)shortFromPacket(buffer, 28)
                      whoKilledMe: (short)shortFromPacket(buffer, 30)
                         thisIsMe: YES];
                
                if(([me flags] & PLAYER_PLOCK) != 0) {
                    if (([me flags] & PLAYER_OBSERV) != 0) {
                        [[universe status] setObserver:YES];
                    }
                    else {
                        [[universe status] setObserver:NO]; 
                    }
                }
                else {	
                    [[universe status] setObserver:NO];
                } 
                //[notificationCenter postNotificationName:@"SP_YOU" object:self userInfo:me];  
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_YOU error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_QUEUE :
            @try {
                NSNumber *queueSize = [NSNumber numberWithInt:(int)shortFromPacket(buffer, 2)];
                [notificationCenter postNotificationName:@"SP_QUEUE" object:self userInfo:queueSize];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_QUEUE error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_STATUS :
            @try {
                Status *status = [universe status];
                
                [status updateTournament: (buffer[1] != 0)
                            armiesBombed: intFromPacket(buffer, 4)
                            planetsTaken: intFromPacket(buffer, 8)
                                   kills: intFromPacket(buffer, 12)	
                                  losses: intFromPacket(buffer, 16)
                                    time: intFromPacket(buffer, 20)
                                timeProd: intFromPacket(buffer, 24)];
                //[notificationCenter postNotificationName:@"SP_STATUS" object:self userInfo:status];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_STATUS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_PLANET :
            @try {                
                Planet *planet = [universe planetWithId:(buffer[1])];

                // update
                [planet setInfo: (buffer[3])];			
                [planet setFlags: shortFromPacket(buffer, 4)];
                [planet setArmies: intFromPacket(buffer, 8)];
                [planet setNeedsDisplay: YES]; 
                
                // allocate
                int teamId = [universe remappedTeamIdWithId: buffer[2]]; 
                Team *team = [universe teamWithId:teamId];
                [universe movePlanet:planet toTeam:team];
                [team addPlanet:planet];
                
                //[notificationCenter postNotificationName:@"SP_PLANET" object:self userInfo:planet];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLANET error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_PICKOK :
            @try 
            {
                bool pickOk = (buffer[1] != 0);
                if (pickOk) {
                    [notificationCenter postNotificationName:@"SP_PICKOK" object:self userInfo:nil]; 
                } else {
                    [notificationCenter postNotificationName:@"SP_PICKNOK" object:self userInfo:nil];  
                }                
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PICKOK error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_LOGIN :
            @try {                         
                // check to see if this is a paradise server
                if(buffer[2] == 69 && buffer[3] == 42) {
                    [notificationCenter postNotificationName:@"SP_LOGIN_INVALID_SERVER" object:self userInfo:nil];
                    return NO;
                }
                Player *me = [universe playerThatIsMe];
                
                bool accept = (buffer[1] != 0);
                if(accept) {
                    [[me stats] setFlags: intFromPacket(buffer, 4)];
                    [notificationCenter postNotificationName:@"SP_LOGIN_ACCEPTED" object:self userInfo:me];
                } else {
                    [notificationCenter postNotificationName:@"SP_LOGIN_NOT_ACCEPTED" object:self userInfo:nil];
                }
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_LOGIN error, reason:");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_FLAGS :
            @try {
                int playerId = buffer[1]; 
                Player *player = [universe playerWithId:playerId];
                [player setFlags: intFromPacket(buffer, 4)]; 
                //[notificationCenter postNotificationName:@"SP_FLAGS" object:self userInfo:player];     
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_FLAGS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_MASK :
            @try {
                int teamMask = buffer[1];
                [notificationCenter postNotificationName:@"SP_MASK" 
                                                  object:self userInfo:[NSNumber numberWithInt:teamMask]];                
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_MASK error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_PSTATUS :
            @try {
                int playerId = buffer[1]; 
                Player *player = [universe playerWithId:playerId];
                int status = buffer[2];
                if([player status] != status) {
                    // process the new status
                    [player setStatus:status];
                    switch(status) {
                            //we did boom
                        case PLAYER_EXPLODE :
                            [player setExplode: 0];
							if ([player isMe]) {
								LLLog(@"ServerReader.handlePacket: SP_PSTATUS i seem to have exploded!");
							}
                            break;
                        case PLAYER_DEAD :
                            // if we become dead, we should explode
                           [player setStatus:PLAYER_EXPLODE];
                            break;
                        default :
                            // reset kills
                            [player setKills: 0];
                            break;
                    }
                    [notificationCenter postNotificationName:@"SP_PSTATUS" object:self userInfo:player];
                }
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PSTATUS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_BADVERSION :
            LLLog(@"ServerReader.handlePacket: SP_BADVERSION not implemented");
            break;
		case SP_HOSTILE :
            @try {
                int playerId = buffer[1]; 
                Player *player = [universe playerWithId:playerId];
                [player setStickyWar: (buffer[2])];
                [player setHostile:(buffer[3])];
                //[notificationCenter postNotificationName:@"SP_HOSTILE" object:self userInfo:player];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_HOSTILE error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_STATS :
            @try {
                int playerId = buffer[1]; 
                Player *player = [universe playerWithId:playerId];
                PlayerStats *stats = [player stats];
                [stats updateTournamentKills: intFromPacket(buffer, 4)
                            tournamentLosses: intFromPacket(buffer, 8)
                                       kills: intFromPacket(buffer, 12)
                                      losses: intFromPacket(buffer, 16)
                             tournamentTicks: intFromPacket(buffer, 20)
                           tournamentPlanets: intFromPacket(buffer, 24)
                      tournamentArmiesBombed: intFromPacket(buffer, 28)
                               starbaseKills: intFromPacket(buffer, 32)
                              starbaseLosses: intFromPacket(buffer, 36)
                                armiesBombed: intFromPacket(buffer, 40)
                                     planets: intFromPacket(buffer, 44)
                            starbaseMaxKills: (double)intFromPacket(buffer, 52) / 100];

                FeatureList *fList = [communication featureList];
                if([[player ship] type] == SHIP_SB  && 
                   [fList valueForFeature: FEATURE_LIST_SB_HOURS] != FEATURE_OFF) {
                    [stats setStarbaseTicks: intFromPacket(buffer, 48)];
                }
                else {
                    [stats setMaxKills: (double)intFromPacket(buffer, 48) / 100];
                }
                //[notificationCenter postNotificationName:@"SP_STATS" object:self userInfo:player];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_STATS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
            break;
		case SP_PL_LOGIN :
            @try {
                int playerId = buffer[1]; 
                Player *player = [universe playerWithId:playerId];
                // check for promotion
                PlayerStats *pstats  = [player stats];
                Rank *oldRank = [pstats rank];
                Rank *newRank = [pstats setRankWithId: (buffer[2])];
                // removed check for is != ensign
                if([player isMe] && newRank != oldRank) {
                    // promoted flag is in the status 
                    Status *stats = [universe status];
                    [stats setPromoted: YES];
                }
                NSString *name    = [self stringFromBuffer:buffer startFrom:4 maxLength:16];
                [player setName:name];
                NSString *monitor = [self stringFromBuffer:buffer startFrom:20 maxLength:16];
                [player setMonitor:monitor];
                NSString *login   = [self stringFromBuffer:buffer startFrom:36 maxLength:16];
                [player setLogin:login];
                //[notificationCenter postNotificationName:@"SP_PL_LOGIN" object:self userInfo:player];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PL_LOGIN error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }
			break;
		case SP_RESERVED :
			@try {
                NSData *sreserved = [NSData dataWithBytes:(buffer+4) length:16];
                
                // do some stuff with old style RSA,
                [notificationCenter postNotificationName:@"SP_RESERVED" object:self userInfo:sreserved];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_RESERVED error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break;
		case SP_PLANET_LOC :
			@try {
                Planet *planet = [universe planetWithId:(buffer[1])];
                /*
                // Rotate coordinates
                Point point = Rotate.rotateCoord(
                                                 intFromPacket(4),
                                                 intFromPacket(8),
                                                 data.rotate,
                                                 Universe.HALF_PIXEL_SIZE,
                                                 Universe.HALF_PIXEL_SIZE);
                */
                NSPoint pos;
                pos.x = intFromPacket(buffer, 4);
                pos.y = intFromPacket(buffer, 8);
                [planet setPosition: pos];
                
                NSString *name    = [self stringFromBuffer:buffer startFrom:12 maxLength:16];
                [planet setName:name];
                [planet setNeedsDisplay:YES];  
                //[notificationCenter postNotificationName:@"SP_PLANET_LOC" object:self userInfo:planet];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLANET_LOC error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break;
		case SP_UDP_REPLY :
			@try {
                // to big to be in this switch
                [self handleUdpReply:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PLANET_LOC error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break;       
		case SP_SEQUENCE : 
        case SP_SC_SEQUENCE :
            // to be overwritten by UDP
            [self handleSequence:buffer];            
            break;          
		case SP_RSA_KEY :
			@try {
                LLLog(@"ServerReader.handlePacket: RSA verification requested.");
                NSMutableData *data = [NSMutableData dataWithBytes:(buffer+4) length:RSA_KEY_SIZE]; 
				[data retain]; // SERIOUS BUG !! will cause instable side effects if not retained (fixed since 1.3.0)
                // do some stuff with RSA,
                // looks very specific, let the RSA handler take care of it when
                // it receives the notification
                [notificationCenter postNotificationName:@"SP_RSA_KEY" object:self userInfo:data];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_RSA_KEY error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break;            
		case SP_MOTD_PIC :
            LLLog(@"ServerReader.handlePacket: SP_MOTD_PIC not implemented");           
            break; 
		case SP_SHIP_CAP :
			@try {
                // setup the properties of this ship
                int shipType = shortFromPacket(buffer, 2);
                Ship *ship = [universe shipOfType:shipType];
                
                [ship setTorpSpeed: shortFromPacket(buffer, 4)];
                [ship setPhaserDamage: shortFromPacket(buffer, 6)];
                [ship setMaxSpeed: intFromPacket(buffer, 8)];
                [ship setMaxFuel: intFromPacket(buffer, 12)];
                [ship setMaxShield: intFromPacket(buffer, 16)];
                [ship setMaxDamage: intFromPacket(buffer, 20)];
                [ship setMaxWeaponTemp: intFromPacket(buffer, 24)];
                [ship setMaxEngineTemp: intFromPacket(buffer, 28)];
                [ship setWidth: shortFromPacket(buffer, 30)];
                [ship setHeight: shortFromPacket(buffer, 32)];
                [ship setMaxArmies: shortFromPacket(buffer, 34)];
                
                [notificationCenter postNotificationName:@"SP_SHIP_CAP" object:self userInfo:ship];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_SHIP_CAP error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_REPLY :
			@try {
                int reply = buffer[1];
                switch(reply) {
                    case SPK_VOFF :
                        if([communication shortVersion] == SHORTVERSION && ![communication receiveShort]) {
                            LLLog(@"ServerReader.handlePacket: Using Short Packet Version 1.");
                            // funny, this never rolls back?
                            [communication setShortVersion: OLDSHORTVERSION];
                            //comm.sendShortReq(SPK_VON); should be done by communication upon							
                            // receiving the event
                            [notificationCenter postNotificationName:@"SP_S_REPLY_SPK_OLD" object:self 
                                                            userInfo:[NSNumber numberWithInt:SPK_VON]];
                        }
                        else {
                            [communication setReceiveShort: NO];
                            //[communication sendUdpReq:[NSNumber numberWithInt:COMM_UPDATE]];
                            //view.short_win.refresh(); should be done by communication upon 
                            // receiving the event
                            [notificationCenter postNotificationName:@"SP_S_REPLY_SPK_VOFF" object:self 
                                                            userInfo:[NSNumber numberWithInt:COMM_UPDATE]];
                        }
                        break;
                    case SPK_VON:
                        [communication setReceiveShort: YES];
                        //view.short_win.refresh();
                        // I didn't know what spwinside and spgwidth where used for.
                        //int spwinside = shortFromPacket(2);
                        //int spgwidth = shortFromPacket(4);
                        /* 
                        * Get a `-' style update to fix the kills shown on the playerlist
                         * when you first enter and to fix other loss if short packets
                         * have just been turned back on.
                         */
						//[communication sendShortReq:[NSNumber numberWithInt:SPK_SALL]];
                        [notificationCenter postNotificationName:@"SP_S_REPLY_SPK_VON" object:self 
                                                        userInfo:[NSNumber numberWithInt:SPK_SALL]];
                        LLLog(@"ServerReader.handlePacket: Receiving Short Packet Version ");
                        break;
                    case SPK_THRESHOLD:
                        break;
                    default:
                        LLLog(@"ServerReader.handlePacket: Unknown response packet value short-req ");
                        break;
                }
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_REPLY error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_MESSAGE :
			@try {
                
                // from part
                NSMutableString *message = [NSString stringWithString: @"   ->   "];
                int from = buffer[3] & 0xFF;
                if(from > [universe playerCount]) {
                    from = 255;
                }
                if(from == 255) {
                    message = [NSString stringWithString: @"GOD->"];                    
                }
                else {
                    Player *player = [universe playerWithId:from];
                    message = [NSString stringWithFormat:@" %@->", [player mapChars]];
                }
                
                // to part
                Player *me = [universe playerThatIsMe];
                Team* myTeam = [me team];
                switch(buffer[1] & (TEAM | INDIV | ALL)) {
                    case TEAM :
                        [message appendString:[myTeam abbreviation]];                       
                        break;
                    case INDIV :
                        [message appendString:[me mapChars]];
                        break;
                    default :
                        [message appendString: @"ALL"];
                        break;
                }
                
                // the message
                [message appendString:[self stringFromBuffer:buffer startFrom:5 maxLength:79]];
                [notificationCenter postNotificationName:@"SP_S_MESSAGE" object:self userInfo:message];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_MESSAGE error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_WARNING :
			@try {
                if(swarningHandler == nil) {
                    swarningHandler = [[ShortPacketWarningHandler alloc] init];
                }
                // way to much code to handle in here, create seperate class as helper
                LLLog(@"ServerReader.handlePacket: SP_S_WARNING passing to ShortPacketWarningHandler");
                [swarningHandler handleSWarning:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_WARNING error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_YOU :
			@try {
                int ghostSlot = ([communication ghostSlot] == -1) ? buffer[1] : [communication ghostSlot];
                Player *me;
                if (ghostSlot == -1) {
                    int playerId = buffer[1]; // this player
                    me = [universe playerWithId:playerId];
                } else {
                    me = [universe playerWithId:ghostSlot];
                }
                
                [me updateHostile: buffer[2]
                        stickyWar: buffer[3]
                           armies: buffer[4]
                            flags: intFromPacket(buffer, 8)
                          whyDead: buffer[5]
                      whoKilledMe: buffer[6]
                         thisIsMe: YES];
                
                if(([me flags] & PLAYER_PLOCK) != 0) {
                    if (([me flags] & PLAYER_OBSERV) != 0) {
                        [[universe status] setObserver:YES];
                    }
                    else {
                        [[universe status] setObserver:NO]; 
                    }
                }
                else {	
                    [[universe status] setObserver:NO];
                } 
                [notificationCenter postNotificationName:@"SP_S_YOU" object:self userInfo:me];                
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_YOU error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_YOU_SS :
			@try {
                Player* me = [universe playerThatIsMe];
                
                // Ignore this message until I know what player slot I am.
                if(me == nil) {
                    return YES;
                }
                
                [me updateDamage: shortFromPacket(buffer, 2)
                   shieldStrenght: shortFromPacket(buffer, 4)
                             fuel: shortFromPacket(buffer, 6)
                       engineTemp: (short)shortFromPacket(buffer, 8)
                      weaponsTemp: (short)shortFromPacket(buffer, 10)                          
                         thisIsMe: YES];
                
                // freaky bit stuff
                FeatureList *fList = [communication featureList];                
                if([fList valueForFeature: FEATURE_LIST_SELF_8FLAGS] != FEATURE_OFF) {
                    [me setFlags: (([me flags] & 0xFFFFFF00) | (buffer[1] & 0xFF))];
                }
                else if([fList valueForFeature: FEATURE_LIST_SELF_8FLAGS2] != FEATURE_OFF) {
                    int new_flags = [me flags] & ~(PLAYER_SHIELD | PLAYER_REPAIR | PLAYER_CLOAK 
                                | PLAYER_GREEN | PLAYER_YELLOW | PLAYER_RED | PLAYER_TRACT | PLAYER_PRESS);
                    
                    int pad1 = buffer[1] & 0xFF;
                    
                    new_flags |= ((pad1 & PLAYER_SHIELD) | (pad1 & PLAYER_REPAIR) 
                                  | ((pad1 & (PLAYER_CLOAK << 2)) >> 2) | ((pad1 & (PLAYER_GREEN << 7)) >> 7) 
                                  | ((pad1 & (PLAYER_YELLOW << 7)) >> 7) | ((pad1 & (PLAYER_RED << 7)) >> 7) 
                                  | ((pad1 & (PLAYER_TRACT << 15)) >> 15)  | ((pad1 & (PLAYER_PRESS << 15)) >> 15));
                    
                    [me setFlags: new_flags];
                }
                [notificationCenter postNotificationName:@"SP_S_YOU_SS" object:self userInfo:me];     
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_YOU_SS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_PLAYER :
			@try {
                // to big to be in this switch
                [self handleVPlayer:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_PLAYER error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_PING :
			@try {
                int response = (buffer[1]);
                [communication setPing:YES withResponse:response]; // we got a ping
                // update the stats
                PingStats *pingStats = [communication pingStats];
                
                [pingStats setLag: (short)shortFromPacket(buffer, 2)];
                [pingStats setTotalLossServerToClient:(buffer[4] & 0xFF) 
                                       ClientToServer:(buffer[5] & 0xFF)];
                [pingStats setIncrementalLossServerToClient:(buffer[6] & 0xFF) 
                                             ClientToServer:(buffer[7] & 0xFF)];
                [pingStats calculateLag];
				//[notificationCenter postNotificationName:@"SP_PING" object:self userInfo:pingStats];  
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_PING error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_TORP :
		case SP_S_8_TORP :
			@try {
                [self handleVTorp:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_TORP error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_TORP_INFO :
			@try {
                [self handleVTorpInfo:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_TORP_INFO error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_PLANET :
			@try {
                [self handleVPlanet:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_PLANET error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_PHASER :
			@try {
                [self handleVPhaser:buffer];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_PHASER error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_KILLS :
			@try {                
                int player_index = 0;
                Player *player;
                int data_pos = 2;
                int numofkills = buffer[1] & 0xFF;                
                
                for(int p = 0; p < numofkills; ++p, data_pos += 2) {
                    player_index = buffer[data_pos + 1] >> 2;
                    player = [universe playerWithId:player_index];
                    [player setKills: (float)(buffer[data_pos] & 0xFF | ((buffer[data_pos + 1] & 0x03) << 8)) / 100];
                    [notificationCenter postNotificationName:@"SP_S_KILLS" object:self userInfo:player];
                }            
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_KILLS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_S_STATS :
			@try {
                Player *player = [universe playerWithId:buffer[1]];
                PlayerStats *stats = [player stats];
                
                [stats updateTournamentKills:shortFromPacket(buffer, 4) 
                            tournamentLosses:shortFromPacket(buffer, 6) 
                                       kills:shortFromPacket(buffer, 8) 
                                      losses:shortFromPacket(buffer, 10) 
                             tournamentTicks:intFromPacket(buffer, 12) 
                           tournamentPlanets:shortFromPacket(buffer, 2) 
                      tournamentArmiesBombed:intFromPacket(buffer, 16) 
                               starbaseKills:shortFromPacket(buffer, 24) 
                              starbaseLosses:shortFromPacket(buffer, 26) 
                                armiesBombed:shortFromPacket(buffer, 28) 
                                     planets:shortFromPacket(buffer, 30) 
                            starbaseMaxKills:intFromPacket(buffer, 32) / 100];
                
                FeatureList *fList = [communication featureList];
                                    
                if([[player ship] type]  == SHIP_SB && [fList valueForFeature: FEATURE_LIST_SB_HOURS] != FEATURE_OFF) {
                    [stats setStarbaseTicks: intFromPacket(buffer, 48)];
                }
                else {
                    [stats setMaxKills: (double)intFromPacket(buffer, 48) / 100];
                }
                [notificationCenter postNotificationName:@"SP_S_STATS" object:self userInfo:player];
            }
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_S_STATS error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_FEATURE :
			@try {
                FeatureList *fList = [communication featureList]; 
                                
                char type = (char)buffer[1];
                int  arg1 = (int)buffer[2]; 
                int  arg2 = (int)buffer[3]; 
                int value = intFromPacket(buffer, 4);
                NSString *name = [self stringFromBuffer:buffer startFrom:8 maxLength:80];
                [fList checkFeature:name withType:type withArg1:arg1 withArg2:arg2 withValue:value];                
                [notificationCenter postNotificationName:@"SP_FEATURE" object:self userInfo:nil];
            }            
            @catch (NSException * e) {
                LLLog(@"ServerReader.handlePacket: SP_FEATURE error");
                LLLog([NSString stringWithFormat:@"%@: %@", [e name], [e reason]]);
            }            
            break; 
		case SP_BITMAP :
            LLLog(@"ServerReader.handlePacket: SP_BITMAP not implemented");           
			break;						
		}
        
        
        //NSTimeInterval stop = [NSDate timeIntervalSinceReferenceDate];  
        //LLLog(@"ServerReader.handlePacket took: %f sec", (stop-start));    
        
    return YES;
}

- (NSString*) stringFromBuffer:(char*)buffer startFrom:(int)start maxLength:(int)max {
    
	// check
	bool okay = NO;
	for (int i = start; i < (start+max); i++) {
        if (buffer[i] == '\0') {
			okay = YES;
		}
	}
	if (!okay) {
		buffer[start+max] = '\0';
	}
    // looks for null temination it self, i could check maxlength, but it's okay
    NSString *line = [NSString stringWithUTF8String:(buffer + start)];
    //LLLog(@"ServerReader.stringFromBuffer (%@)", line);
    return line;
}

- (NSTimeInterval)timeOut {
	return timeOut;
}

- (void) setTimeOut:(NSTimeInterval)newTimeOut {
	timeOut = newTimeOut;
}

@end
