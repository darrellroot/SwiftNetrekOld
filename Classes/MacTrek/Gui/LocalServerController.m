//
//  LocalServerController.m
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "LocalServerController.h"


@implementation LocalServerController

// privates
bool serverRuns = NO;

- (id) init {
    self = [super init];
    if (self != nil) {

    }
    return self;
}


- (void) enableLogin {
    [loginButton setEnabled:YES];
}

- (void) disableLogin {
    [loginButton setEnabled:NO];
}

- (void) awakeFromNib {
    LLLog(@"LocalServerController awakeFromNib");

    // setup the server controller and tie it to the log window
    server = [[ServerController alloc] initWithTextView: serverLogView];
    // setup the robots, no need to log their output (i think)
    robots = [[RobotsController alloc] initWithTextView:serverLogView];   
}


- (IBAction)startServer:(id)sender {
	
    [server startServer];
    serverRuns = YES;
    
#if 0 // Bug 2846441
    
    // add localhost if it is not already there
    if ([selectServerController findServer:@"localhost"] == nil) {
        MetaServerEntry *entry = [[MetaServerEntry alloc] init];
        [entry setAddress: @"localhost"];
        [entry setPort:    2592];
        [entry setStatus:  DEFAULT];
        [entry setGameType:    BRONCO];	
        [selectServerController addServer:entry];  // gets selected automatically  
    }
#endif
    
    // wait until we have connected
    //[loginButton setEnabled:YES];
}

- (IBAction)stopServer:(id)sender
{
    [server stopServer];
    serverRuns = NO;
    
    // remove localhost if there
    [selectServerController removeServer:@"localhost"]; // deselect automatically
    
    [loginButton setEnabled:NO];
}

- (IBAction)startRobots:(id)sender
{
    if (!serverRuns) {
        [self startServer:self];
    }
    [robots startRobots:[numberOfRobots intValue]];
}

- (IBAction)stopRobots:(id)sender
{
    [robots stopRobots];
}


@end
