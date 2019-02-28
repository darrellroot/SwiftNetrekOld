//
//  ServerSenderUdp.h
//  MacTrek
//
//  Created by Aqua on 13/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "LLNetwork.h"
#import "ServerSender.h"


@interface ServerSenderUdp : ServerSender {
    LLUDPSocket *socket;
}

- (id) initWithSocket:(LLUDPSocket*) socket;
- (void) close;

@end
