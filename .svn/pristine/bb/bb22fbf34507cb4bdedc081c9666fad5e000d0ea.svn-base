//
//  LoginController.h
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "LoginManager.h"
#import "SelectServerController.h"

@interface LoginController : BaseClass {
	IBOutlet NSTextField *playerName;    
	IBOutlet NSTextField *playerPassword;    
	IBOutlet NSTextField *playerPasswordVerify; 
	IBOutlet NSTextField *loginInstruction;
    IBOutlet NSLevelIndicator *loginClock;
    IBOutlet NSButton *outfitButton;
    
    // our helper to talk to the server
    LoginManager *loginManager;
	bool multiThreaded;
}

- (void) reset;
- (void) enablePlayerName;
- (void) disablePlayerName;
// handling of input events
- (void)loginDidEndEditing:(NSNotification *)aNotification;
- (void) setMultiThreaded:(bool)multi;
- (void) startClock;
- (void) stopClock;

@end
