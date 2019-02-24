//
//  ServerReaderTcp.h
//  MacTrek
//
//  Created by Aqua on 06/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
@class ServerReader;
#import "ServerReader.h"

@class Communication;
#import "Communication.h"
#import "LLNetwork.h"

@interface ServerReaderTcp : ServerReader {
	
	LLSocketStream *stream;
	LLTCPSocket *sock;
}

- (id)initWithUniverse:(Universe*)newUniverse communication:(Communication*)comm
                socket:(LLTCPSocket*) socket;

@end
