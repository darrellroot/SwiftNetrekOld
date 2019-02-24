//
//  ServerSenderTcp.h
//  MacTrek
//
//  Created by Aqua on 13/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "LLNetwork.h"
#import "ServerSender.h"


@interface ServerSenderTcp : ServerSender {
    LLTCPSocket *socket;
}

- (id) initWithSocket:(LLTCPSocket*) socket;
- (int) serverPort;
- (LLHost*) serverHost;

@end
