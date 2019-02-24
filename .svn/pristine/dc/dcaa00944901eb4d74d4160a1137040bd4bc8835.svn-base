//
//  LocalServerController.h
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "SelectServerController.h"
#import "ServerController.h"
#import "ServerControllerNew.h"
#import "RobotsController.h"

@interface LocalServerController : BaseClass {
    IBOutlet NSButton                  *loginButton;
    IBOutlet NSTextView                *serverLogView;
    IBOutlet NSTextField               *numberOfRobots;
    IBOutlet NSButton                  *startServerButton;
    IBOutlet NSButton                  *stopServerButton;
    IBOutlet NSButton                  *startRobotsButton;
    IBOutlet NSButton                  *stopRobotsButton;
    // the Back button is covered by the menu controller
    IBOutlet SelectServerController    *selectServerController;
    
    // pointer to the server manager
    ServerController *server;
    RobotsController *robots;
}


- (IBAction)startServer:(id)sender;
- (IBAction)stopServer:(id)sender;
- (IBAction)startRobots:(id)sender;
- (IBAction)stopRobots:(id)sender;

- (void) disableLogin;
- (void) enableLogin;

@end
