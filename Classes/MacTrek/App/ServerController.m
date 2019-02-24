//
//  ServerController.m
//  MacTrek
//
//  Created by Aqua on 21/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "ServerController.h"


@implementation ServerController


- (id) init {
    self = [super init];
    if (self != nil) {
        serverTask = nil;
        logTask = nil;
        logDestination = nil;
        restartServer = NO;
        restartLog = NO;
        serverPid = -1;
		// kill old servers
		//[self stopServer];
    }
    return self;
}

- (id)initWithTextView:(NSTextView *) destination {
    self = [self init];
    logDestination = destination;
    return self;
}

- (void)startServer {
    
    //NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
	NSString *pathToResources = @"/usr/local/games";
    NSString *pathToServer = [NSString stringWithFormat:@"%@/netrek-server-vanilla/bin/netrekd", pathToResources];
    NSString *pathToLog = [NSString stringWithFormat:@"%@/netrek-server-vanilla/var/log", pathToResources];
    
    if (serverTask != nil) {
        // still running? stop the server with restart, this will
        // start the server again after it is properly stoped
        [serverTask stopProcess];
        restartServer = YES;        
    } else {
         // clean start
        serverTask = [[LLTaskWrapper alloc] initWithController:self 
                                                   arguments:[NSArray arrayWithObjects:pathToServer, nil] ];
        [serverTask startProcess];
    }
    
    if (logTask != nil) {
        [logTask stopProcess];
        restartLog = YES;        
    } else {
        logTask = [[LLTaskWrapper alloc] initWithController:self 
                                                arguments:[NSArray arrayWithObjects:@"/usr/bin/tail",
                                                    @"-f", pathToLog, nil] ];
        [logTask startProcess];         
    }

}

- (void) stopServer {
    if (serverTask != nil) {
        [serverTask stopProcess];
    }
    if (logTask != nil) {
        [logTask stopProcess];
    }
    if (serverPid > 0) {
        // won't run very long so no clean up needed?
		
		/*
		 NSString *killCommand = @"/bin/kill";
		 
		 LLTaskWrapper *killTask = [[[LLTaskWrapper alloc] initWithController:self 
																arguments:[NSArray arrayWithObjects:killCommand, 
																	[NSString stringWithFormat: @"%d", serverPid], nil] ] autorelease];
		 */ 
		
		// patch through shell script, to kill also robots and other stuff
		// quite harsh actually
		/*
		NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
		NSString *killCommand = [NSString stringWithFormat:@"%@/kill.sh", pathToResources];
		
		LLTaskWrapper *killTask = [[[LLTaskWrapper alloc] initWithController:self 
									arguments:[NSArray arrayWithObjects:@"/bin/sh", killCommand, nil] ] autorelease];	
		 
		 [killTask startProcess];
		 
		 */
		
		// attempt 3, very simple
		system("killall -9 robot");
		system("killall netrekd");		
        
        LLLog(@"ServerController.stopServer kill PID %d", serverPid);
        serverPid = -1;
    }
}

- (void)appendOutput:(NSString *)output fromTask:(id) task {
    
    // scan the text for "started, pid xxxx,"
    NSRange myRange = [output rangeOfString:@"started, pid "];
    if (myRange.location != NSNotFound) {
        // take the rest of the string minus the comma
        myRange.location += myRange.length;
        myRange.length = [output length] - myRange.location - 1;
        serverPid = [[output substringWithRange:myRange] intValue];
    }
    
    // check also for "already running as pid 4623"
    myRange = [output rangeOfString:@"already running as pid "];
    if (myRange.location != NSNotFound) {
        // take the rest of the string minus the comma
        myRange.location += myRange.length;
        myRange.length = [output length] - myRange.location - 1;
        serverPid = [[output substringWithRange:myRange] intValue];
    }
    
    if (logDestination != nil) {
        [logDestination setEditable:YES];
        [logDestination insertText: output];
        [logDestination setEditable:NO];
    } else {
        LLLog([NSString stringWithFormat: @"ServerController.appendOutput %@", output]);
    }

}

- (void)processStarted:(id)task {
    if (task == serverTask) {
        LLLog(@"ServerController.processStarted: serverTask");
    } else if (task == logTask) {
        LLLog(@"ServerController.processStarted: logTask");
    } else {
        LLLog(@"ServerController.processStarted: unknown task");
    }
}


- (void)processFinished:(id)task {
    if (task == serverTask) {
        //[serverTask release];
        serverTask = nil;
        LLLog(@"ServerController.processFinished: serverTask done");
        // is this stop part of a restart?
        if (restartServer) {
            serverTask = [[LLTaskWrapper alloc] initWithController:self 
                                                       arguments:[NSArray arrayWithObjects:@"/usr/local/games/netrek-server-vanilla/bin/netrekd", nil] ];
            [serverTask startProcess];
            restartServer = NO;
        }    
            
    } else if (task == logTask) {
        //[logTask release];
        logTask = nil;
        LLLog(@"ServerController.processFinished: logTask done");
        if (restartLog) {
            logTask = [[LLTaskWrapper alloc] initWithController:self 
                                                    arguments:[NSArray arrayWithObjects:@"/usr/bin/tail",
                                                        @"-f", @"/usr/local/games/netrek-server-vanilla/var/log", nil] ];
            [logTask startProcess];  
            restartLog = NO;
        }    
    } else {
        LLLog(@"ServerController.processFinished: unknown task done");
    }
}

@end
