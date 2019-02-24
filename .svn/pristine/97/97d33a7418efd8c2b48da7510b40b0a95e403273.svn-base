//
//  ServerController.h
//  MacTrek
//
//  Created by Aqua on 21/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "LLTaskWrapper.h"
#import "BaseClass.h"

@interface ServerController : BaseClass <LLTaskWrapperController> {

    LLTaskWrapper *serverTask;
    LLTaskWrapper *logTask;
    bool restartServer;
    bool restartLog;
    NSTextView *logDestination;
    int serverPid;
}

- (id)initWithTextView:(NSTextView *) logDestination;
- (void)startServer;
- (void)stopServer;

@end
