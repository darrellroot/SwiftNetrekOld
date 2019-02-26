//
//  MenuController.m
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MenuController.h"


@implementation MenuController

// startup
- (id) init {
    self = [super init];
    if (self != nil) {

    }

    return self;
}

- (bool) serverIsInstalled {
	NSString *pathToResources = @"/usr/local/games";
    NSString *pathToServer = [NSString stringWithFormat:@"%@/netrek-server-vanilla/bin/netrekd", pathToResources];
	
	NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:pathToServer];
}

- (void) awakeFromNib {
    
    // important: the view has a tab start which will not resize properly
    //            as this only happen at the first frame, we created
    //            a dummy. Raise Splash window now, and it will be
    //            resized properly!
    
    [tabFrameView selectTabViewItemWithIdentifier:@"Splash"];
    // show menu after some time (2 sec)
    //[self performSelector: @selector(raiseMenu:) withObject: self afterDelay: 2];
	
	// check if the server is installed
	if ([self serverIsInstalled]) {
		[startServerButton setEnabled:YES];
	} else {
		[startServerButton setEnabled:NO];
	}	
}

// internal routines
- (void) enableLogin {
    [loginButton setEnabled:YES];
}

- (void) disableLogin {
    [loginButton setEnabled:NO];
}

- (void) setServerSelected:(MetaServerEntry *) server {
    
    if (server != nil) {        
        // enabling happens not on selection but on obtaining a slot
        // [loginButton setEnabled:YES];
         
    } else {
        // no server, thus cannot login
        [loginButton setEnabled:NO];
    }  
}

// menu actions
- (IBAction)raiseSettings:(id)sender {
    [tabFrameView selectTabViewItemWithIdentifier:@"Settings"];   
}

- (IBAction)raiseSelectServer:(id)sender{
    [tabFrameView selectTabViewItemWithIdentifier:@"Select"];   
}

- (IBAction)raiseStartServer:(id)sender{
    [tabFrameView selectTabViewItemWithIdentifier:@"Run"];   
}

- (IBAction)raiseLogin:(id)sender{
    [tabFrameView selectTabViewItemWithIdentifier:@"Login"];   
}

- (IBAction)raiseOutfit:(id)sender {
    [tabFrameView selectTabViewItemWithIdentifier:@"Outfit"];   
}

- (IBAction)raiseGame:(id)sender {
    [tabFrameView selectTabViewItemWithIdentifier:@"Game"];   
}

- (IBAction)raiseCredits:(id)sender {
	[tabFrameView selectTabViewItemWithIdentifier:@"Credits"];   
}

- (IBAction)quit:(id)sender {
    LLLog(@"MenuController.quit");
    [tabFrameView selectTabViewItemWithIdentifier:@"Splash"];
    // stop the whole app
	[notificationCenter postNotificationName:@"MC_MACTREK_SHUTDOWN"];
    [[NSApplication sharedApplication] stop:self];    
}

// return to the menu
- (IBAction)raiseMenu:(id)sender {
    
    if ([[[tabFrameView selectedTabViewItem] identifier] isEqualToString:@"Settings"]) {
        // leaving settings pane.. lets set the values
        [notificationCenter postNotificationName:@"MC_LEAVING_SETTINGS"];
    }
    
    // stop any previous timers to raise us
    // argument will be nil, since i have no link to the guimanager
    //[[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(raiseMenu:) target:self argument:nil];
    //[[NSRunLoop currentRunLoop] cancelPerformSelectorsWithTarget:self];
    [tabFrameView selectTabViewItemWithIdentifier:@"Menu"];   
}

- (void) leaveSplashScreen {
    if ([[[tabFrameView selectedTabViewItem] identifier] isEqualToString:@"Splash"]) {
        [self raiseMenu:self];
    }
}

- (void) setCanLogin:(bool)enable {
    [loginButton setEnabled:enable];
}

- (void) setCanPlay:(bool)enable {
    [playButton setEnabled:enable];
}

- (IBAction)helpButtonPressed:(id)sender {
	
	NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
	NSString *pathToPdf = [NSString stringWithFormat:@"%@/MacTrekUserManual.pdf", pathToResources];
	//TODO this freezes game
	[[NSWorkspace sharedWorkspace] openFile:pathToPdf
							withApplication:@"Preview"];
}

- (IBAction)quickButtonPressed:(id)sender {
	[notificationCenter postNotificationName:@"MC_QUICK_CONNECT_STAGE_1"];
}


@end
