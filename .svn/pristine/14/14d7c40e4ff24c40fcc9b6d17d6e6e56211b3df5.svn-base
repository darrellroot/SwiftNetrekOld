//-------------------------------------------
// File:  ServerReader.h
// Class: ServerReader
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
//
// Event based serverReader. Posts events when receiving an update.
// sometimes the update is put in the userData. The following events are generated:
//
// communication:
//
//          SP_UDP_SWITCHED_TO_TCP
//          SP_TCP_SWITCHED_TO_UDP  with userInfo: port 
//          SP_SWITCHED_DENIED            
//          SP_SWITCH_VERIFY
//          SP_ASK_FOR_COMM_UPDATE
//          SP_S_REPLY_SPK_OLD with userInfo: packetMode 
//          SP_S_REPLY_SPK_VOFF with userInfo: commMessageToBeSent
//          SP_S_REPLY_SPK_VONwith userInfo: commMessageToBeSent 
//          SP_RESERVED with userInfo: sreserved
//          SP_RSA_KEY with userInfo: data
//          SP_PING with userInfo: pingStats  
//          SP_FEATURE
// login:
//
//          SP_QUEUE with userInfo: queueSize
//          SP_PICKOK 
//          SP_PICKNOK  
//          SP_LOGIN_INVALID_SERVER
//          SP_LOGIN_ACCEPTED with userInfo: me
//          SP_LOGIN_NOT_ACCEPTED
//          SP_MASK  with userInfo: teamMask
//
// messages:
//
//          SP_MESSAGE with userInfo: obj  
//          SP_WARNING with userInfo: warning    
//          SP_MOTD with userInfo: line
//          SP_MOTD_SERVER_INFO with userInfo: line
//          SP_S_MESSAGE with userInfo: message
//          SPW_TEXTE with userInfo:message
//          SPW_PHASER_HIT_TEXT with userInfo:message
//          SPW_BOMB_INEFFECTIVE with userInfo:message
//          SPW_BOMB_TEXT with userInfo:message
//          SPW_BEAMUP_TEXT with userInfo:message
//          SPW_BEAMUP2_TEXT with userInfo:message
//          SPW_BEAMUPSTARBASE_TEXT with userInfo:message
//          SPW_BEAMDOWNSTARBASE_TEXT with userInfo:message
//          SPW_BEAMDOWNPLANET_TEXT with userInfo:message
//          SPW_SBREPORT with userInfo:message
//          SPW_ONEARG_TEXT with userInfo:message
//          SPW_BEAM_D_PLANET_TEXT with userInfo:message
//          SPW_BEAM_U_TEXT with userInfo:message
//          SPW_LOCKPLANET_TEXT with userInfo:message
//          SPW_LOCKPLAYER_TEXT with userInfo:message
//          SPW_SBRANK_TEXT with userInfo:message
//          SPW_SBDOCKREFUSE_TEXT with userInfo:message
//          SPW_SBDOCKDENIED_TEXT with userInfo:message
//          SPW_SBLOCKSTRANGER with userInfo:message
//          SPW_SBLOCKMYTEAM with userInfo:message
//          SPW_RCM_DMKILL with userInfo:rcm
//          SPW_RCM_DMKILLP with userInfo:rcm
//          SPW_RCM_DMBOMB with userInfo:rcm
//          SPW_RCM_DMDEST with userInfo:rcm
//          SPW_RCM_DMTAKE with userInfo:rcm
//          SPW_RCM_DMGHOSTKILL with userInfo:rcm
//          SPW_INLDRESUME with userInfo:message
//          SPW_INLDTEXTE with userInfo:message
//          SPW_STEXTE with userInfo:message
//          SPW_SHORT_WARNING with userInfo:message
//          SPW_STEXTE_STRING with userInfo:message
//          SPW_UNKNOWN with userInfo:message                                        
//
// players:
//
//          SP_V_PLAYER with userInfo: player     
//          SP_V_PLAYER with userInfo: player   
//          SP_PLAYER_INFO with userInfo: player
//          SP_KILLS with userInfo: player
//          SP_PLAYER with userInfo: player 
//          SP_PSTATUS with userInfo: player
//          SP_HOSTILE with userInfo: player
//          SP_STATS with userInfo: player
//          SP_FLAGS with userInfo: player
//          SP_S_KILLS with userInfo: player
//          SP_S_STATS with userInfo: player
//
// new player:
//
//          SP_PL_LOGIN with userInfo: player
//
// you:
//
//          SP_YOU with userInfo: me  
//          SP_STATUS with userInfo: status
//          SP_S_YOU with userInfo: me                
//          SP_S_YOU_SS with userInfo: me
//
// planets:
//
//          SP_V_PLANET with userInfo: planet
//          SP_PLANET_LOC with userInfo: planet
//
// ships:
//
//          SP_SHIP_CAP with userInfo: ship
//
// weapons:
//
//          SP_V_TORP with userInfo: torp   
//          SP_V_TORP_INFO with userInfo: torp
//          SP_TORP_INFO with userInfo: torp
//          SP_TORP with userInfo: torp         
//          SP_PLASMA_INFO with userInfo: plasma  
//          SP_PLASMA with userInfo: plasma
//          SP_V_PHASER with userInfo: phaser
//

#import <Cocoa/Cocoa.h>
@class Communication;
#import "Communication.h"
#import "Universe.h"
#import "LLNotificationCenter.h"
#import "ShortPacketWarningHandler.h"
#import "PacketTypes.h"
#import "MessageConstants.h"
#import "BaseClass.h"
#import "MTDistress.h"

#define  SPWINSIDE       500
#define  SHORT_WARNING    33
#define  STEXTE_STRING    34

// should be in seperate RSA file
#define  RSA_KEY_SIZE     32

@interface ServerReader : BaseClass {
 
    bool motd_done;
    ShortPacketWarningHandler *swarningHandler;  // a short packet warning handler, it will be created as needed
    Communication *communication; 
	NSTimeInterval timeOut;
} 

- (NSTimeInterval)timeOut;
- (void) setTimeOut:(NSTimeInterval)newTimeOut;
- (id)initWithUniverse:(Universe*)universe communication:(Communication*)comm;
- (NSData *) doRead;        // to be overwritten by TCP or UDP subclasses
- (void) close;             // to be overwritten by TCP or UDP subclasses
- (void) readFromServer;    // main routine
- (bool) handlePacket:(int)ptype withSize:(int)size inBuffer:(char *)buffer;

// plain C functions
int shortFromPacket(char *buffer, int offset);

// helper to cut of C strings
- (NSString*) stringFromBuffer:(char*)buffer startFrom:(int)start maxLength:(int)max;
 
@end
