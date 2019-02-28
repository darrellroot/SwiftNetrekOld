//-------------------------------------------
// File:  PingStats.h
// Class: PingStats
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
 
#import <Cocoa/Cocoa.h>
#import "BaseClass.h"

@interface PingStats : BaseClass {

	int iloss_sc;	// inc % loss 0--100, server to client
	int iloss_cs;	// inc % loss 0--100, client to server
	int tloss_sc;	// total % loss 0--100, server to client
	int tloss_cs;	// total % loss 0--100, client to server
	int lag;		// delay in ms of last ping
	int av;		    // rt time
	int sd;		    // std deviation
} 

- (void) setIncrementalLossServerToClient: (int) rate_sc ClientToServer: (int) rate_cs;
- (void) setTotalLossServerToClient: (int) rate_sc ClientToServer: (int) rate_cs;
- (void) setLag: (int)newLag;
- (void) setRoundTripTime: (int)time;
- (void) setStandardDeviation: (int)deviation;

- (int)  incrementalLossFromServerToClient;  
- (int)  incrementalLossFromClientToServer;  
- (int)  totalLossFromServerToClient;  
- (int)  totalLossFromClientToServer;  
- (int)  lagOfLastPing;  
- (int)  roundTripTime;
- (int)  standardDeviation;  
- (void) calculateLag;
 
@end
