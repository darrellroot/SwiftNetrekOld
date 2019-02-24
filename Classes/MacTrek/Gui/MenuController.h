//
//  MenuController.h
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "MetaServerParser.h"

@interface MenuController : BaseClass {
    IBOutlet NSButton    *settingsButton;
    IBOutlet NSButton    *selectServerButton;
    IBOutlet NSButton    *startServerButton;
    IBOutlet NSButton    *loginButton;
    IBOutlet NSButton    *playButton;
    IBOutlet NSButton    *quitButton;
	IBOutlet NSButton    *creditsButton;
	IBOutlet NSButton    *helpButton;
    IBOutlet NSButton    *quickConnectButton;
    IBOutlet NSTabView   *tabFrameView;  
}
// menu actions
- (IBAction)raiseSettings:(id)sender; 
- (IBAction)raiseSelectServer:(id)sender;
- (IBAction)raiseStartServer:(id)sender;
- (IBAction)raiseLogin:(id)sender;
- (IBAction)raiseOutfit:(id)sender;
- (IBAction)raiseGame:(id)sender;
- (IBAction)raiseCredits:(id)sender;
- (IBAction)quit:(id)sender;

- (IBAction)helpButtonPressed:(id)sender;
- (IBAction)quickButtonPressed:(id)sender;

// return to the menu
- (IBAction)raiseMenu:(id)sender; 
- (void) leaveSplashScreen;

// enable functions
- (void) setCanLogin:(bool)enable;
- (void) setCanPlay:(bool)enable;
- (void) disableLogin;
- (void) enableLogin;
- (bool) serverIsInstalled;



@end
