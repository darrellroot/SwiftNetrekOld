//
//  ServerReaderUdp.h
//  MacTrek
//
//  Created by Aqua on 06/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "LLNetwork.h"
@class ServerReader;
#import "ServerReader.h"
@class Communication;
#import "Communication.h"
#import "UdpStats.h"

#define SRV_UDP_MAX_DATA_LENGTH  1300


@interface ServerReaderUdp : ServerReader {
    UdpStats *udpStats;
	LLUDPSocket *udpSocket;
	bool sequenceCheck;
}

- (id)initWithUniverse:(Universe*)newUniverse communication:(Communication*)comm socket:(LLUDPSocket *)socket udpStats:(UdpStats*)stats;
- (UdpStats*)udpStats;
- (void) setSequenceCheck:(bool)newValue;
- (LLUDPSocket *)udpSocket;

@end
