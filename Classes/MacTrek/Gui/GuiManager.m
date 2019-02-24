//
//  GuiManager.m
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "GuiManager.h"
//
// The GuiManger maintains (among others) the game state machine, or to be precise the state machine that handles
// the changes between the menus. It uses the following table to jump between states and specifies which events
// trigger a state change
//                     State          1          2          3          4          5          7          8
// Event                              no       server     server     slot       login      outfit     game
//                                  server    selected   contacted   found     accepted   accepted   entered
//                                 selected          
// MS_SERVER_SELECT                   2          2          2          2          2                    
// LOGIN button pressed                                                5          5                    
// CC_SERVER_CALL_SUCCESS                        3                                                  
// CC_SERVER_CALL_FAILED                         1                                                  
// CC_SLOT_FOUND                                            4                                        
// LM_LOGIN_INVALID_SERVER                                             1                              
// LM_LOGIN_COMPLETE                                                              7                              
// OM_ENTER_GAME                                                                             8          
// CC_GO_OUTFIT                                                                                        7
// CC_GO_LOGIN                                                                                         5
//
// AddOn: there actually is a state 0 (begin state) that shows the splashScreen. The Splash Screen waits for
//        a number of events before it raises the menu pane and allows the game to start 
//

@implementation GuiManager

bool clientRuns = NO;
bool firstGame = YES;
int startUpEvents = 0;
bool quickConnect = NO;
NSString *defaultName;
NSString *defaultPassword;

- (id) init {
    self = [super init];
    if (self != nil) {
		
		defaultName = @"guest";
		defaultPassword = @"";
		
		// ROOT PLACE to turn MULTITHREADING off, only tested for guest login
		// turn only off for testing!
		multiThreaded = YES; 
		mutex = [[NSLock alloc] init];
		
        // setup our client
        //client = [[ClientController alloc] initWithUniverse:universe];
		client = [[ClientController alloc] init];
        currentServer = nil;
		
        // load the themes
        soundPlayerTheme1 = [[SoundPlayerForNetrek alloc] init];
        painterTheme1     = [[PainterFactoryForNetrek alloc] init];
        soundPlayerTheme2 = [[SoundPlayerForMacTrek alloc] init];
        painterTheme2     = [[PainterFactoryForMacTrek alloc] init];
        soundPlayerTheme3 = [[SoundPlayerForTac alloc] init];
        painterTheme3     = [[PainterFactoryForTac alloc] init];
        // pick a default
        soundPlayerActiveTheme = soundPlayerTheme2;
        painterActiveTheme = painterTheme2;
        activeTheme = -1;
		tipCntrl = [[MTTipOfTheDayController alloc] init];
        
        // reset gameState
        gameState = GS_NO_SERVER_SELECTED;
        
        // tag events
        [notificationCenter addObserver:self selector:@selector(serverSelected:) 
                                   name:@"MS_SERVER_SELECTED" object:nil];
        [notificationCenter addObserver:self selector:@selector(serverSlotFound) 
                                   name:@"CC_SLOT_FOUND" object:nil];
        [notificationCenter addObserver:self selector:@selector(serverDeSelected) 
                                   name:@"LC_INVALID_SERVER" object:nil];
        [notificationCenter addObserver:self selector:@selector(loginComplete) 
                                   name:@"LC_LOGIN_COMPLETE" object:nil];
        [notificationCenter addObserver:self selector:@selector(outfitAccepted) 
                                   name:@"SP_PICKOK" object:nil];
        [notificationCenter addObserver:self selector:@selector(loginComplete) 
                                   name:@"SP_PICKNOK" object:nil];
		[notificationCenter addObserver:self selector:@selector(serverDeSelected) 
                                   name:@"SP_QUEUE" object:nil];
        // when killed
        [notificationCenter addObserver:self selector:@selector(iDied) 
                                   name:@"CC_GO_OUTFIT" object:nil];
		// or suicide
		//[notificationCenter addObserver:self selector:@selector(iDied) 
        //                           name:@"COMM_SEND_QUIT_REQ" object:nil];
		
        [notificationCenter addObserver:self selector:@selector(commError) 
                                   name:@"COMM_TCP_WRITE_ERROR" object:nil];
        // needed to keep polling for changed masks.. (at a very low rate)
        //[notificationCenter addObserver:self selector:@selector(handleTeamMask:) 
         //                          name:@"SP_MASK" object:nil];
        
        // startup events
        //[notificationCenter addObserver:self selector:@selector(increaseStartUpCounter) 
        //                           name:@"MS_SERVERS_READ"]; $$ sent, before i am observer..
        [notificationCenter addObserver:self selector:@selector(increaseStartUpCounter) 
                                   name:@"PF_IMAGES_CACHED"]; 
        [notificationCenter addObserver:self selector:@selector(increaseStartUpCounter) 
                                   name:@"SP_SOUNDS_CACHED"]; 
		
		// new painter selected?
		[notificationCenter addObserver:self selector:@selector(settingsChanged:) name:@"SC_NEW_SETTINGS"];
		
		// help pressed
		[notificationCenter addObserver:self selector:@selector(showKeyMapPanel) 
                                   name:@"GV_SHOW_HELP" object:nil];
		
		// message sent, move focus to gameview
		[notificationCenter addObserver:self selector:@selector(focusToGameView) 
                                   name:@"COMM_SEND_MESSAGE" object:nil];
		
		// quick connect
		[notificationCenter addObserver:self selector:@selector(quickConnect:) 
                                   name:@"SC_QUICK_CONNECT_STAGE_2" object:nil];

				
		// shutdown
		[notificationCenter addObserver:self selector:@selector(shutdown) name:@"MC_MACTREK_SHUTDOWN"];
    }
    return self;
}



- (void) settingsChanged:(SettingsController*) settingsController  {
	[self setTheme];
}

- (void) quickConnect:(MetaServerEntry*) entry {
	
	LLLog(@"GuiManager.quickConnect: setting server %@, user %@", [entry address], [properties objectForKey:@"USERNAME"]);
	[self serverSelected:entry]; // select the server
	quickConnect = YES;
}

- (void) quickConnectAutoLogin {
	
	/*
	if ([properties objectForKey:@"USERNAME"] != nil) {
		[defaultName release];
		defaultName = [properties objectForKey:@"USERNAME"];
		[defaultName retain];
	} 
	
	if ([properties objectForKey:@"PASSWORD"] != nil) {
		[defaultPassword release];
		defaultPassword = [properties objectForKey:@"PASSWORD"];
		[defaultPassword retain];
	}
	*/
	LLLog(@"GuiManager.quickConnectAutoLogin: logging in with %@", defaultName);
	[notificationCenter postNotificationName:@"GM_SEND_LOGIN_REQ" 
                                      object:nil 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys: 
                                        defaultName, @"name",
                                        defaultPassword, @"pass", 
                                        NSUserName(), @"login", 
                                        [NSNumber numberWithInt:0], @"query",
                                        nil]];
}

- (void) quickConnectPickTeamShip {
	LLLog(@"GuiManager.quickConnectPickTeamShip: picking ship and team");

	// blow through outfit menu
	[outfitCntrl setQuickConnect:YES];
	[outfitCntrl findTeam];
	
	// reset it some damage
	[loginCntrl reset];
}

- (void) quickConnectComplete {
	quickConnect = NO;
	[outfitCntrl setQuickConnect:NO];
}

- (void) focusToGameView {
	[[gameCntrl gameView] makeFirstResponder];
}

- (void) shutdown {
	// kill all robots
	// leave some old code intact	
	//[localServerCntrl stopServer:self];
	
	// but stop the new server too
	// should kill the robots as well
	[server stopServer];
	[service stop];
}

// to be called..
- (void) playIntroSoundEffect {
    [soundPlayerActiveTheme playSoundEffect:@"INTRO_SOUND"];  
}

// Application delegate function
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	LLLog(@"GuiManager.applicationShouldTerminate: shutting down");
	[self shutdown];
	return NSTerminateNow;
}

- (NSString*)gameStateAsString {
	switch (gameState) {
	
		case GS_NO_SERVER_SELECTED:
			return @"GS_NO_SERVER_SELECTED";
			break;
		case GS_SERVER_SELECTED:
			return @"GS_SERVER_SELECTED";
			break;
		case GS_SERVER_CONNECTED:
			return @"GS_SERVER_CONNECTED";
			break;
		case GS_SERVER_SLOT_FOUND:
			return @"GS_SERVER_SLOT_FOUND";
			break;
		case GS_LOGIN_ACCEPTED:
			return @"GS_LOGIN_ACCEPTED";
			break;
		case GS_OUTFIT_ACCEPTED:
			return @"GS_OUTFIT_ACCEPTED";
			break;
		case GS_GAME_ACTIVE:
			return @"GS_GAME_ACTIVE";
			break;
		case GS_MAX_STATE:
			return @"GS_MAX_STATE";
			break;
	}
	return @"GS_ERROR";
}

- (void) increaseStartUpCounter {
    
    startUpEvents++;
    [startUpProgress setIntValue:startUpEvents];
    [startUpProgress setNeedsDisplay:YES];
    LLLog(@"GuiManager.increaseStartUpCounter got event %d of %d", startUpEvents, NR_OF_EVENTS_BEFORE_SHOWING_MENU);
    
    if (startUpEvents == NR_OF_EVENTS_BEFORE_SHOWING_MENU) {
        
        //[startUpProgress setHidden:YES];
        //[startUpProgress setNeedsDisplay:YES];
        [self playIntroSoundEffect];
        
        //[menuCntrl raiseMenu:self]; // $$ should be on mouseclick
        [menuButton setHidden:NO]; // enable going to the memu
        [menuButton setEnabled:YES];
        [menuButton setNeedsDisplay:YES];
        // or go automaticaly after 1 seconds (use obj nil since menu does not know us
        [menuCntrl  performSelector:@selector(leaveSplashScreen) withObject:nil afterDelay: 1];
				
		if ([tipCntrl newVersionAvailable]) {
			// show as tip even when disabled tips 
			[tipCntrl performSelector:@selector(showNewVersionIndicationIfAvailable) withObject:nil afterDelay: 1];
		} else {			
			// if we need to, show a tip
			if ([settingsCntrl tipsEnabled]) {
				// show a tip
				[tipCntrl performSelector:@selector(showTip) withObject:nil afterDelay: 1];			
			}
		}
        
    } else if (startUpEvents > NR_OF_EVENTS_BEFORE_SHOWING_MENU) {
        
        LLLog(@"GuiManager.increaseStartUpCounter did not expect this event... %d", startUpEvents);
        [menuCntrl raiseMenu:self]; // $$ try..
    }    
}

- (IBAction)showNextTip:(id)sender {
	[tipCntrl showTip];
}

- (void) awakeFromNib { 
	// initate painters
	[painterTheme1 awakeFromNib];
	[painterTheme2 awakeFromNib];
	[painterTheme3 awakeFromNib];
	
    // set the startup bar value
    [startUpProgress setMaxValue:NR_OF_EVENTS_BEFORE_SHOWING_MENU];
    
    // set up a timer to redraw at FRAME_RATE 
    // since some data is updated outside the main loop and in the receive 
    // thread (default is still with timer (so not sync))
	// will probably not work since there is a blocking wait
	// in the main draw loop when not multithreading
	[self setSyncScreenUpdateWithRead:NO];
	
    // does the controller wait, or asks for reads herself...
    [loginCntrl setMultiThreaded:multiThreaded];
	
	// set the version string
	[versionString setStringValue:[NSString stringWithFormat:@"Version %@", VERSION]];
	LLLog(@"GuiManager.awakeFromNib Setting version to %@", VERSION);
	
    
#if 0  // Bug 2846441
    
	// new server controller. No longer managed with buttons but allways running!
	server = [[ServerControllerNew alloc] init];
	[server restartServer];		// stop only on shutdown... (but restart in case we were badly shutdowned)
								// add localhost if it is not already there
	if ([selectServerCntrl findServer:@"localhost"] == nil) {
		MetaServerEntry *entry = [[MetaServerEntry alloc] init];
		[entry setAddress: @"localhost"];
		[entry setPort:    2592];
		[entry setStatus:  DEFAULT];
		[entry setGameType:    BRONCO];	
		[selectServerCntrl addServerPassivly:entry];  // gets selected automatically  
	}
    
#endif	
    
	// register for quit
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(killed:) 
												 name:NSMenuDidChangeItemNotification //NSWindowWillCloseNotification
											   object:nil]; 

	// setup the online help panel
	[self setUpKeyMapPanel];
}

- (void) killed:(NSNotification *)notification {
	
	NSMenu *source = [notification object];
	NSMenuItem *item = [source itemAtIndex:[[[notification userInfo] valueForKey:@"NSMenuItemIndex"] intValue]];
	
	//LLLog(@"GuiManager.killed: %@, menu [%@]", [notification name], [item title]);	
	if (![[item title] isEqualToString:@"Quit"]){
		return; // wrong menu changed
	}
	
	// get's called a zilliion times
	static bool beeingKilled = NO;
	
	if  (!beeingKilled) {
		beeingKilled = YES;
		[menuCntrl quit:self];
	} else {
		//LLLog(@"GuiManager.killed: ignoring double kill");
	}
}


- (void) testLog:(NSNotification *)notification {
	LLLog(@"GuiManager.testLog: %@", [notification name]);	
}

// added synchronized access with the reader, disables the timer
// and relies on SERVER_READER_READ_SYNC to be repainted
- (void)setSyncScreenUpdateWithRead:(bool)enable {
	
	// stop active timer
	[timer invalidate];
	if (timer != nil) {
		[timer release];
	}
	
	// use sync or timer
	if (enable) {
		[notificationCenter addObserver:self selector:@selector(screenRefreshTimerFired:) name:@"SERVER_READER_READ_SYNC"
								 object:nil useLocks:NO useMainRunLoop:NO]; 
		[notificationCenter addObserver:self selector:@selector(screenRefreshTimerFired:) name:@"GM_GAME_ENTERED"
								 object:nil useLocks:NO useMainRunLoop:NO]; 
		[notificationCenter addObserver:self selector:@selector(screenRefreshTimerFired:) name:@"COMM_SEND_TEAM_REQ"
								 object:nil useLocks:NO useMainRunLoop:NO]; 
	}
	else {		
		if (multiThreaded) {
			timer = [NSTimer scheduledTimerWithTimeInterval: (1 / FRAME_RATE)
													 target:self selector:@selector(screenRefreshTimerFired:)
												   userInfo:nil 
													repeats:YES];
		} else {
			// singleTreaded
			[self performSelector:@selector(screenRefreshTimerFired:) withObject:nil afterDelay:(1 / FRAME_RATE)];
		}

	}

}

//#define SHOWTIME 0

- (void)screenRefreshTimerFired:(NSTimer*)theTimer {
    
	int interval; 
	
   static NSTimeInterval start, stop;
	
   start = [NSDate timeIntervalSinceReferenceDate]; 
#ifdef SHOWTIME
   LLLog(@"GuiManager.screenRefreshTimerFired(slept): %f sec", (start-stop));     
#endif

    if (gameState == GS_GAME_ACTIVE) {
		 //[notificationCenter setEnable:NO];
        // after that, repaint
		interval = (1 / FRAME_RATE); // for non-multithreading 
        [gameCntrl repaint:(start-stop)];        
    } else {
		interval = 1; // every second? it's quite blocking, for non-multithreading 
        //[notificationCenter setEnable:YES];
    }
	
    stop = [NSDate timeIntervalSinceReferenceDate];  
#ifdef SHOWTIME
    LLLog(@"GuiManager.screenRefreshTimerFired(spent): %f sec", (stop-start));
#endif
	
	// $$ this will work, but what about when we are killed?
	if (!multiThreaded) {
		if (![mutex lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]]) {
			LLLog(@"GuiManager.screenRefreshTimerFired cannot access client"); // no lock obtained, so no need to unlock
		} else {
			//lock obtained
			[client singleReadFromServer]; // single threaded 
			[mutex unlock];
		}
		
		// not using timers for events
		[self performSelector:@selector(screenRefreshTimerFired:) withObject:nil afterDelay:interval];
	}
	
	//[mainWindow displayIfNeeded];   // not needed comm is now threadsafe 
}

- (void)serverSelected:(MetaServerEntry *) selectedServer {
    
	// deactivate old quick connects
	quickConnect = NO;
	
    switch (gameState) {
        case GS_NO_SERVER_SELECTED:
        case GS_SERVER_SELECTED:
            // this event can also be a deselect 
            // handle it seperatly
            if (selectedServer == nil) {
                LLLog(@"GuiManager.serverSelected forwarding to deselect");
                [self serverDeSelected];
                return;
            }
            // when a server is selected, connect to it
            // to see if we can go to the login panel
            gameState = GS_SERVER_SELECTED;
            currentServer = selectedServer;
            
            // now initiate the step to the next state 
            [client stop];
            // run the client in the main thread (no seperate)
            if ([client startClientAt:[selectedServer address] 
                                 port:[selectedServer port] 
                             seperate:multiThreaded]) {
                // equals a CC_SERVER_CALL_SUCCESS
                LLLog(@"GuiManager.serverSelected connect to server successfull"); 
                // handle state entering
                if (multiThreaded) {            // other wise we have already a slot found
                   [self serverConnected]; 
                }
                            
            } else {
                // equals a CC_SERVER_CALL_FAILED
                LLLog(@"GuiManager.serverSelected cannot connect to server!");                
                // fall back to the first state
                [self serverDeSelected];
                // tell the selector that this server is no good
                [selectServerCntrl invalidServer];                
            }
            break;
        case GS_SERVER_CONNECTED:
        case GS_SERVER_SLOT_FOUND:
        case GS_LOGIN_ACCEPTED:			
            // same server selected again?
            //if (currentServer != selectedServer) {
			if (YES) {   // 1750207 reconnect fails				
				LLLog(@"GuiManager.serverSelected (re)connecting to %@", [selectedServer address]);
                
                if (currentServer != nil) {
                     // close old connection
					LLLog(@"GuiManager.serverSelected disconnecting to %@", [currentServer address]);
                    [self serverDeSelected];
                }
                // open to new
                [self serverSelected:selectedServer];
                currentServer = selectedServer;
            } else {
				LLLog(@"GuiManager.serverSelected ignoring GS_LOGIN_ACCEPTED of %@", [currentServer address]);
			}
            break;
        case GS_OUTFIT_ACCEPTED:
        case GS_GAME_ACTIVE:
            LLLog(@"GuiManager.serverSelected unexpected gameState %@, reseting", [self gameStateAsString]);
            [self serverDeSelected];
            [menuCntrl raiseMenu:self];
            break;
        default:
            LLLog(@"GuiManager.serverSelected unknown gameState %@", [self gameStateAsString]);
            break;
    }  	
    
    LLLog(@"GuiManager.serverSelected GAMESTATE = %@", [self gameStateAsString]);
}

- (void) serverDeSelected {
    // if no server was selected disable login cntrl
    gameState = GS_NO_SERVER_SELECTED;
    // stop connection
    [client stop];
    //[client release];
    // create an empty client
    //client = [[ClientController alloc] initWithUniverse:universe];
    // cannot login
    [menuCntrl disableLogin];
    [localServerCntrl disableLogin];
    [selectServerCntrl disableLogin];
    // when we can not type our name
    [loginCntrl disablePlayerName];
    [loginCntrl reset];
    currentServer = nil;
    // get's also called to force our state back to deselection
    // so make sure nothing is selected after all
    [selectServerCntrl deselectServer:self];
    
    LLLog(@"GuiManager.serverDeSelected GAMESTATE = %@", [self gameStateAsString]);
}

- (void) serverConnected {

    switch (gameState) {

        case GS_SERVER_SELECTED:            
            // nothing sepecial,
            // wait for a slot found
            gameState = GS_SERVER_CONNECTED;
            break;
        case GS_SERVER_SLOT_FOUND:
            // sometimes this happens immideatly
            break;            
        case GS_SERVER_CONNECTED:
        case GS_OUTFIT_ACCEPTED:            
        case GS_GAME_ACTIVE:
        case GS_LOGIN_ACCEPTED:
        case GS_NO_SERVER_SELECTED:
            LLLog(@"GuiManager.serverConnected unexpected gameState %@, reseting", [self gameStateAsString]);
            [self serverDeSelected];
            [menuCntrl raiseMenu:self];            
            break;
        default:
            LLLog(@"GuiManager.serverConnected unknown gameState %@", [self gameStateAsString]);
            break;
    }
 
    
    LLLog(@"GuiManager.serverConnected GAMESTATE = %@", [self gameStateAsString]);
}

- (void) serverSlotFound {
    switch (gameState) {
        case GS_NO_SERVER_SELECTED:

        case GS_OUTFIT_ACCEPTED:
            LLLog(@"GuiManager.serverSlotFound unexpected gameState %@, reseting", [self gameStateAsString]);
            [self serverDeSelected];
            [menuCntrl raiseMenu:self];            
            break;
        case GS_SERVER_CONNECTED:
        case GS_SERVER_SELECTED:                // can happen because of seperate thread
        case GS_GAME_ACTIVE:                    // after a ghostbust, reconnect is done automatically
            gameState = GS_SERVER_SLOT_FOUND;
            // now we can login
            [menuCntrl enableLogin];
            [localServerCntrl enableLogin];
            [selectServerCntrl enableLogin];
            [loginCntrl enablePlayerName];
            [loginCntrl startClock];
            // raise login window automatically
            // [menuCntrl raiseLogin:self];
            
            // a successfull login moves us to the next state
            
            // send our settings to the server            
            if (![client sendSlotSettingsToServer]) {
                LLLog(@"GuiManager.serverSlotFound cannot send slot settings to server!");
                [self serverDeSelected];
            }
            break;
        default:
            LLLog(@"GuiManager.serverSlotFound unknown gameState %@", [self gameStateAsString]);
            break;
    }
    
    LLLog(@"GuiManager.serverSlotFound GAMESTATE = %@", [self gameStateAsString]);
	
	if (quickConnect) {
		LLLog(@"GuiManager.serverSlotFound calling autologin");
		[self quickConnectAutoLogin];
	}
	
}

- (void) iDied {
    // restore the cursor if needed
    if ([NSCursor currentCursor] == [NSCursor crosshairCursor]) {
        [[NSCursor crosshairCursor] pop];
    }
	[keyMapPanel close]; // remove the help screen
    [gameCntrl stopGame];
    [self loginComplete];
}

- (void) loginComplete {
    switch (gameState) {
        case GS_NO_SERVER_SELECTED:
        case GS_SERVER_SELECTED:
        case GS_SERVER_CONNECTED:
        case GS_OUTFIT_ACCEPTED:
            LLLog(@"GuiManager.loginComplete unexpected gameState %@, reseting", [self gameStateAsString]);
            [self serverDeSelected];
            [menuCntrl raiseMenu:self]; 
            break;
        case GS_LOGIN_ACCEPTED: // when outfit is not accepted try again
            LLLog(@"GuiManager.loginComplete login was not accepted, try again");
            // a successfull outfit moves us to the next state
            break;
        case GS_SERVER_SLOT_FOUND:
            gameState = GS_LOGIN_ACCEPTED;
            // cannot login twice
            [menuCntrl disableLogin];
            [localServerCntrl disableLogin];
            [selectServerCntrl disableLogin];
            // when we can not type our name
            [loginCntrl disablePlayerName];
            // set the theme
			[self setTheme];
            // raise the outfit window automatically
            [menuCntrl raiseOutfit:self];
            // start with a empty login
            [outfitCntrl setInstructionFieldToDefault];
            // when we receive status messages, outfitCntrl updates the textfield 
            // only as long as we are in outfit!!!
            [notificationCenter addObserver:outfitCntrl selector:@selector(setInstructionField:) name:@"SP_WARNING"
                                     object:nil useLocks:NO useMainRunLoop:YES]; 
			if (quickConnect) {
				// wait 100ms to allow SP_MASK to arrive
				LLLog(@"GuiManager.loginComplete delaying request for ship and team by 100ms");
				//[self performSelector:@selector(quickConnectPickTeamShip) withObject:self afterDelay:0.1];
				// does not work after delay
				[self quickConnectPickTeamShip];
			}
            // else a successfull outfit moves us to the next state
            break;
        case GS_GAME_ACTIVE:    // if we are killed we get back here
            // start with a empty login
            [outfitCntrl setInstructionFieldToDefault];
            // when we receive status messages, outfitCntrl updates the textfield 
            // only as long as we are in outfit!!!
            [notificationCenter addObserver:outfitCntrl selector:@selector(setInstructionField:) name:@"SP_WARNING"
                                     object:nil useLocks:NO useMainRunLoop:YES]; 
            gameState = GS_LOGIN_ACCEPTED;
            // raise the outfit window automatically
            [menuCntrl raiseOutfit:self];
            // a successfull outfit moves us to the next state
            break;
        default:
            LLLog(@"GuiManager.loginComplete unknown gameState %@", [self gameStateAsString]);
            break;
    }
    LLLog(@"GuiManager.loginComplete GAMESTATE = %@", [self gameStateAsString]);
}

- (void) outfitAccepted {
    switch (gameState) {
        case GS_NO_SERVER_SELECTED:
        case GS_SERVER_SELECTED:
        case GS_SERVER_CONNECTED:
        case GS_OUTFIT_ACCEPTED:
        case GS_SERVER_SLOT_FOUND:
        case GS_GAME_ACTIVE:
            LLLog(@"GuiManager.outfitAccepted unexpected gameState %@, reseting", [self gameStateAsString]);
            [self serverDeSelected];
			[menuCntrl setCanPlay:NO];
            [menuCntrl raiseMenu:self];            
            break;
        case GS_LOGIN_ACCEPTED:
            gameState = GS_OUTFIT_ACCEPTED;
            // let outfitCntrl stop listening to warnings
            [notificationCenter removeObserver:outfitCntrl name:@"SP_WARNING"];
            [outfitCntrl setInstructionFieldToDefault];
			[menuCntrl setCanPlay:YES];
            // activate the game
            [self gameEntered];
 
            break;
        default:
            LLLog(@"GuiManager.outfitAccepted unknown gameState %@", [self gameStateAsString]);
            break;
    }
    LLLog(@"GuiManager.outfitAccepted GAMESTATE = %@", [self gameStateAsString]);
}

- (void) gameEntered { 

    switch (gameState) {
        case GS_NO_SERVER_SELECTED:
        case GS_SERVER_SELECTED:
        case GS_SERVER_CONNECTED:
        case GS_LOGIN_ACCEPTED:
        case GS_SERVER_SLOT_FOUND:
        case GS_GAME_ACTIVE:
            LLLog(@"GuiManager.gameEntered unexpected gameState %@, reseting", [self gameStateAsString]);
            [self serverDeSelected];
            [menuCntrl raiseMenu:self];            
            break;
        case GS_OUTFIT_ACCEPTED:
			// -----------------------------------------------------
			// let the games begin, but first setup all the data
			// we require
			// -----------------------------------------------------		
			// set the featurelist of this server (current settings)
			[[gameCntrl gameView] setFeatureList:[[client communication] featureList]];
			[[gameCntrl mapView] setFeatureList:[[client communication] featureList]];
            // save the keymap if it was changed
            [[settingsCntrl actionKeyMap] writeToDefaultFileIfChanged];
			/* FR 1682996 refactor settings
			
            // first pass on the keyMap that was created in the settings
            [gameCntrl setActionKeyMap:[settingsCntrl actionKeyMap]]; 
			[gameCntrl setDistressKeyMap:[settingsCntrl distressKeyMap]]; 
			// 1666849 and the mouse
			[gameCntrl setMouseMap:[settingsCntrl mouseMap]];
			*/
			[self fillKeyMapPanel];
            // and the volume setting
            [soundPlayerActiveTheme setVolumeFx:[settingsCntrl fxLevel]];
            [soundPlayerActiveTheme setVolumeMusic:[settingsCntrl musicLevel]];
            // go and play
            [menuCntrl raiseGame:self];
            [gameCntrl startGame];
            gameState = GS_GAME_ACTIVE;
            // a kill or error will get us out of the game  
            [soundPlayerActiveTheme playSoundEffect:@"ENTER_SHIP_SOUND"];
			[notificationCenter postNotificationName:@"GM_GAME_ENTERED"];
            // show help first time BUG 1750211
            if (firstGame) {
                [self showKeyMapPanel];
                firstGame = NO;
            }
            
			[self quickConnectComplete];
            break;
        default:
            LLLog(@"GuiManager.gameEntered unknown gameState %@", [self gameStateAsString]);
            break;
    }
    LLLog(@"GuiManager.gameEntered GAMESTATE = %@", [self gameStateAsString]);
}

- (void) commError { 
    switch (gameState) {
        case GS_NO_SERVER_SELECTED:
        case GS_SERVER_SELECTED:
            break;                      // queued events 
        case GS_SERVER_CONNECTED:
        case GS_LOGIN_ACCEPTED:
        case GS_SERVER_SLOT_FOUND:
        case GS_GAME_ACTIVE:
        case GS_OUTFIT_ACCEPTED:
            LLLog(@"GuiManager.commError unexpected (gameState %@), reseting", [self gameStateAsString]);
			[keyMapPanel close]; // remove the help screen
            [self serverDeSelected];
			[menuCntrl disableLogin];
            [menuCntrl raiseMenu:self];            
            break;
        default:
            LLLog(@"GuiManager.gameEntered unknown gameState %@", [self gameStateAsString]);
            break;
    }
    LLLog(@"GuiManager.commError GAMESTATE = %@", [self gameStateAsString]);
}

- (void) setTheme {
    
    // we are not yet setting the mapview to a themed painter,
    // can do so in the future if desired.    
    int theme = [settingsCntrl graphicsModel] + 1; // we count 1,2,3 graphicsModel starts at 0
    bool shouldSpeak = [settingsCntrl voiceEnabled];
	bool accel = [settingsCntrl accelerate];
    
    if (theme != activeTheme) {
        LLLog(@"GuiManager.setTheme to theme %d", theme);
        switch (theme) {
        case 1:            
            [gameCntrl setPainter:painterTheme1];
            painterActiveTheme = painterTheme1;
            [soundPlayerActiveTheme unSubscibeToNotifications]; // silence
            soundPlayerActiveTheme = soundPlayerTheme1;
            [soundPlayerActiveTheme subscribeToNotifications];  // activate            
            break;
        case 2:            
            [gameCntrl setPainter:painterTheme2];
            painterActiveTheme = painterTheme2;
            [soundPlayerActiveTheme unSubscibeToNotifications]; // silence
            soundPlayerActiveTheme = soundPlayerTheme2;
            [soundPlayerActiveTheme subscribeToNotifications];  // activate
            break;
        case 3:            
            [gameCntrl setPainter:painterTheme3];
            painterActiveTheme = painterTheme3;
            [soundPlayerActiveTheme unSubscibeToNotifications]; // silence
            soundPlayerActiveTheme = soundPlayerTheme3;
            [soundPlayerActiveTheme subscribeToNotifications];  // activate            
            break;            
        default:
            LLLog(@"GuiManager.setTheme ERROR, do not know of theme %d", theme);
            break;
        }
		activeTheme = theme;
		[gameCntrl setSpeakComputerMessages:shouldSpeak];
		[painterActiveTheme setAccelerate:accel];
		
		// add voice commands
		[gameCntrl setListenToVoiceCommands:[settingsCntrl voiceCommands]]; 
    }
    
    [soundPlayerActiveTheme setVolumeFx:[settingsCntrl fxLevel]]; 
	[outfitCntrl setActivePainter:painterActiveTheme];
	
    if ([settingsCntrl fxLevel] == 0.0) {
        // special case disable all sound
        [soundPlayerActiveTheme unSubscibeToNotifications]; // silence
        LLLog(@"GuiManager.setTheme silencing SOUND");
    }
}

- (void) setUpKeyMapPanel {
	//static LLHUDWindowController *helpWindowCntrl = nil;
	
	if (!helpWindowCntrl) {
		helpWindowCntrl = [[LLHUDWindowController alloc] init];		
		// Make a rect to position the window at the top-right of the screen.
		NSSize windowSize = NSMakeSize(325.0, 765.0);
		[helpWindowCntrl createWindowWithTextFieldWithSize:windowSize];
	}
	
	[[helpWindowCntrl window] setTitle:@"Keyboard Mapping"];
	//[[helpWindowCntrl window] orderFront:self];
	
	LLLog(@"GuiManager.setUpKeyMapPanel: DONE");
}

- (void) showKeyMapPanel {
	
	// toggle position
	/*
	if ([keyMapPanel isVisible]) {
		[keyMapPanel close];
	} else {
		[keyMapPanel orderFront:self];
	}
	 */
	
	static int mode = 0; // 0 = invisible, 1 = action keys, 2 is macro keys
	
	if ([[helpWindowCntrl window] isVisible]) {
		if (mode == 1) {
			// refill panel
			[self fillKeyMapPanel];
			// and show
			[[helpWindowCntrl window] orderFront:self];
			mode = 2;
		} else {
			[[helpWindowCntrl window] close];
			mode = 0;
		}
	} else {
		// refill panel
		[self fillKeyMapPanel];
		[[helpWindowCntrl window] orderFront:self];
		mode = 1;
	}
}

- (void) fillKeyMapPanel {

	LLLog(@"GuiManager.fillKeyMapPanel setting keymap in help panel");

	static bool showActionKeys = YES;
	
	NSMutableString *result = [[[NSMutableString alloc] init] autorelease];
	
	// toggle contents
	if (showActionKeys) {
		// add the distress macros too
		//[result appendString:@"---------Communication--------\n"];
		MTKeyMap *keyMap = [settingsCntrl distressKeyMap];
		NSArray *actionKeys = [keyMap allKeys];
		
		for (int i = 0; i < [actionKeys count]; i++) {
			int action = [[actionKeys objectAtIndex:i] intValue];
			[result appendString:[NSString stringWithFormat:@"%c - %@\n", 
				[keyMap keyForAction:action], [keyMap descriptionForAction:action]]];
		}
		showActionKeys = NO;
	} else {
		// add the actions	
		//[result appendString:@"-----------Controls-----------\n"];
		MTKeyMap *keyMap = [settingsCntrl actionKeyMap];
		NSArray *actionKeys = [keyMap allKeys];
		for (int i = 0; i < [actionKeys count]; i++) {
			int action = [[actionKeys objectAtIndex:i] intValue];
			[result appendString:[NSString stringWithFormat:@"%c - %@\n", 
				[keyMap keyForAction:action], [keyMap descriptionForAction:action]]];
		}
		showActionKeys = YES;
	}
	
	//[keyMapList setString:result];
	[[helpWindowCntrl textField] setStringValue:result];
	//LLLog(@"GuiManager.fillKeyMapPanel setting %@", [[helpWindowCntrl textField] stringValue]);
}

@end
