//
//  ServerSender.m
//  MacTrek
//
//  Created by Aqua on 13/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "ServerSender.h"


@implementation ServerSender

- (id) init {
    self = [super init];
    if (self != nil) {
        pktConv = [[PacketTypesDebug alloc] init];
    }
    return self;
}


- (id) initWithSocket:(LLSocket*) newSocket {   
    self = [super init];
    if (self != nil) {
        LLLog(@"ServerSender.initWithSocket should have been subclassed!");
    }
    return self;
}

- (bool) sendBuffer:(char*) buffer length:(int)size {
    LLLog(@"ServerSender.sendBuffer should have been subclassed!");
    return NO;
}

- (void) close {
    LLLog(@"ServerSender.close should have been subclassed!");
}

@end
