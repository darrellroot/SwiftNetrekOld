//
//  Communication.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "PacketTypes.h"
#import "Universe.h"
#import "UdpStats.h"
#import "LLNotificationCenter.h"
#import "PingStats.h"
#import "Luky.h"
#include <unistd.h>
#import "BaseClass.h"
#import "RSAWrapper.h"

#define COMM_UPDATES_PER_SECOND   10
#define MAX_PORT_RETRY  10
// set to yes to diagnose the udp 
#define COMM_UDP_DIAG        NO
#define COMM_MAX_PORT_RETRY  10 
// other number blocks, like UDP Version
#define COMM_SHORTVERSION    11
// S_P2
#define COMM_OLDSHORTVERSION 10		
// 10 milli second for LLNetwork vs 1 second for OmniNetwork
#define COMM_NETWORK_TIMEOUT 0.001

#define MAX_WAIT_BEFORE_CONTINUE 10

@interface Communication : BaseClass {
    int  commMode;         // COMM_TCP or COMM_UDP
    int  commStatus;
    int  commModeRequest;
    int  shortVersion;
    bool receiveShort;
    int  ghostSlot;
    FeatureList *fList;
    PingStats *pStats;
    UdpStats *udpStats;
	bool multiThreaded;
	RSAWrapper *rsaCoder;
	int udpReceiveMode;
	int udpSendMode;
	bool udpSequenceChecking;
}

// init
// privates
- (void)subscribeToNotifications;
- (void) run;
- (void) run:(id)sender;
// get and set some cool stuff
- (void) setMultiThreaded:(bool) multi;
-(void) setPing:(bool) received withResponse:(int)response;
-(FeatureList*) featureList;
-(PingStats*) pingStats;
-(UdpStats*)udpStats;
-(int)ghostSlot;
-(void)setGhostSlot:(int) slot;
-(int)commStatus;
-(void)setCommStatus:(int)status;
-(int)commMode;
-(void)setCommMode:(int)mode;
-(int)commModeRequest;
-(void)setCommModeRequest:(int)mode;
-(int)shortVersion;
-(void)setShortVersion:(int)ver;
-(bool)receiveShort;
-(void)setReceiveShort:(bool)rs;
-(int) packetsReceived;
-(void)increasePacketsReceived;
-(void)decreasePacketsReceived;
// control functions
- (void) sendShortPacketWithId:(char) type;
- (void) sendShortPacketNoForceWithId:(char) type state:(char) state;
- (void) sendShortPacketWithId:(char) type boolState:(bool) state;
- (void) sendShortPacketWithId:(char) type state:(char) state;
- (void) sendServerPacketWithBuffer:(char*)buffer length:(int) size;
// forcing routines
- (void) resetForce;
- (int) forceCheckFlags:(int) flag force:(int) force type:(char)type;
- (int) forceCheckValue:(int) value force:(int) force type:(char) type;
- (int) forceCheckTractFlag:(int) flag force:(int) force type:(char) type;
- (void) checkForce;
// these can be invoked by sending event messages
-(void)cleanUp:(id)sender;
-(bool)readFromServer;
-(void)readFromServer:(id)sender;
-(void)periodicReadFromServer; // only if the thread has been started..
// server messages
- (void) sendSpeedReq:(NSNumber *) speed;  // int
- (void) sendDockingReq:(NSNumber *) on;   // bool
- (void) sendCloakReq:(NSNumber *) on;     // bool
- (void) sendRefitReq:(NSNumber *) ship;   // char
- (void) sendDirReq:(NSNumber *) dir;	   // char
- (void) sendPhaserReq:(NSNumber *) dir;   // char
- (void) sendTorpReq:(NSNumber *) dir;     // char
- (void) sendPlasmaReq:(NSNumber *) dir;   // char
- (void) sendShieldReq:(NSNumber *) on;    // bool
- (void) sendBombReq:(NSNumber *) bomb;    // bool
- (void) sendBeamReq:(NSNumber *) up;      // bool
- (void) sendRepairReq:(NSNumber *) on;    // bool
- (void) sendOrbitReq:(NSNumber *) orbit;  // bool
- (void) sendQuitReq:(id)sender;
- (void) sendCoupReq:(id)sender;
- (void) sendByeReq:(id)sender;
- (void) sendPractrReq:(id)sender;
- (void) sendDetonateReq:(id)sender;
- (void) sendPlaylockReq:(NSNumber *) player;     // int
- (void) sendPlanlockReq:(NSNumber *) planet;     // int
- (void) sendResetStatsReq:(NSNumber *) verify;   // char
- (void) sendWarReq:(NSNumber *) mask;		  // char
- (void) sendTractorOnReq:(NSNumber *) player;    // char
- (void) sendTractorOffReq:(NSNumber *) player;   // char
- (void) sendRepressorOnReq:(NSNumber *) player;  // char
- (void) sendRepressorOffReq:(NSNumber *) player; // char
- (void) sendTeamReq:(NSDictionary *)newTeam;    
- (void) sendDetMineReq:(NSNumber *) torpId;      // int
- (void) sendFeature:(NSDictionary *)newFeature;
- (void) sendLoginReq:(NSDictionary *)login; 
- (void) sendPingReq:(NSNumber *)start;		  // bool
- (void) sendServerPingResponse:(NSNumber *) number; // char
- (void) sendMessage:(NSDictionary *)mess;
- (void) sendUpdatePacket:(NSNumber *) updates_per_second; // int
- (void) sendThreshold:(NSNumber*) threshold; // int
- (void) sendDetonateMyTorpsReq:(id)sender;
- (void) sendOptionsPacket:(id)sender;
- (int) sendPickSocketReq;
- (int) sendPickSocketReq:(NSNumber*) startAtPort; // int
- (void) sendUdpReq:(NSNumber*) req; //char
- (void) sendShortReq:(NSNumber*) req; //char
- (void) sendUdpVerify:(id)sender;
- (void) sendReservedReply:(NSData *)sreserved;
- (void) sendRSAResponse:(NSMutableData *)data;
// setup communication
- (bool) callServer:(NSString *) hostName port:(int) port;
- (bool) startCommunicationThread; // call after successfull call of server
- (bool) stopCommunicationThread;
// applet routines
- (bool) connectToServerUsingPort:(int) port;
- (bool) connectToServerUsingPort:(int) port expectedHost:(NSString *) host; 
- (bool) connectToServerUsingNextPort;
- (void) connectToServerUdpAtPort:(int) port;
- (int)  sendSocketVersionAndNumberReq:(int)port;
 // private routine, use sendUdpReq instead
- (bool) openUdpConn;
- (void) closeUdpConn;
// thread stuff
- (bool) isRunning;
- (bool) isSleeping;
- (bool) awakeCommunicationThread;
- (bool) suspendCommunicationThread;

@end
