//
//  JTrekController.m
//  MacTrek
//
//  Created by Aqua on 02/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "JTrekController.h"


@implementation JTrekController


- (id) init {
    self = [super init];
    if (self != nil) {
        jtrek = nil;
    }
    return self;
}

- (id)initWithTextView:(NSTextView *) destination {
    self = [self init];
    logDestination = destination;
    return self;
}

// overwrite master
- (void)startClientAt:(NSString *)server port:(int)port {

	// demo
	[self startJTrekAt:server port:port];

}

- (void)startJTrekAt:(NSString *)server port:(int)port {
    
    if (jtrek != nil) {
        // still running? stop the server with restart, this will
        // start the server again after it is properly stoped
        [self stopJTrek];
        [self startJTrekAt:server port:port];
    } else {
        // clean start
        NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
        NSString *pathToJTrek = [NSString stringWithFormat:@"%@/jtrek.jar", pathToResources];
        jtrek = [[LLTaskWrapper alloc] initWithController:self 
                                              arguments:[NSArray arrayWithObjects: @"/usr/bin/java", @"-classpath",
                                                  pathToJTrek, @"jtrek/Main", @"-h", server, @"-p",
                                                  [NSString stringWithFormat:@"%d", port], nil]]; 
        [jtrek startProcess];
    }
}

- (void) stopJTrek {
    if (jtrek != nil) {
        [jtrek stopProcess];
        [jtrek release];
        jtrek = nil;
    }
}

- (void)appendOutput:(NSString *)output fromTask:(id) task {
     
    if (logDestination != nil) {
        [logDestination setEditable:YES];
        [logDestination insertText: output];
        [logDestination setEditable:NO];
    } else {
        LLLog([NSString stringWithFormat: @"JTrekController.appendOutput %@", output]);
    }
    
}

- (void)processStarted:(id)task {
    LLLog(@"JTrekController.processStarted");
}

- (void)processFinished:(id)task {
    LLLog(@"JTrekController.processFinished:  done");
}

@end
