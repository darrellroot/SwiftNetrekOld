//
//  UdpStats.m
//  MacTrek
//
//  Created by Aqua on 06/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "UdpStats.h"


@implementation UdpStats

int udp_dropped = 0;
int udp_recent_dropped = 0;
int udp_total = 0;
int recent_count = 0;
int recent_dropped = 0;
int sequence = 0;
int packets_sent = 0;
int packets_received = 0;

- (id) init {
    self = [super init];
    if (self != nil) {
        udp_dropped = 0;
        udp_recent_dropped = 0;
        udp_total = 0;
        recent_count = 0;
        recent_dropped = 0;
        sequence = 0;
        packets_sent = 0;
        packets_received = 0;
    }
    return self;
}

-(void) increasePacketsSendBy:(int) newValue {
    packets_sent += newValue;
}

-(void) increaseUdpDroppedBy:(int) newValue {
    udp_dropped += newValue;
}

-(void) increaseUdpRecentDroppedBy:(int) newValue {
    udp_recent_dropped += newValue;
}

-(void) increaseUdpTotalBy:(int) newValue {
    udp_total += newValue;
}

-(void) increaseRecentCountBy:(int) newValue {
    recent_count += newValue;
}

-(void) increaseRecentDroppedBy:(int) newValue {
    recent_dropped += newValue;
}

-(void) increaseSequenceBy:(int) newValue {
    sequence += newValue;
}

-(void) setUdpDropped:(int) newValue {
    udp_dropped = newValue;
}

-(void) setUdpRecentDropped:(int) newValue {
    udp_recent_dropped = newValue;
}

-(void) setUdpTotal:(int) newValue {
    udp_total = newValue;
}

-(void) setRecentCount:(int) newValue {
    recent_count = newValue;
}

-(void) setRecentDropped:(int) newValue {
    recent_dropped = newValue;
}

-(void) setSequence:(int) newValue {
    sequence = newValue;
}

-(void) setPacketsSent:(int) newValue {
    packets_sent = newValue;
}

-(void) setPacketsReceived:(int) newValue {
    packets_received = newValue;
}

-(int) udpDropped {
    return udp_dropped;
}

-(int) udpRecentDropped{
    return udp_dropped;
}

-(int) udpTotal{
    return udp_total;
}

-(int) recentCount{
    return recent_count;
}

-(int) recentDropped{
    return recent_dropped;
}

-(int) sequence{
    return sequence;
}

-(int) packetsSent{
    return packets_sent;
}

-(int) packetsReceived{
    return packets_received;
}

@end
