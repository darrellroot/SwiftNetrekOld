//
//  Communication.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Communication.h"
#import "ServerReaderTcp.h"
#import "ServerReaderUdp.h"
#import "ServerSenderTcp.h"
#import "ServerSenderUdp.h"
#import <Math.h>

@implementation Communication

// use ping?
bool ping = NO;

// force state and weapons
// only if force is YES
bool forceState = NO;

int fSpeed = -1;
int fShield = -1;
int fOrbit = -1;
int fRepair = -1;
int fBeamup = -1;
int fBeamdown = -1;
int fCloak = -1;
int fBomb = -1;
int fDockperm = -1;
int fPhaser = -1;
int fPlasma = -1;
int fPlayLock = -1; 
int fPlanLock = -1;
int fTractor = -1;
int fRepressor = -1;

// privates
int baseLocalUdpPort = 0;
int localUdpPort = 0;
int updatesPerSecond = COMM_UPDATES_PER_SECOND;
char buffer[104];           // maintain a static sendbuffer

// network stuff
int nextPort = 0;           // remember the ports we already tried
ServerReaderTcp *tcpReader;
ServerReaderUdp *udpReader;
ServerSenderTcp *tcpSender;
ServerSenderUdp *udpSender;

// thread vars
// these should really be LOCKS $$$
bool isRunning;
bool isSleeping;
bool keepRunning;
bool goSleeping;

- (id) init {
    self = [super init];
    if (self != nil) {
		rsaCoder = [[RSAWrapper alloc] init];
        ghostSlot = -1;  
        commMode = COMM_TCP;         // COMM_TCP or COMM_UDP
        commStatus = 0;
        shortVersion = COMM_SHORTVERSION;
        receiveShort = NO;
        fList = [[FeatureList alloc] init]; 
        pStats = [[PingStats alloc] init];
        udpStats = [[UdpStats alloc] init];   
        tcpReader = nil;
        udpReader = nil;
        [self subscribeToNotifications];
        isRunning = NO;
		isSleeping = NO;
        keepRunning = YES;
		goSleeping = NO;
		//  $$$ Communication does not do anything with them yet!
		udpReceiveMode = MODE_SIMPLE;
		udpSendMode = MODE_SIMPLE;
		udpSequenceChecking = YES;
		
		// multithreaded?
		multiThreaded = NO;
				
		// listen to changes in settings
		[notificationCenter addObserver:self selector:@selector(setUdpSequenceCheck:) name:@"UC_UDP_SEQUENCE_CHECK"];
		[notificationCenter addObserver:self selector:@selector(setUdpSendMode:) name:@"UC_UDP_SEND_MODE"];
		[notificationCenter addObserver:self selector:@selector(setUdpReceiveMode:) name:@"UC_UDP_RECEIVE_MODE"];
	}
    return self;
}

- (void)awakeFromNib {
	// post initial state
	[notificationCenter postNotificationName:@"COMM_MODE_CHANGED" userInfo:[NSNumber numberWithInt:commMode]];
	[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];
}

- (void) setUdpSequenceCheck:(NSNumber*) newValue {
	udpSequenceChecking = [newValue boolValue];
	if (udpReader) {
		[udpReader setSequenceCheck:udpSequenceChecking];
	}
}

- (void) setUdpSendMode:(NSNumber*) newValue {
	udpSendMode = [newValue intValue];
}

- (void) setUdpReceiveMode:(NSNumber*) newValue {
	udpReceiveMode = [newValue intValue];
}

- (void) setMultiThreaded:(bool) multi {
    multiThreaded = multi;
}

- (void)subscribeToNotifications {
    
    // tie [self selector] to a common event so it can be remotely invoked
    // this is thread safe because of the locks
    // i will respond to anyone (nil)																	   // expected parameter
    [notificationCenter addObserver:self selector:@selector(readFromServer:) 
                               name:@"COMM_READ_FROM_SERVER" object:nil useLocks:multiThreaded];           // --
    [notificationCenter addObserver:self selector:@selector(cleanUp:) 
                               name:@"COMM_CLEAN_UP" object:nil useLocks:multiThreaded];                   // --
    [notificationCenter addObserver:self selector:@selector(readFromServer:) 
                               name:@"COMM_READ_FROM_SERVER" object:nil useLocks:multiThreaded];           // --
    [notificationCenter addObserver:self selector:@selector(sendSpeedReq:) 
                               name:@"COMM_SEND_SPEED_REQ"  object:nil useLocks:multiThreaded];            // NSNumber intValue
    [notificationCenter addObserver:self selector:@selector(sendDockingReq:) 
                               name:@"COMM_SEND_DOCK_REQ" object:nil useLocks:multiThreaded];              // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendCloakReq:) 
                               name:@"COMM_SEND_CLOAK_REQ" object:nil useLocks:multiThreaded];             // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendRefitReq:) 
                               name:@"COMM_SEND_REFIT_REQ" object:nil useLocks:multiThreaded];             // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendDirReq:) 
                               name:@"COMM_SEND_DIR_REQ" object:nil useLocks:multiThreaded];               // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendPhaserReq:) 
                               name:@"COMM_SEND_PHASER_REQ" object:nil useLocks:multiThreaded];            // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendTorpReq:) 
                               name:@"COMM_SEND_TORPS_REQ" object:nil useLocks:multiThreaded];             // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendPlasmaReq:) 
                               name:@"COMM_SEND_PLASMA_REQ" object:nil useLocks:multiThreaded];            // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendShieldReq:) 
                               name:@"COMM_SEND_SHIELD_REQ" object:nil useLocks:multiThreaded];            // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendBombReq:) 
                               name:@"COMM_SEND_BOMB_REQ" object:nil useLocks:multiThreaded];              // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendBeamReq:) 
                               name:@"COMM_SEND_BEAM_REQ" object:nil useLocks:multiThreaded];              // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendRepairReq:) 
                               name:@"COMM_SEND_REPAIR_REQ" object:nil useLocks:multiThreaded];            // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendOrbitReq:) 
                               name:@"COMM_SEND_ORBIT_REQ" object:nil useLocks:multiThreaded];             // NSNumber boolValue
    [notificationCenter addObserver:self selector:@selector(sendQuitReq:) 
                               name:@"COMM_SEND_QUIT_REQ" object:nil useLocks:multiThreaded];              // --
    [notificationCenter addObserver:self selector:@selector(sendCoupReq:) 
                               name:@"COMM_SEND_COUP_REQ" object:nil useLocks:multiThreaded];              // --
    [notificationCenter addObserver:self selector:@selector(sendByeReq:) 
                               name:@"COMM_SEND_BYE_REQ" object:nil useLocks:multiThreaded];               // --
    [notificationCenter addObserver:self selector:@selector(sendPractrReq:) 
                               name:@"COMM_SEND_PRACTICE_REQ" object:nil useLocks:multiThreaded];          // --
    [notificationCenter addObserver:self selector:@selector(sendDetonateReq:) 
                               name:@"COMM_SEND_DETONATE_REQ" object:nil useLocks:multiThreaded];          // --
    [notificationCenter addObserver:self selector:@selector(sendDetMineReq:)
                               name:@"COMM_SEND_DET_MINE_REQ" object:nil useLocks:multiThreaded];          // NSNumber intValue
    [notificationCenter addObserver:self selector:@selector(sendDetonateMyTorpsReq:)
                               name:@"COMM_SEND_DET_MINE_ALL_REQ" object:nil useLocks:multiThreaded];      // --
    [notificationCenter addObserver:self selector:@selector(sendPlaylockReq:) 
                               name:@"COMM_SEND_PLAYER_LOCK_REQ" object:nil useLocks:multiThreaded];       // NSNumber intValue
    [notificationCenter addObserver:self selector:@selector(sendPlanlockReq:) 
                               name:@"COMM_SEND_PLANET_LOCK_REQ" object:nil useLocks:multiThreaded];       // NSNumber intValue	
    [notificationCenter addObserver:self selector:@selector(sendResetStatsReq:)
                               name:@"COMM_SEND_RESET_STATS_REQ" object:nil useLocks:multiThreaded];       // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendWarReq:)
                               name:@"COMM_SEND_WAR_REQ" object:nil useLocks:multiThreaded];               // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendTractorOnReq:)
                               name:@"COMM_SEND_TRACTOR_ON_REQ" object:nil useLocks:multiThreaded];        // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendTractorOffReq:)
                               name:@"COMM_SEND_TRACTOR_OFF_REQ" object:nil useLocks:multiThreaded];       // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendRepressorOnReq:)
                               name:@"COMM_SEND_REPRESSOR_ON_REQ" object:nil useLocks:multiThreaded];      // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendRepressorOffReq:)
                               name:@"COMM_SEND_REPRESSOR_OFF_REQ" object:nil useLocks:multiThreaded];     // NSNumber charValue
    [notificationCenter addObserver:self selector:@selector(sendTeamReq:)
                               name:@"COMM_SEND_TEAM_REQ" object:nil useLocks:multiThreaded];              // NSDictionary with team, ship
    [notificationCenter addObserver:self selector:@selector(sendFeatureReq:)
                               name:@"COMM_SEND_FEATURE_REQ" object:nil useLocks:multiThreaded];           // NSDictionary with type, arg1, arg2, name
    [notificationCenter addObserver:self selector:@selector(sendLoginReq:)
                               name:@"COMM_SEND_LOGIN_REQ" object:nil useLocks:multiThreaded];             // NSDictionary with query,name,pass,login
    [notificationCenter addObserver:self selector:@selector(sendPingReq:)
                               name:@"COMM_SEND_PING_REQ" object:nil useLocks:multiThreaded];              // NSNumber bool
    [notificationCenter addObserver:self selector:@selector(sendServerPingResponse:)
                               name:@"COMM_SEND_PING_RESPONSE" object:nil useLocks:multiThreaded];         // NSNumber char
    [notificationCenter addObserver:self selector:@selector(sendMessage:)
                               name:@"COMM_SEND_MESSAGE" object:nil useLocks:multiThreaded];               // NSDictionary with group, indiv, message
    [notificationCenter addObserver:self selector:@selector(sendUpdatePacket:)
                               name:@"COMM_SEND_UPDATE_PACKET" object:nil useLocks:multiThreaded];         // NSNumber int
    [notificationCenter addObserver:self selector:@selector(sendUpdatePacket:)
                               name:@"COMM_SEND_TRESHOLD" object:nil useLocks:multiThreaded];              // NSNumber int
    [notificationCenter addObserver:self selector:@selector(sendOptionsPacket:)
                               name:@"COMM_SEND_OPTIONS_PACKET" object:nil useLocks:multiThreaded];        // --
    [notificationCenter addObserver:self selector:@selector(sendPickSocketReq:)
                               name:@"COMM_SEND_PICK_SOCKET" object:nil useLocks:multiThreaded];           // NSNumber int
    [notificationCenter addObserver:self selector:@selector(sendUdpReq:)
                               name:@"COMM_SEND_UDP_REQ" object:nil useLocks:multiThreaded];               // NSNumber char
    [notificationCenter addObserver:self selector:@selector(sendShortReq:)
                               name:@"COMM_SEND_SHORT_REQ" object:nil useLocks:multiThreaded];             // NSNumber char
    [notificationCenter addObserver:self selector:@selector(sendUdpVerify:)
                               name:@"COMM_SEND_VERIFY" object:nil useLocks:multiThreaded];                // --
	[notificationCenter addObserver:self selector:@selector(forceResetToTCP:)
                               name:@"COMM_FORCE_RESET_TO_TCP" object:nil useLocks:multiThreaded];         // --
     
    // implementation of serverReader events
    [notificationCenter addObserver:self selector:@selector(closeUdpConn)
                               name:@"SP_SWITCHED_DENIED" object:nil useLocks:multiThreaded];			   // close connection if switch denied
	[notificationCenter addObserver:self selector:@selector(closeUdpConn)
                               name:@"SP_UDP_SWITCHED_TO_TCP" object:nil useLocks:multiThreaded];          // close the connection 
	[notificationCenter addObserver:self selector:@selector(sendUdpVerify:)
                               name:@"SP_TCP_SWITCHED_TO_UDP" object:nil useLocks:multiThreaded];          // when switched to UDP verify
    [notificationCenter addObserver:self selector:@selector(sendShortReq:)
                               name:@"SP_S_REPLY_SPK_OLD" object:nil useLocks:multiThreaded];              // switch ot old version
    [notificationCenter addObserver:self selector:@selector(sendUdpReq:)
                               name:@"SP_S_REPLY_SPK_VOFF" object:nil useLocks:multiThreaded];             // UDP off
    [notificationCenter addObserver:self selector:@selector(sendShortReq:)
                               name:@"SP_S_REPLY_SPK_VON" object:nil useLocks:multiThreaded];              // switch ot short pkt  
	[notificationCenter addObserver:self selector:@selector(sendShortReq:)
                               name:@"SP_S_REPLY_SPK_VON" object:nil useLocks:multiThreaded];              // switch ot short pkt  
	[notificationCenter addObserver:self selector:@selector(sendReservedReply:)
                               name:@"SP_RESERVED" object:nil useLocks:multiThreaded];					   // server requested reserved
	
	[notificationCenter addObserver:self selector:@selector(sendRSAResponse:) 
								   name:@"SP_RSA_KEY" object:nil useLocks:multiThreaded];
	
    [notificationCenter addObserver:self selector:@selector(stopCommunicationThread)
                               name:@"COMM_RESURRECT_FAILED" object:nil useLocks:multiThreaded]; 
	
	// shutdown
	[notificationCenter addObserver:self selector:@selector(sendByeReq:) name:@"MC_MACTREK_SHUTDOWN"];

}

-(char*) bigEndianInteger:(int) value inBuffer:(char*) dst withOffset:(int)dst_begin {
    dst[dst_begin]   = (char)((value >> 24) & 0xFF);
    dst[++dst_begin] = (char)((value >> 16) & 0xFF);
    dst[++dst_begin] = (char)((value >> 8 ) & 0xFF);
    dst[++dst_begin] = (char)(value & 0xFF);
    return dst;
}

-(PingStats*) pingStats {
    return pStats;
}

-(UdpStats*)udpStats {
    return udpStats;
}

- (int) updatesPerSecond { 	// private var ?
    return updatesPerSecond;
}

- (int) ghostSlot {
    return ghostSlot;
}

- (void) setGhostSlot:(int) slot {
    ghostSlot = slot;
}

-(int)commMode {
    return commMode;
}

-(void)setCommMode:(int)mode {
    commMode = mode;
	[notificationCenter postNotificationName:@"COMM_MODE_CHANGED" userInfo:[NSNumber numberWithInt:commMode]];
}

-(int)commModeRequest {
    return commModeRequest;
}

-(void)setCommModeRequest:(int)mode {
    commModeRequest = mode;
}

-(FeatureList*) featureList {
    return fList;
}

-(int)commStatus {
    return commStatus;
}

-(void)setCommStatus:(int)status {
    commStatus = status;
	[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];

}

-(int)shortVersion {
    return shortVersion;
}

-(void)setShortVersion:(int)ver {
    shortVersion = ver;
}

-(bool)receiveShort {
    return receiveShort;
}

-(void)setReceiveShort:(bool)rs {
    receiveShort = rs;
}

-(void) setPing:(bool) received withResponse:(int)response {
    // 1750190 Ghostbust on IDLE
    ping = received;
    [self sendServerPingResponse:[NSNumber numberWithInt:response]];
}

-(int) packetsReceived {
    return [udpStats packetsReceived];
}

-(void)increasePacketsReceived {
    [udpStats setPacketsReceived: [udpStats packetsReceived] + 1];
}

-(void)decreasePacketsReceived {
    [udpStats setPacketsReceived: [udpStats packetsReceived] - 1];
}

-(char *) insertString:(NSString *)str inBuffer:(char*)buffer offset:(int)offset maxLength:(int)max {
	// max is either the max or the length of the string we try to copy
	max = (max > [str length] ? [str length] : max);
	// get it as a cstring
	const char *input = [str UTF8String];
	// perform the copy
	strncpy(buffer+offset, input, max);
	// close the string
	buffer[offset+max] = 0;
	return buffer;
}

// some generic send messages, internal use only
- (void) sendShortPacketWithId:(char) type {
	[self sendShortPacketWithId:type state: 0];
}

- (void) sendShortPacketNoForceWithId:(char) type state:(char) state {
	buffer[0] = type;
	buffer[1] = state;
	[self sendServerPacketWithBuffer:buffer length:4];
}

- (void) sendShortPacketWithId:(char) type boolState:(bool) state {
    [self sendShortPacketWithId:type state: (state ? 1 :0 ) ];
}

    // state is a boolean, 1 means on, 0 means off
- (void) sendShortPacketWithId:(char) type state:(char) state {    
	// same as without forceStat
	[self sendShortPacketNoForceWithId:type state:state];
    
	// if we're sending in UDP mode, be prepared to forceStat it
	if (commMode == COMM_UDP && (forceState || udpSendMode == MODE_FAT || udpSendMode == MODE_DOUBLE)) {
		switch (type) {
            case CP_SPEED:
                fSpeed = state | 0x100;
                break;
            case CP_SHIELD:
                fShield = state | 0xA00;
                break;
            case CP_ORBIT:
                fOrbit = state | 0xA00;
                break;
            case CP_REPAIR:
                fRepair = state | 0xA00;
                break;
            case CP_CLOAK:
                fCloak = state | 0xA00;
                break;
            case CP_BOMB:
                fBomb = state | 0xA00;
                break;
            case CP_DOCKPERM:
                fDockperm = state | 0xA00;
                break;
            case CP_PLAYLOCK:
                fPlayLock = state | 0xA00;
                break;
            case CP_PLANLOCK:
                fPlanLock = state | 0xA00;
                break;
            case CP_BEAM:
                if (state == 1)
                    fBeamup = 1 | 0x500;
                else
                    fBeamdown = 2 | 0x500;
                break;
		}
		
		if (udpSendMode == MODE_DOUBLE) {			
		    switch (type) {
				case CP_PHASER:
					fPhaser = state | 0x100;
					break;
				case CP_PLASMA:
					fPlasma = state | 0x100;
					break;
			}
		}
	}
}

- (void) sendServerPacketWithBuffer:(char*)buffer length:(int) size {
	
	if(commMode == COMM_UDP  && udpSendMode != MODE_TCP) {
		// UDP stuff
		switch (buffer[0]) {
			case CP_SPEED:
			case CP_DIRECTION:
			case CP_PHASER:
			case CP_PLASMA:
			case CP_TORP:
			case CP_QUIT:
			case CP_PRACTR:
			case CP_SHIELD:
			case CP_REPAIR:
			case CP_ORBIT:
			case CP_PLANLOCK:
			case CP_PLAYLOCK:
			case CP_BOMB:
			case CP_BEAM:
			case CP_CLOAK:
			case CP_DET_TORPS:
			case CP_DET_MYTORP:
			case CP_REFIT:
			case CP_TRACTOR:
			case CP_REPRESS:
			case CP_COUP:
			case CP_DOCKPERM:
			case CP_PING_RESPONSE:
				// non-critical stuff, use UDP
				[udpStats increasePacketsSendBy:1];
				if ((udpSender == nil) || (![udpSender sendBuffer:buffer length:size])) {
				    commModeRequest = commMode;
				    commStatus = STAT_CONNECTED;
					[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];
				    [self sendUdpReq:COMM_TCP]; // should switch to TCP? $$$ not in orig code
				    [self closeUdpConn];
				}
                return;
                break;
			default:
				LLLog(@"Communications.sendServerPacketWithBuffer unknown UDP packet");
				break;
		}
	} 
    
    // either TCP mode or critical packet
    if ((tcpSender == nil) || (![tcpSender sendBuffer:buffer length:size])) {
        LLLog(@"Communications.sendServerPacketWithBuffer TCP write error");
        [notificationCenter postNotificationName:@"COMM_TCP_WRITE_ERROR" object:self 
                                        userInfo:@"TCP write error"];
    }
}

- (void) resetForce {
	fSpeed = fShield = fOrbit = fRepair = fBeamup = fBeamdown = fCloak 
    = fBomb = fDockperm = fPhaser = fPlasma = fPlayLock = fPlanLock 
    = fTractor = fRepressor = -1;
}

/** 
* If something we want to happen hasn't yet, send it again.
* The low byte is the request, the high byte is a max count.  When the max
* count reaches zero, the client stops trying.	Checking is done with a
* macro for speed & clarity. 
*/
- (int) forceCheckFlags:(int) flag force:(int) force type:(char)type {
	if (force > 0) {
		if (([[universe playerThatIsMe] flags] & flag) != (force & 0xFF)) {
			[self sendShortPacketNoForceWithId:type state: (force & 0xFF)];
			force -= 0x100;
			if (force < 0x100) {
				force = -1;  // give up
			}
		} 
		else {
			force = -1;
		}
	}
	return force;
}

- (int) forceCheckValue:(int) value force:(int) force type:(char) type {
	if (force > 0) {
		if (value != (force & 0xFF)) {
			[self sendShortPacketNoForceWithId:type state:(force & 0xFF)];
			force -= 0x100;
			if (force < 0x100) {
				force = -1;	// give up
			}
		} 
		else {
			force = -1; 
		}
	}
	return force;
}

- (int) forceCheckTractFlag:(int) flag force:(int) force type:(char) type {
	if (force > 0) {
		if ((([[universe playerThatIsMe] flags] & flag) != 0) ^ ((force & 0xFF) != 0)) {
			int state = ((force & 0xFF) >= 0x40) ? 1 : 0;
			int pnum = (force & 0xFF) & (~0x40);
			buffer[0] = type;
			buffer[1] = (char)state;
			buffer[2] = (char)pnum;
			[self sendServerPacketWithBuffer:buffer length:4];
			force -= 0x100;
			if (force < 0x100) {
				force = -1;	// give up
			}
		}
		else {
			force = -1;
		}
	}
	return force;
}

- (void) checkForce {
	
	// speed almost always repeats because it takes a while to accelerate/decelerate
	// to the desired value
	Player *me= [universe playerThatIsMe];
	fSpeed    = [self forceCheckValue: [me speed] force:fSpeed type: CP_SPEED];
	fShield   = [self forceCheckFlags: PLAYER_SHIELD force:fShield type:CP_SHIELD];
	fOrbit    = [self forceCheckFlags: PLAYER_ORBIT force:fOrbit type:CP_ORBIT];
	fRepair   = [self forceCheckFlags: PLAYER_REPAIR force:fRepair type:CP_REPAIR];
	fBeamup   = [self forceCheckFlags: PLAYER_BEAMUP force:fBeamup type:CP_BEAM];
	fBeamdown = [self forceCheckFlags: PLAYER_BEAMDOWN force:fBeamdown type:CP_BEAM];
	fCloak    = [self forceCheckFlags: PLAYER_CLOAK force:fCloak type:CP_CLOAK];
	fBomb     = [self forceCheckFlags: PLAYER_BOMB force:fBomb type:CP_BOMB];
	fDockperm = [self forceCheckFlags: PLAYER_DOCKOK force:fDockperm type:CP_DOCKPERM];
	fPhaser   = [self forceCheckValue: [[universe phaserWithId:[me phaserId]] status] force:fPhaser type:CP_PHASER];
	fPlasma   = [self forceCheckValue: [[universe plasmaWithId:[me plasmaId]] status] force:fPlasma type:CP_PLASMA];
	fPlayLock = [self forceCheckFlags: PLAYER_PLOCK force:fPlayLock type:CP_PLAYLOCK];
	fPlanLock = [self forceCheckFlags: PLAYER_PLLOCK force:fPlanLock type:CP_PLANLOCK];
	fTractor  = [self forceCheckTractFlag: PLAYER_TRACT force:fTractor type:CP_TRACTOR];
	fRepressor= [self forceCheckTractFlag: PLAYER_PRESS force:fRepressor type:CP_REPRESS];
}

// server packets
// these routines can be invoked by sending a notification
// see the header file for the proper invokation
// alternativly you can call them directly on the Communication object.
//
-(void)cleanUp:(id)sender {
	LLLog(@"Communication.cleanUp entered");
    if (tcpReader != nil) {
        [self sendByeReq:self];
        [tcpReader close];
        [tcpReader release];
        tcpReader = nil;
    }
    if (udpReader != nil) {
        [udpReader close];
        [udpReader release];
        udpReader = nil;
    }
    if (udpSender != nil) {
        [udpSender close];
        [udpSender release];
        udpSender = nil;
    }
    if (tcpSender != nil) {
        [tcpSender close];
        [tcpSender release];
        tcpSender = nil;
    }
    // remove all subscriptions
    // run - (void)subscribeToNotifications to reconnect
    //[notificationCenter removeObserver:self name:nil];
}

// convieniance function
-(void)readFromServer:(id)sender {
    [self readFromServer];
}


-(bool)readFromServer {
	
	bool readOk = YES;
    //static NSTimeInterval start, stop;
    
    //start = [NSDate timeIntervalSinceReferenceDate]; 
    //LLLog(@"Communication.readFromServer(slept): %f sec", (start-stop)); 
    //LLLog(@"Communication.readFromServer entered");
    
    // read from UDP connection
    if(udpReader != nil && commStatus != STAT_SWITCH_TCP && (udpReceiveMode != MODE_TCP)) {
        @try {
            [udpReader readFromServer];
        }
        @catch(NSException *e) {
			LLLog(@"Communication.readFromServer ERROR reading UDP: %@", [e reason]);
            [self sendUdpReq:COMM_TCP];
            [self closeUdpConn];
		    readOk = NO;
			commMode = COMM_TCP;
			[notificationCenter postNotificationName:@"COMM_MODE_CHANGED" userInfo:[NSNumber numberWithInt:commMode]];
        }
        
        if (commStatus == STAT_VERIFY_UDP) {
            [udpStats setSequence:0];// reset sequence #s
			[self resetForce];
			
			commMode = COMM_UDP;
			commStatus = STAT_CONNECTED;
			LLLog(@"Communication.readFromServer connected to server on UDP and verified both ways");
			[notificationCenter postNotificationName:@"COMM_MODE_CHANGED" userInfo:[NSNumber numberWithInt:commMode]];	
			[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];
			
			if (udpReceiveMode != MODE_SIMPLE) {
				[self sendUdpReq:[NSNumber numberWithChar:(COMM_MODE + (udpReceiveMode & 0xFF))]];
			}

        }
        
        [self checkForce];
    }
    
    // read from TCP connection
    @try {
        if(tcpReader != nil) {
            [tcpReader readFromServer];
        }
    }
    @catch(NSException *e) {
        LLLog(@"Communication.readFromServer exception %@: %@", [e name], [e reason] );
        [notificationCenter postNotificationName:@"COMM_GHOSTBUSTED" object:self 
                                        userInfo:@"Whoops!  We've been ghostbusted!"];
		readOk = NO;
        if (commMode == COMM_UDP) {
            [self closeUdpConn];
        }
        commMode = commModeRequest = COMM_TCP;
		[notificationCenter postNotificationName:@"COMM_MODE_CHANGED" userInfo:[NSNumber numberWithInt:commMode]];
        
		/* MacTrek 1.1.0 resurection rarely works and usually locks down the 
			entire program because this thread does a blocking read 
			why actually? */
		// ------ GHOSTBUST RESURECT ------ 
		
		LLLog(@"Communication.readFromServer attemting resurrection");
		
		// this next port stuff does not seem to work $$$
        if([self connectToServerUsingNextPort]) {
		// try something new			
		// int port = [tcpSender serverPort]; // get the port from the socket
		// LLHost *server = [tcpSender serverHost];
		//if ([self callServer:[server address] port:port]) {
			
            [notificationCenter postNotificationName:@"COMM_RESURRECTED" object:self 
                                            userInfo:@"Yea!  We've been resurrected!"];
			LLLog(@"Communication.readFromServer Yea!  We've been resurrected!");
			readOk = YES;
        }
        else {
            [notificationCenter postNotificationName:@"COMM_RESURRECT_FAILED" object:self 
                                            userInfo:@"Sorry,  We could not be resurrected!"];
			LLLog(@"Communication.readFromServer Sorry,  We could not be resurrected!");
			readOk = NO;
        }
		
		// ------ GHOSTBUST RESURECT ------
    }
    
    //stop = [NSDate timeIntervalSinceReferenceDate];  
    //LLLog(@"Communication.readFromServer(spent): %f sec", (stop-start));
	return readOk;
}

- (void) sendSpeedReq:(NSNumber*) speed {
    [self sendShortPacketWithId:CP_SPEED state: (char)[speed intValue]];		
}

- (void) sendDockingReq:(NSNumber*) on {
    [self sendShortPacketWithId:CP_DOCKPERM boolState:[on boolValue]];
}

- (void) sendCloakReq:(NSNumber*) on {
    [self sendShortPacketWithId:CP_CLOAK boolState:[on  boolValue]];
}

- (void) sendRefitReq:(NSNumber *) ship {
    [self sendShortPacketWithId:CP_REFIT state:[ship charValue]];
}

- (void) sendDirReq:(NSNumber *) dir {
    [self sendShortPacketWithId:CP_DIRECTION state:[dir charValue]];
}

- (void) sendPhaserReq:(NSNumber *) dir {
    [self sendShortPacketWithId:CP_PHASER state:[dir charValue]];
}

- (void) sendTorpReq:(NSNumber *) dir {
    [self sendShortPacketWithId:CP_TORP state:[dir charValue]];
}

- (void) sendPlasmaReq:(NSNumber *) dir {
    [self sendShortPacketWithId:CP_PLASMA state:[dir charValue]];
}

- (void) sendShieldReq:(NSNumber*) on {
    [self sendShortPacketWithId:CP_SHIELD boolState:[on boolValue]];
}

- (void) sendBombReq:(NSNumber*) bomb {
    [self sendShortPacketWithId:CP_BOMB boolState:[bomb boolValue]];
}

- (void) sendBeamReq:(NSNumber*) up {
    [self sendShortPacketWithId:CP_BEAM state:(char)([up boolValue] ? 1 : 2)];
}

- (void) sendRepairReq:(NSNumber*) on {
    [self sendShortPacketWithId:CP_REPAIR boolState:[on boolValue]];
}

- (void) sendOrbitReq:(NSNumber*) orbit {
    [self sendShortPacketWithId:CP_ORBIT boolState:[orbit boolValue]];
}

- (void) sendQuitReq:(id)sender {
	LLLog(@"Communication.sendQuitReq entered");
    [self sendShortPacketWithId:CP_QUIT];
}

- (void) sendCoupReq:(id)sender {
    [self sendShortPacketWithId:CP_COUP];
}

- (void) sendByeReq:(id)sender {
	LLLog(@"Communication.sendByeReq entered");
    [self sendShortPacketWithId:CP_BYE];
}

- (void) sendPractrReq:(id)sender {
    [self sendShortPacketWithId:CP_PRACTR];
}

- (void) sendDetonateReq:(id)sender {
    [self sendShortPacketWithId:CP_DET_TORPS];
}

- (void) sendPlaylockReq:(NSNumber *) player {
    [self sendShortPacketWithId:CP_PLAYLOCK state:(char)[player intValue]];
}

- (void) sendPlanlockReq:(NSNumber *) planet {
    [self sendShortPacketWithId:CP_PLANLOCK state:(char)[planet intValue]];
}

- (void) sendResetStatsReq:(NSNumber *) verify {
    [self sendShortPacketWithId:CP_RESETSTATS state:[verify charValue]];
}

- (void) sendWarReq:(NSNumber *) mask {
    [self sendShortPacketWithId:CP_WAR state:[mask charValue]];
}

- (void) sendTractorOnReq:(NSNumber *) player {
	buffer[0] = CP_TRACTOR;
	buffer[1] = 1; // on
	buffer[2] = [player charValue];
	[self sendServerPacketWithBuffer:buffer length:4];
	// stop force
	fRepressor = 0;
	fTractor = [player charValue] | 0x40;
}

- (void) sendTractorOffReq:(NSNumber *) player {
	buffer[0] = CP_TRACTOR;
	buffer[1] = 0; // off
	buffer[2] = [player charValue];
	[self sendServerPacketWithBuffer:buffer length:4];
	fTractor = 0;
}

- (void) sendRepressorOnReq:(NSNumber *) player {
	buffer[0] = CP_REPRESS;
	buffer[1] = 1; // on
	buffer[2] = [player charValue];
	[self sendServerPacketWithBuffer:buffer length:4];
	// stop force
	fTractor = 0;
	fRepressor = [player charValue] | 0x40;
}

- (void) sendRepressorOffReq:(NSNumber *) player {
	buffer[0] = CP_REPRESS;
	buffer[1] = 0; // off
	buffer[2] = [player charValue];
	[self sendServerPacketWithBuffer:buffer length:4];
	fRepressor = 0;
}

- (void) sendTeamReq:(NSDictionary *)newTeam {
	buffer[0] = CP_OUTFIT;
	buffer[1] = [[newTeam valueForKey:@"team"] charValue];
	buffer[2] = [[newTeam valueForKey:@"ship"] charValue];
	[self sendServerPacketWithBuffer:buffer length:4];
}

-(void) sendDetMineReq:(NSNumber *) torpId {
	buffer[0] = CP_DET_MYTORP;
	buffer[2] = (char)(([torpId intValue] >> 8) & 0xFF);
	buffer[3] = (char)([torpId intValue] & 0xFF);
	[self sendServerPacketWithBuffer:buffer length:4];
}

- (void) sendFeature:(NSDictionary *)newFeature {
	buffer[0]= CP_FEATURE; 
	buffer[1] = [[newFeature valueForKey:@"type"] charValue];
	buffer[2] = [[newFeature valueForKey:@"arg1"] charValue];
	buffer[3] = [[newFeature valueForKey:@"arg2"] charValue];
	[self bigEndianInteger:[[newFeature valueForKey:@"value"] intValue] inBuffer:buffer withOffset:4];
	NSString *name = [newFeature valueForKey:@"name"];
	[self insertString:name inBuffer:buffer offset:8 maxLength:79];
	[self sendServerPacketWithBuffer:buffer length:88];
}

- (void) sendLoginReq:(NSDictionary *)login {
	buffer[0]= CP_LOGIN; 
	buffer[1] = (char)([login valueForKey:@"query"] ? 1 : 0);
	NSString *name = [login valueForKey:@"name"];
	NSString *pass = [login valueForKey:@"pass"];
	NSString *log  = [login valueForKey:@"login"];
    [self insertString:name inBuffer:buffer offset:4 maxLength:15];
    [self insertString:pass inBuffer:buffer offset:20 maxLength:15];
    [self insertString:log  inBuffer:buffer offset:36 maxLength:15];
	[self sendServerPacketWithBuffer:buffer length:52];
}

- (void) sendReservedReply:(NSData *)sreserved {
	
	// this client supports RSA thus we do not have
	// to encrypt old style. Only to tell the server
	// which version of RSA we support
	LLLog(@"Communication.sendReservedReply responding with: RSA v2.0 CLIENT");

	buffer[0] = CP_RESERVED;	
	// sreserved contains 16 bytes that are key
	// they are put in the buffer from 4..20
	memcpy(&buffer[4], (char *) [sreserved bytes], 16);
    
	// buffer 20..36 contain the response (can be shorter)
	memcpy(&buffer[20], "RSA v2.0 CLIENT", 15);
	// clear if shorter
    buffer[ (15 + 20) ] = 0;
	
	[self sendServerPacketWithBuffer:buffer length:36];		
}

- (void) sendRSAResponse:(NSMutableData *)data {
	
    buffer[0] = CP_RSA_KEY;
	
    int port = [tcpSender serverPort]; // get the port from the socket
    LLHost *server = [tcpSender serverHost];
	
	LLLog(@"Communication.sendRSAResponse responding with: %@:%d",
		[server hostname], port);
	
    NSMutableData *response = [rsaCoder encode:data forHost:server onPort:port];
	
	memcpy(&buffer[4], [response bytes], [response length]);
	[self sendServerPacketWithBuffer:buffer length:(4 + [response length])];	

	// and discard the data
   [data autorelease];
   [response autorelease];
}

- (void) sendPingReq:(NSNumber *)start {
	buffer[0] = CP_PING_RESPONSE;
	buffer[2] = (char)([start boolValue] ? 1 : 0); // on or off
                                                   // strange, i would expect length 3
                                                   // but code sais 12 prob a copy error from response
                                                   // checked with server: should be 12
	[self sendServerPacketWithBuffer:buffer length:12];
}

- (void) sendServerPingResponse:(NSNumber *) number {
	buffer[0] = CP_PING_RESPONSE;
	buffer[1] = [number charValue];
	buffer[2] = (char)(ping ? 1 : 0);
	[self bigEndianInteger:[udpStats packetsSent] + ((commMode == COMM_UDP && udpSendMode) ? 1 : 0) inBuffer:buffer withOffset:4];
    [self bigEndianInteger:[udpStats packetsReceived] inBuffer:buffer withOffset:8];
    [self sendServerPacketWithBuffer:buffer length:12];
}

- (void) sendMessage:(NSDictionary *)mess {
	buffer[0] = CP_MESSAGE;
	buffer[1] = [[mess valueForKey:@"group"] charValue];
	buffer[2] = [[mess valueForKey:@"indiv"] charValue];
	NSString *message = [mess valueForKey:@"message"];
	LLLog(@"Communication.sendMessage %@ from %x to %x", message, [[mess valueForKey:@"indiv"] charValue], [[mess valueForKey:@"group"] charValue]);
    [self insertString:message inBuffer:buffer offset:4 maxLength:79];
	[self sendServerPacketWithBuffer:buffer length:84];
}

- (void) sendUpdatePacket:(NSNumber *) updates_per_second {
	// avoid sending unnecairy packets
	if(updatesPerSecond == [updates_per_second intValue]) {
		return;
	}
	updatesPerSecond = [updates_per_second intValue];
	buffer[0]= CP_UPDATES;
	[self bigEndianInteger:1000000 / [updates_per_second intValue] inBuffer:buffer withOffset:4];
	[self sendServerPacketWithBuffer:buffer length:8];
}

- (void) sendShortReq:(NSNumber *) state {
	buffer[0] = CP_S_REQ;
	buffer[1] = [state charValue];
	buffer[2] = shortVersion;
	[self sendServerPacketWithBuffer:buffer length:4];
    
	// generate proper events
	switch ([state charValue]) {
        case SPK_VON :
       		[notificationCenter postNotificationName:@"COMM_PACKET_REQUEST_SHORT_SENT" object:self 
                                            userInfo:@"Sending short packet request"];
            break;
        case SPK_VOFF :
         	[notificationCenter postNotificationName:@"COMM_PACKET_REQUEST_OLD_SENT" object:self 
                                            userInfo:@"Sending old style packet request"];
            break;
	}
    
	// reset torps if needed
	if(receiveShort && ([state charValue] == SPK_SALL || [state charValue] == SPK_ALL)) {
		// Let the client do the work, and not the network :-)
		[universe setAllTorpsStatus:TORP_FREE];
		[universe setAllPlasmasStatus:PLASMA_FREE];
		[universe setAllPhasersStatus:PHASER_FREE];
        
        [notificationCenter postNotificationName:@"COMM_PACKET_REQUEST_SMALL_UPDATE" object:self 
                                        userInfo:@"Sending small update request"];
	}
}

- (void) sendThreshold:(NSNumber*) threshold {
	buffer[0] = CP_S_THRS;
	buffer[2] = (char)(([threshold intValue] >> 8) & 0xFF);
	buffer[3] = (char)( [threshold intValue] & 0xFF);
	[self sendServerPacketWithBuffer:buffer length:4];
}

- (void) sendDetonateMyTorpsReq:(id)sender {
	Torp *torp;
	NSArray *torps = [[universe playerThatIsMe] torps];
	for (int t = 0; t < [torps count]; t++) {
		torp = [torps objectAtIndex:t];
		if ([torp status] == TORP_MOVE || [torp status] == TORP_STRAIGHT) {
			[self sendDetMineReq: [NSNumber numberWithChar:(char)[torp weaponId]]];
			if (receiveShort) {
				// Let the server det for me
				// it needs only one....
				break;
			}
		}
	}
}

- (void) sendOptionsPacket:(id)sender {
    buffer[0] = CP_OPTIONS;
    
    int flags = 
        (STATS_MAPMODE				
         + STATS_NAMEMODE
         + STATS_SHOWSHIELDS			
         + STATS_KEEPPEACE
         + STATS_SHOWLOCAL
         + STATS_SHOWGLOBAL);
    [self bigEndianInteger:flags inBuffer:buffer withOffset:4];
    
    // insert a blank string as the keymap
    [self insertString:@"" inBuffer:buffer offset:8 maxLength:96];
    [self sendServerPacketWithBuffer:buffer length:104];
}

/** pickSocket */
- (int) sendSocketVersionAndNumberReq:(int)port {
    return [self sendPickSocketReq:[NSNumber numberWithInt:port]];
}

- (int) sendPickSocketReq {
    return [self sendPickSocketReq:[NSNumber numberWithInt:nextPort]];
}

- (int) sendPickSocketReq:(NSNumber*) startAtPort {
    int old_port = [startAtPort intValue];
    
    nextPort = (int)(random() & 32767);
    while (nextPort < 2048 || nextPort == old_port) {
        nextPort = ((nextPort + 10687) & 32767);
    }
    buffer[0] = CP_SOCKET;
    buffer[1] = SOCKVERSION;
    buffer[2] = UDPVERSION;
    [self bigEndianInteger:nextPort inBuffer:buffer withOffset:4];
    [self sendServerPacketWithBuffer:buffer length:8];
    
    // tell everyone about our new port
    //[notificationCenter postNotificationName:@"COMM_PICK_SOCKET_SENT" object:self 
    //                                userInfo:[NSNumber numberWithInt:nextPort]];
    
    return nextPort;
}

- (void) sendUdpReq:(NSNumber*) request {
    char req = [request charValue];
    
    buffer[0] = CP_UDP_REQ;
    buffer[1] = (char)(req & 0xFF);
    
    // first handle the special cases    
    if (req >= COMM_MODE) {
        buffer[1] = COMM_MODE;
        buffer[2] = (char)((req - COMM_MODE) & 0xFF);
        [self sendServerPacketWithBuffer:buffer length:8];
        return;
    }
    
    if (req == COMM_UPDATE) {
        if (receiveShort) {
            // Let the client do the work, and not the network
            [universe resetWeaponInfo];
        }
        
        [self sendServerPacketWithBuffer:buffer length:8];
        [notificationCenter postNotificationName:@"COMM_UPDATE_REQ_SENT" object:self 
                                        userInfo:@"Sent request for full update"];
        return;
    }
    
    if (req == commModeRequest) {
        [notificationCenter postNotificationName:@"COMM_UPDATE_REQ_DUPLICATE" object:self 
                                        userInfo:@"Request is in progress, do not disturb"];
        return;
    }
    
    // handle the normal cases
    // start by opening the connection
    if (req == COMM_UDP) {
        // open UDP port
        if([self openUdpConn]) {
            LLLog([NSString stringWithFormat:@"Communication.sendUdpReq: bind to local port %d success", localUdpPort]);
			[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];
        }
        else {
            LLLog([NSString stringWithFormat:@"Communication.sendUdpReq: bind to local port %d failed", localUdpPort]);
            commModeRequest = COMM_TCP;
            commStatus = STAT_CONNECTED;
			[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];

            return;
        }
    }
    //
    // send the actual request
    buffer[0] = CP_UDP_REQ;
    buffer[1] = req;
    buffer[2] = CONNMODE_PORT; // we get addr from packet
    [self bigEndianInteger:localUdpPort inBuffer:buffer withOffset:4];
    [self sendServerPacketWithBuffer:buffer length:8];
    
    // update internal state stuff
    commModeRequest = req;
    if (req == COMM_TCP) {
        commStatus = STAT_SWITCH_TCP;
    }
    else {
        commStatus = STAT_SWITCH_UDP;
    }
    [notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];

    NSString *message = [NSString stringWithFormat:@"UDP: Sent request for %@ mode", (req == COMM_TCP ? @"TCP" : @"UDP")];
    LLLog([NSString stringWithFormat:@"Communication.sendUdpReq: %@", message]);
}

- (void) sendUdpVerify:(id)sender {
    buffer[0] = CP_UDP_REQ;
    buffer[1] = COMM_VERIFY;
    buffer[2] = (char)0;
    [self bigEndianInteger:0 inBuffer:buffer withOffset:4];
    if (![udpSender sendBuffer:buffer length:8]) {
        LLLog(@"Communication.sendUdpVerify: UDP: send failed.  Closing UDP connection");  
       
        [notificationCenter postNotificationName:@"COMM_UDP_LINK_SEVERED" object:self 
                                        userInfo:@"UDP link severed"];
        // update vars
        commModeRequest = commMode;
        commStatus = STAT_CONNECTED;
        [notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];

        // loop back 
        [self sendUdpReq:COMM_TCP];
        [self closeUdpConn];
    }
}

//------------------------------------------------------------------------------
// setup communication
//------------------------------------------------------------------------------
- (bool) callServer:(NSString *)server port:(int) port {
    
    LLHost *hostName;
	LLTCPSocket *socket;
    
    LLLog([NSString stringWithFormat:@"Communication.callServer: %@ at %d", server, port]);
    @try {
        // try this
        hostName = [LLHost hostWithName:server];
    }
    @catch (NSException * e) {
        LLLog([NSString stringWithFormat:@"Communication.callServer: %@", [e reason]]);
        return NO;
    }    
	
    @try {
        // connect and create a stream
        socket = [[LLTCPSocket alloc] init];
        [socket connectToHost:hostName port:port];
		[socket setBlocking:NO]; // or this may lock the entire thread !
        LLLog(@"Communication.callServer: got connection parameters");
        // create a sender and receiver
        [tcpSender release];
        tcpSender = [[ServerSenderTcp alloc] initWithSocket:socket];
        [tcpReader release];
        tcpReader = [[ServerReaderTcp alloc] initWithUniverse:universe communication:self socket:socket];
		[tcpReader setTimeOut:COMM_NETWORK_TIMEOUT]; // should set timeout to 4 min ?
        // pickSocket() is required here to send which version we are useing of Sockets
        [self sendSocketVersionAndNumberReq:port];
    }
    @catch (NSException * e) {
        LLLog(@"Communication.callServer: error connecting to %@ reason %@", hostName, [e reason]);
        return NO;
    }
    
    // get the server features
    [self sendFeature:[NSDictionary dictionaryWithObjectsAndKeys:
        @"FEATURE_PACKETS", @"name", 
        [NSNumber numberWithChar:'S'], @"type", 
        [NSNumber numberWithInt:1] ,   @"value", 
        [NSNumber numberWithInt:0],    @"arg1", 
        [NSNumber numberWithInt:0],    @"arg2", nil]];
    
    return YES;
}

// the connectToServer routines are only used when starting up with a socket on the prompt and autologin
// otherwise use callServer
- (bool) connectToServerUsingNextPort {
    // tell the server to pick a port and use it ourself	
    return [self connectToServerUsingPort:nextPort];
}

- (bool) connectToServerUsingPort:(int) port {
    return [self connectToServerUsingPort:port expectedHost:nil];
}

// not sure if we need the hostname at all? it is only used in log statements
- (bool) connectToServerUsingPort:(int) port expectedHost:(NSString *) host {
    
    LLHost *hostName;
    
    LLLog([NSString stringWithFormat:@"Communication.connectToServer: (%@) Waiting for connection at port %d", host, port]);
    
    // setup a TCP server, and accept the first incomming connection
    LLTCPSocket *serverTCPSocket, *connectionTCPSocket;
    
    @try {        
        serverTCPSocket = [[LLTCPSocket alloc] init];
        [serverTCPSocket listenOnPort:port];    
    }
    @catch (NSException * e) {
        LLLog(@"Communication.connectToServer: error creating socket %d", port);
        return false;
    }
    
    @try {
        connectionTCPSocket = [serverTCPSocket acceptConnectionAndKeepListening];
        LLLog(@"Communication.connectToServer: got connection");
		// set to non-blocking communication
		[serverTCPSocket setBlocking:NO];
    }
    @catch (NSException * e) {
        LLLog(@"Communication.connectToServer: error accepting connection on socket %d", port);
        return false;
    }
    
    // use the passed hostname or else get it from the connection
    // (why not always get it from the connection?)
    if(host == nil) {
        hostName = [connectionTCPSocket remoteHost];
    } else {
        hostName = [LLHost hostWithName:host];
    }
    
    @try {
        // create a sender and receiver
        [tcpSender release];
        tcpSender = [[ServerSenderTcp alloc] initWithSocket:connectionTCPSocket];
        [tcpReader release];
        tcpReader = [[ServerReaderTcp alloc] initWithUniverse:universe communication:self socket:connectionTCPSocket];
		[tcpReader setTimeOut:COMM_NETWORK_TIMEOUT]; // should set timeout to 4 min ?
        // pickSocket() is required here to send which version we are useing of Sockets
        [self sendSocketVersionAndNumberReq:port];
    }
    @catch (NSException * e) {
        LLLog([NSString stringWithFormat:@"Communication.connectToServer: error connecting to %@", hostName]);
        return false;
    }
    LLLog([NSString stringWithFormat:@"Communication.connectToServer: got connection to %@ at %d", hostName, port]);
    return YES;
}

// private UDP routine
- (bool) openUdpConn {
    
    // if baseLocalUdpPort is defined, we want to start from that
    if(baseLocalUdpPort > 0)  {
        localUdpPort = baseLocalUdpPort;
        LLLog([NSString stringWithFormat:@"Communication.openUdp: UDP: using base port %d", baseLocalUdpPort]);
    }
    else {
        localUdpPort = (int)(random() & 32767);
    }
    
    for(int attempts = 0; attempts < MAX_PORT_RETRY; ++attempts) {
        while(localUdpPort < 2048) {
            localUdpPort = ((localUdpPort + 10687) & 32767);
        }
        
        @try {
            // connect and create a socket
            LLUDPSocket *udpSocket = [[LLUDPSocket alloc] init];
            [udpSocket listenOnPort: localUdpPort];
            //[udpSocket setAllowsBroadcast: YES]; // In  case we are sending to the broadcast address
            
			LLLog([NSString stringWithFormat:@"Communication.openUdp: UDP: port is %d", localUdpPort]);
            
            // setup the reader 
            [udpReader release];
            udpReader = [[ServerReaderUdp alloc] initWithUniverse:universe communication:self socket:udpSocket udpStats:udpStats];
			[udpReader setTimeOut:COMM_NETWORK_TIMEOUT]; 
			[udpReader setSequenceCheck:udpSequenceChecking];

            
            return true;
        }
        @catch(NSException *e) {
            // bind() failed, so find another port.  If we're tunneling through a
            // router-based firewall, we just increment; otherwise we try to mix it
            // up a little.  The check for ports < 2048 is done above.
            if(baseLocalUdpPort > 0) {
                ++localUdpPort;
            }
            else {
                localUdpPort = ((localUdpPort + 10687) & 32767);
            }
        }
    }
    LLLog(@"Communication.openUdp: UDP: Unable to find a local port to bind to");
    return false;
}

- (void) connectToServerUdpAtPort:(int) port {
	// setup the udp writer
	//LLUDPSocket *udpSocket = [[LLUDPSocket alloc] init];
	LLUDPSocket *udpSocket = [udpReader udpSocket]; // use the same socket as the reader	
	
	// try to connect to the servers udp port
	LLHost *server = [tcpSender serverHost]; // first get the server name
	[udpSocket connectToHost:server port:port]; // set it up in the socket
	
	LLLog(@"Communication.connectToServerUdpAtPort: %@:%d", [server hostname], port);
	
	[udpSender release];
	udpSender = [[ServerSenderUdp alloc] initWithSocket:udpSocket];
}

- (void) closeUdpConn {
    LLLog(@"Communication.closeUdpConn: UDP: Closing UDP socket");
	if (udpReader) {
		[udpReader close];
		[udpReader release];
		udpReader = nil;
	}
	if (udpSender) {
		[udpSender close];
		[udpSender release];
		udpSender = nil;
	}
}

- (void) forceResetToTCP:(id)sender {
    LLLog(@"Communication.forceResetToTCP: UDP: FORCE RESET REQUESTED"); 
    [self sendUdpReq:[NSNumber numberWithChar:COMM_TCP]];

    commMode = commModeRequest = COMM_TCP;
	[notificationCenter postNotificationName:@"COMM_MODE_CHANGED" userInfo:[NSNumber numberWithInt:commMode]];
    commStatus = STAT_CONNECTED;
	[notificationCenter postNotificationName:@"COMM_STATE_CHANGED" userInfo:[NSNumber numberWithInt:commStatus]];
	udpReceiveMode = MODE_TCP;
	udpSendMode = MODE_TCP;
	[self setUdpSequenceCheck:[NSNumber numberWithBool:YES]];

    [self closeUdpConn];
}

// THREAD stuff
- (void) setUpAndRunThread:(id)sender {
   
    // create a private pool for this thread
    NSAutoreleasePool *tempPool = [[NSAutoreleasePool alloc] init];
    
    LLLog(@"Communication.setUpAndRunThread: start running");
    //[notificationCenter postNotificationName:@"COMM_STARTED_THREAD" object:self userInfo:nil];
    
    // add this thread to the main run loop..
    //[[NSRunLoop currentRunLoop] run];
    [self run:self];	
	
    LLLog(@"Communication.setUpAndRunThread: stopped running");
    //[notificationCenter postNotificationName:@"COMM_STOPPED_THREAD" object:self userInfo:nil];
    
    // release the pool
    [tempPool release];  
}

- (void) run {
    [self run:self];
}

- (void) run:(id)sender {
    LLLog(@"Communication.run started");
    // keep reading in blocked mode from the server
    // despatch event of what we got. Some reads may result in writes within the same
    // thread, therefor all access to the sendXXX methods are synchronized using locks
    
	//static float start, stop;
	
    if (multiThreaded) {        
        //NSTimeInterval start, stop;
        while (keepRunning) {
            //start = [NSDate timeIntervalSinceReferenceDate]; 
            //LLLog(@"Communication.run(slept): %f sec", (start-stop));        
			if (goSleeping && !isSleeping) {
				LLLog(@"Communication.run going to sleep");
				isSleeping = YES;				
			} else if (isSleeping && !goSleeping) {
				LLLog(@"Communication.run going to awake from sleep");
				isSleeping = NO;	
			}
				
			if (isSleeping) {
				sleep(COMM_NETWORK_TIMEOUT);
				//LLLog(@"Communication.run snort snort");
			} else {
				if ([self readFromServer] == NO) {
					LLLog(@"Communication.run ERROR detected going to sleep");
					// error occured, better stop
					 goSleeping = YES;
				} else {
					// read ok, if not TCP then UDP stats have changed
					if (commMode != COMM_TCP) {
						static int i = 0;
						if (i < 10) { // reduce load, do not report all changes
							i++;
						} else {
							[notificationCenter postNotificationName:@"COMM_UDP_STATS_CHANGED" userInfo:udpStats];
						}
					}
				}
			}
            //stop = [NSDate timeIntervalSinceReferenceDate];  
            //LLLog(@"Communication.run(blocking): %f sec", (stop-start));            
        }
        LLLog(@"Communication.run stopped");
        isRunning = NO; // must do this in setUpAndRunThread or the object will be
						// destroyed before the pool is released ??
    } else {
        // try a timer every 10ms when running in the main loop
        [NSTimer scheduledTimerWithTimeInterval: 0.001
                                         target:self selector:@selector(readFromServer)
                                       userInfo:nil 
                                        repeats:YES];  
    }
}

// must be called periodically if we are not in a seperate thread.
- (void) periodicReadFromServer {
    if (isRunning && keepRunning) {
        [self readFromServer];
    }
}

- (bool) startCommunicationThread {
    // spawns seperate thread that listens to the server
    if (isRunning) {
        LLLog(@"Communication.startCommunicationThread: already running");
        return NO;
    }
    // detatch a new thread and start listening
    isRunning = YES;
    keepRunning = YES;

    [NSThread detachNewThreadSelector:@selector(setUpAndRunThread:) toTarget:self withObject:nil];
	// this works but leaks like hell
	//[NSThread detachNewThreadSelector:@selector(run:) toTarget:self withObject:nil];

    return YES;
}

- (bool) stopCommunicationThread {
    if (!isRunning) {
        LLLog(@"Communication.stopCommunicationThread: not running");
        return NO;
    }  
    LLLog(@"Communication.stopCommunicationThread: asking thread to stop wait for notification");
    keepRunning = NO;   
	
	// wait for thread to exit
	while (isRunning)  {
		LLLog(@"Communication.stopCommunicationThread: waiting for stop");
		sleep(COMM_NETWORK_TIMEOUT);
	}
    LLLog(@"Communication.stopCommunicationThread: thread stopped");
    return YES;
}

// stopping threads leads to strange bugs, better sleep in stead of reading and
// reanimate later on
- (bool) suspendCommunicationThread {
	if (!isRunning) {
        LLLog(@"Communication.suspendCommunicationThread: not running");
        return NO;
    } 
	goSleeping = YES;
	
	// wait for thread to sleep
	int count = 0;
	while (!isSleeping)  {
		LLLog(@"Communication.suspendCommunicationThread: waiting for sleep");
		count++;
		sleep(COMM_NETWORK_TIMEOUT);
		if (count > MAX_WAIT_BEFORE_CONTINUE){
			LLLog(@"Communication.suspendCommunicationThread: never went to sleep enforce mode");
			isSleeping = YES;
		}
	}
    LLLog(@"Communication.suspendCommunicationThread: thread sleeping");
    return YES;
}

- (bool) awakeCommunicationThread {
	if (!isSleeping) {
        LLLog(@"Communication.awakeCommunicationThread: not sleeping");
        return NO;
    } 
	goSleeping = NO;
	
	// wait for thread to awake
	while (isSleeping)  {
		LLLog(@"Communication.awakeCommunicationThread: waiting for awake");
		sleep(COMM_NETWORK_TIMEOUT);
	}
    LLLog(@"Communication.awakeCommunicationThread: thread awake");
    return YES;
}

- (bool) isSleeping {
	return isSleeping;
}

- (bool) isRunning {
	return isRunning;
}

@end
