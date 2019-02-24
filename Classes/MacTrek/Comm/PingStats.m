//-------------------------------------------
// File:  PingStats.m
// Class: PingStats
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------
 
#import "PingStats.h"
#include <math.h>
 
@implementation PingStats

- (id) init {
    self = [super init];
    if (self != nil) {        
        iloss_sc = 0;	// inc % loss 0--100, server to client
        iloss_cs = 0;	// inc % loss 0--100, client to server
        tloss_sc = 0;	// total % loss 0--100, server to client
        tloss_cs = 0;	// total % loss 0--100, client to server
        lag = 0;		// delay in ms of last ping
        av = 0;         // rt time
        sd = 0;         // std deviation
    }
    return self;
}

- (void) setIncrementalLossServerToClient: (int) rate_sc ClientToServer: (int) rate_cs {
	iloss_sc = rate_sc;
	iloss_cs = rate_cs;
}

- (void) setTotalLossServerToClient: (int) rate_sc ClientToServer: (int) rate_cs {
	tloss_sc = rate_sc;
	tloss_cs = rate_cs;
}

- (void) setLag: (int)newLag {
	lag = newLag;
}

- (void) setRoundTripTime: (int)time {
	av = time;
}

- (void) setStandardDeviation: (int)deviation {
	sd = deviation;
}

- (int)  incrementalLossFromServerToClient {
	return iloss_sc;
}
  
- (int)  incrementalLossFromClientToServer {
	return iloss_cs;
}
  
- (int)  totalLossFromServerToClient {
	return tloss_sc;
}
  
- (int)  totalLossFromClientToServer {
	return tloss_cs;
}
  
- (int)  lagOfLastPing {
	return lag;
}
  
- (int)  roundTripTime {
	return av;
}
  
- (int)  standardDeviation {
	return av;
}
  
- (void) calculateLag {
    
	double s2;
	int sum;
	int n;
    
	if (lag > 2000) {
		// probably ghostbusted
		return;
	}
	
	sum += lag;
	s2 += (lag * lag);
	
	if (++n != 1) {
		av = sum / n;
		sd = sqrt((double)((s2 - av * sum) / (n - 1)));
	}
}

@end
