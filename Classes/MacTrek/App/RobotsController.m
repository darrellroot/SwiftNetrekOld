//
//  RobotsController.m
//  MacTrek
//
//  Created by Aqua on 02/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "RobotsController.h"


@implementation RobotsController


- (id) init {
    self = [super init];
    if (self != nil) {
        robots = [[NSMutableArray alloc] init];
        restart = NO;
        //NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
		NSString *pathToResources = @"/usr/local/games";
        pathToRobot = [NSString stringWithFormat:@"%@/netrek-server-vanilla/lib/og/robot", pathToResources];
        fedNames = [NSArray arrayWithObjects:@"Kirk", @"McCoy", @"Jobs", @"Spock", @"Picard", @"Riker", 
            @"T'Poll", @"Kevin", nil];
        kliNames = [NSArray arrayWithObjects: @"Scott", @"Kahless", @"Worf", @"Gowron", @"Martok", @"K'mpec",
            @"Kor", @"Gates", nil];
        // need to retain?
        [fedNames retain];
        [kliNames retain];
        [pathToRobot retain];
    }
    return self;
}

- (id)initWithTextView:(NSTextView *) destination {
    self = [self init];
    logDestination = destination;
    return self;
}

- (void)startRobots:(int)numberOfRobots {
    
    if ([robots count] > 0) {
        // still running? stop the server with restart, this will
        // start the server again after it is properly stoped
        [self stopRobots];
        [self startRobots:numberOfRobots];
    } else {
        // clean start
        NSString *botName;
        NSString *team;
        for (int i = 0; i < numberOfRobots; i++) {
            if ((i % 2) == 0) {
                botName = [fedNames objectAtIndex:(i/2)];
                team = @"-Tf";
            } else {
                botName = [kliNames objectAtIndex:i/2];
                team = @"-To";
            }
            
            LLTaskWrapper *robotTask = [[LLTaskWrapper alloc] initWithController:self 
                                                                   arguments:[NSArray arrayWithObjects: pathToRobot, 
                                                                       team, @"-h",  @"localhost", @"-p", @"2592", @"-n"
                                                                       , botName, @"-b", @"-O", @"-I", nil] ];
            [robotTask startProcess];
            [robots addObject:robotTask];
        }
    }
}

- (void) stopRobots {
    for (int i = 0; i < [robots count]; i++) {
        LLTaskWrapper *robot = [robots objectAtIndex:i];
        [robots removeObjectAtIndex:i];
        if (robot != nil) {
            [robot stopProcess];
            [robot release]; 
        }       
    }
}

- (void)appendOutput:(NSString *)output fromTask:(id) task {
     
    if (logDestination != nil) {
        [logDestination setEditable:YES];
        [logDestination insertText: output];
        [logDestination setEditable:NO];
    } else {
        LLLog([NSString stringWithFormat: @"RobotsController.appendOutput %@", output]);
    }
    
}

- (void)processStarted:(id)task {
    LLLog(@"RobotsController.processStarted");
}

- (void)processFinished:(id)task {
    LLLog(@"RobotsController.processFinished:  done");
}

@end
