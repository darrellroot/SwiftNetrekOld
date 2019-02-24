//
//  GameView.m
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "GameView.h"


@implementation GameView

- (void) awakeFromNib {
    
    [super awakeFromNib];
    
	warMask = 0; // at peace with all
	warTeam = nil; // no team selected 
    step = GV_SCALE_STEP;
    actionKeyMap = nil;
	distressKeyMap = nil;
	mouseMap = nil;
    scale = 40; // default
    trigonometry = [LLTrigonometry defaultInstance];

    angleConvertor = [[Entity alloc] init];
	screenshotController = [[LLScreenShotController alloc] init];
    busyDrawing = NO;
    
    inputMode = GV_NORMAL_MODE;
		
	// listen to voice commands here
	[notificationCenter addObserver:self selector:@selector(voiceCommand:) name:@"VC_VOICE_COMMAND"];
	[notificationCenter addObserver:self selector:@selector(settingsChanged:) name:@"SC_NEW_SETTINGS"];
	
	// and take over any defaults that there may be
	[self settingsChanged:nil];
}

- (void) settingsChanged:(SettingsController*) settingsController {
	actionKeyMap = [properties objectForKey:@"ACTION_KEYMAP"];
	distressKeyMap = [properties objectForKey:@"DISTRESS_KEYMAP"];
	mouseMap = [properties objectForKey:@"MOUSE_MAP"];
}

- (void) voiceCommand:(NSNumber *) action {
	
	// before we accept a command, the mouse must
	// be in our window	
	NSPoint mousePos = [self mousePos];
	
	if (NSPointInRect(mousePos, [self bounds])) {
		LLLog(@"GameView.voiceCommand entered");
		[self performAction:[action intValue]];
	} else {
		LLLog(@"GameView.voiceCommand ignored");
	}	
}

- (void) makeFirstResponder {
	[[self window] makeFirstResponder:self];
}

- (void) setPainter:(PainterFactory*)newPainter {
    painter = newPainter;
    // reset inputMode too
    inputMode = GV_NORMAL_MODE;
}

- (NSPoint) gamePointRepresentingCentreOfView {
	//LLLog(@"GameView.gamePointRepresentingCentreOfView entered");
    return [[universe playerThatIsMe] predictedPosition];
}

- (void) setScaleFullView {
    NSSize viewSize = [self bounds].size;
    
    int minSize = (viewSize.height < viewSize.width ? viewSize.height : viewSize.width);
    
    // minSize must cover UNIVERSE_PIXEL_SIZE thus zoom is
    scale = UNIVERSE_PIXEL_SIZE / minSize;
}

- (void) setScale:(int)newScale {
    scale = newScale;
}

- (int) scale {
    return scale;
}

// draw the view
- (void)drawRect:(NSRect)aRect {
    
    // sometimes the drawing takes so long the timer invokes another go
    // maybe should use locks..
    if (busyDrawing) {
        LLLog(@"GameView.drawRect busy drawing");
        return;
    }    
    busyDrawing = YES;
    
    // during this draw i want to lock universal access (try for half a framerate)
    if ([[universe synchronizeAccess] lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:MAX_WAIT_BEFORE_DRAW]]) { 
        
        // first set up the gamebounds based on my position
        NSRect gameBounds = [painter gameRectAround:[self gamePointRepresentingCentreOfView]
                                            forView:[self bounds]
                                          withScale:scale]; 
        // then draw it        
        [painter drawRect:aRect 
             ofViewBounds:[self bounds] 
whichRepresentsGameBounds:gameBounds
                withScale:scale]; 
        
        [[universe synchronizeAccess] unlock];
    } else {
        LLLog(@"GameView.drawRect waited %f seconds for lock, discarding", MAX_WAIT_BEFORE_DRAW);
        
        // first set up the gamebounds based on my position
        NSRect gameBounds = [painter gameRectAround:[self gamePointRepresentingCentreOfView]
                                            forView:[self bounds]
                                          withScale:scale]; 
        // then draw it        
        [painter drawRect:aRect 
             ofViewBounds:[self bounds] 
whichRepresentsGameBounds:gameBounds
                withScale:scale]; 
        
        // no lock obtained, so no need to unlock
    }
    busyDrawing = NO;
}

/* FR 1682996 refactor settings

// 1666849 selectable mouse buttons
- (void) setMouseMap:(MTMouseMap *)newMouseMap {
	[mouseMap release];
	mouseMap = newMouseMap;
	[mouseMap retain];
}

- (void) setDistressKeyMap:(MTKeyMap *)newKeyMap {
	[distressKeyMap release];
    distressKeyMap = newKeyMap;
	[distressKeyMap retain];
}

- (void) setActionKeyMap:(MTKeyMap *)newKeyMap {
	[actionKeyMap release];
    actionKeyMap = newKeyMap;
	[actionKeyMap retain];
}
*/
// view functions
- (void) keyDown:(NSEvent *)theEvent {
    
    if (actionKeyMap == nil) {
        LLLog(@"GameView.keyDown have no keymap");
        [super keyDown:theEvent];
        return;
    }
    
    switch (inputMode) {
    case GV_NORMAL_MODE:
        //LLLog(@"GameView.keyDown handle in normal mode");  // happens often
        [self normalModeKeyDown:theEvent];
        break;
    case GV_MESSAGE_MODE:
        LLLog(@"GameView.keyDown handle in message mode");
        [self messageModeKeyDown:theEvent];
        break;
    case GV_MACRO_MODE:
        LLLog(@"GameView.keyDown handle in macro mode");
        [self macroModeKeyDown:theEvent];
        break;
    case GV_REFIT_MODE:
        LLLog(@"GameView.keyDown handle in refit mode");
        [self refitModeKeyDown:theEvent];
        break;
	case GV_WAR_MODE:
        LLLog(@"GameView.keyDown handle in war mode");
        [self warModeKeyDown:theEvent];
        break;
    default:
        LLLog(@"GameView.keyDown unknown mode %d", inputMode);
        // reset
        inputMode = GV_NORMAL_MODE;
        break;
    }    
}

- (void) normalModeKeyDown:(NSEvent *)theEvent  {
    
    // check all characters in the event
	// $$$ why not use charactersIgnoringModifiers???
    NSString *characters = [theEvent characters];
    
    for (int i = 0; i < [characters length]; i++) {
        unichar theChar = [characters characterAtIndex:i];
        unsigned int modifierFlags = [theEvent modifierFlags];
        
		// current implementation allows the sending of distress calls by
		// holding down the control key
		if (modifierFlags & NSControlKeyMask) {
			// convert the mouse pointer to a point in the game grid
            NSPoint targetGamePoint = [painter gamePointFromViewPoint:[self mousePos] 
                                                     viewRect:[self bounds]
                                        gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                                    withScale:scale];
			// first tell the handler where our mouse is
			[macroHandler setGameViewPointOfCursor:targetGamePoint];
			// handle the distress as a macro (first remove the modifiers...)
			char c = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
			
			// lookup which distress this should be
			int distressCode = [distressKeyMap actionForKey:c withModifierFlags:modifierFlags];
			// only valid keys
			if (distressCode == DC_UNKNOWN) {
				[super keyDown:theEvent];
			}
			else {
				bool useRCD = [[properties valueForKey:@"USE_RCD"] boolValue];				
				if (useRCD) {
					LLLog(@"GameView.keyDown sending RCD %d", distressCode);
					[macroHandler sendReceiverConfigureableDistress:distressCode];
				} else {  // normal
					LLLog(@"GameView.keyDown sending MACRO %d", distressCode);
					[macroHandler sendDistress:distressCode];
				}
			}
			return;
		} else {	
			// lookup which action this should be
			int action = [actionKeyMap actionForKey:theChar withModifierFlags:modifierFlags];
			
			// only valid keys
			if (action == ACTION_UNKNOWN) {
				[super keyDown:theEvent];
			}
			else {
				if ([self performAction: action] == NO) {
					[super keyDown:theEvent];
				}
			}   
		}
    }  
}

- (void) messageModeKeyDown:(NSEvent *)theEvent {
    
    // always reset
    inputMode = GV_NORMAL_MODE;
    
    // fish for [A|G|T|F|K|O|R|0..f] 
    // create address and send the event
    
    // going for the first char only
    unichar theChar = [[theEvent characters] characterAtIndex:0];
    int playerId = -1;    
    
    switch (theChar) {
    case 'A':
    //case 'a': // could also be player a
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"ALL"];
        return;
        break;
    case 'G':
    //case 'g': // 1751357 g is now a player
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"GOD"];
        return;
        break;
    //case 'T': // 1751357 T is should be a player ?
    case 't':
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"TEAM"];
        return;
        break;
    case 'F':
    //case'f': // could also be player f
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"FED"];
        return;
        break;
    case 'K':
    case 'k':
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"KLI"];
        return;
        break;
    case 'R':
    case 'r':
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"ROM"];
        return;
        break;
    case 'O':
    case 'o':
        [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" userInfo:@"ORI"];
        return;
        break;
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
        playerId = theChar - '0';
        break;
    default:    
         // 1751357 support up to 32 players
        if ((theChar >= 'a') && (theChar <= 'v')) {
            playerId = theChar - 'a' + 10;
        } else if (theChar == 'T') {
            playerId = 't' - 'a' + 10; // swap t and T
        } else {
            [notificationCenter postNotificationName:@"PM_WARNING" userInfo:@"Unknown player. message not sent."]; 
            return; 
        }
        break;
    }
    [notificationCenter postNotificationName:@"GV_MESSAGE_DEST" 
                                    userInfo:[[universe playerWithId:playerId] mapChars]];
}

- (void) macroModeKeyDown:(NSEvent *)theEvent {
    // $$ should do something here
    LLLog(@"GameView.macroModeKeyDown not implemented");
    // reset
    inputMode = GV_NORMAL_MODE;
}

- (void) refitModeKeyDown:(NSEvent *)theEvent {
    // always reset
    inputMode = GV_NORMAL_MODE;   
    
    // going for the first char only
    unichar theChar = [[theEvent characters] characterAtIndex:0];
    
    char ship_type = SHIP_CA;
    switch(theChar) {
		case 's' : case 'S' :
			ship_type = SHIP_SC;			
			break;
		case 'd' : case 'D' :
			ship_type = SHIP_DD;
			break;
		case 'c' : case 'C' :
			ship_type = SHIP_CA;
			break;
		case 'b' : case 'B' :
			ship_type = SHIP_BB;
			break;
		case 'g' : case 'G' :
			ship_type = SHIP_GA;
			break;
		case 'o' : case 'O' :
			ship_type = SHIP_SB;
			break;
		case 'a' : case 'A' :
			ship_type = SHIP_AS;
			break;
		default :
			return;
    }
    [notificationCenter postNotificationName:@"COMM_SEND_REFIT_REQ" userInfo:[NSNumber numberWithChar:ship_type]];    
}


- (void) warModeKeyDown:(NSEvent *)theEvent {
    // always reset
    inputMode = GV_NORMAL_MODE;   
    
	// is a team selected for negotiations?
	if (warTeam == nil) {
		LLLog(@"GameView.warModeKeyDown no team selected");
		return;
	}	
	
    // going for the first char only
    unichar theChar = [[theEvent characters] characterAtIndex:0];
    
	if (theChar == 'h') {
		// they really want to decleare war
		warMask |= [warTeam bitMask];
		LLLog(@"GameView.warModeKeyDown declaring hostile on %@", [warTeam abbreviation]);
		[notificationCenter postNotificationName:@"COMM_SEND_WAR_REQ" userInfo:[NSNumber numberWithChar:warMask]];    
		// update warning BUG 1682448
		[notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:[NSString stringWithFormat:@"Declaring war on %@", [warTeam abbreviation]]];
	} else if (theChar == 'p') {
		// they really want to decleare peace
		warMask &= ~([warTeam bitMask]);
        LLLog(@"GameView.warModeKeyDown declaring peace on %@", [warTeam abbreviation]);
		[notificationCenter postNotificationName:@"COMM_SEND_WAR_REQ" userInfo:[NSNumber numberWithChar:warMask]];
		// update warning BUG 1682448
		[notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:[NSString stringWithFormat:@"Sending peace treaty to %@", [warTeam abbreviation]]];
	} 
	// always clear the team
	warTeam = nil;
}

// mouse events 1666849 now dynamic allocated
- (void) mouseDown:(NSEvent *)theEvent {
    [self performAction:[mouseMap actionMouseLeft]];
}

- (void) otherMouseDown:(NSEvent *)theEvent {
    [self performAction:[mouseMap actionMouseMiddle]];
}

- (void) rightMouseDown:(NSEvent *)theEvent {    
    [self performAction:[mouseMap actionMouseRight]];
}

// 1636254 continuous steering (or torping for that matter since 1666849)
- (void)rightMouseDragged:(NSEvent *)theEvent {
	[self rightMouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
	[self mouseDown:theEvent];
}

- (void) otherMouseDragged:(NSEvent *)theEvent {
	[self otherMouseDown:theEvent];
}

// there should be an action for that and a button but leave it
// static for now 
- (void) scrollWheel:(NSEvent *)theEvent {
    float mouseRole = [theEvent deltaY];
    // 1.0 means zoom in
    // -1.0 means zoom out
    if (mouseRole > 0) {
        // zoom in means smaller scale factor
        int newScale = scale - step*scale;
        if (newScale == scale) {
            newScale = scale - 1; // at least 1
        }
        // if scale is small it may not be possible to zoom in
        // scale*step = 0;
        if (newScale > [painter minScale]) {
            scale = newScale; 
        }
    } else {
        // zoom out means larger factor
        // if scale is small it may not be possible to zoom out
        // scale*step = 0 this means you'll stay zoomed in
        int newScale = scale + step*scale;
        if (newScale == scale) {
            newScale = scale + 1; // at least 1
        }
        if (newScale < [painter maxScale]) {
            scale = newScale;
        }
    }
    //LLLog(@"GameView.scrollWheel setting scale to %d", scale);
}


- (void) sendSpeedReq:(int)speed {
    if (universe == nil) {
        LLLog(@"GameView.sendSpeedReq have no universe?");
    }
    
    int maxSpeed = [[[universe playerThatIsMe] ship] maxSpeed];   
    if (speed > maxSpeed) {
        speed = maxSpeed;
    }
    
    [[universe playerThatIsMe] setRequestedSpeed:speed]; // store here so we can track accelertaion in the future
    [notificationCenter postNotificationName:@"COMM_SEND_SPEED_REQ" userInfo:[NSNumber numberWithInt:speed]];
}

- (float) mouseDir {

	/* 1636263 must be relative between centerpos
    NSPoint mouseLocation = [self mousePos];
    
    // we are at the center
	NSPoint ourLocation;
    NSRect bounds = [self bounds];
    ourLocation.x = bounds.size.width / 2;
    ourLocation.y = bounds.size.height / 2;
    
    // the direction is
	//float dir = [trigonometry angleDegBetween:mouseLocation andPoint:ourLocation];
    */
	 
	// convert the mouse pointer to a point in the game grid
	NSPoint mouseLocation = [painter gamePointFromViewPoint:[self mousePos] 
												   viewRect:[self bounds]
									  gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
												  withScale:scale]; 
	
	NSPoint ourLocation = [[universe playerThatIsMe] predictedPosition];
	
    float dir = [trigonometry angleDegBetween:mouseLocation andPoint:ourLocation];
    dir -= 90;  // north is 0 deg
    if (dir < 0) {
        dir += 360;
    }
    //LLLog(@"GameView.mouseDir = %f", dir);
    
    return dir;
}

// $$ may need locks here if the code becomes multi threaded
- (bool) performAction:(int) action {
    
    //LLLog(@"GameView.performAction performing action %d", action);
    
    int maxSpeed, speed;
    Player *target = nil;
    Planet *planet = nil;
    NSPoint targetGamePoint;
    Player *me = [universe playerThatIsMe];    // IS used sometimes, compiler just complains..
    
    switch (action) {
        case ACTION_UNKNOWN:
            LLLog(@"GameView.performAction unknown action %d", action);
            return NO;
            break;
	    case ACTION_CLOAK:
            if ([[universe playerThatIsMe] flags] & PLAYER_CLOAK) {
                [notificationCenter postNotificationName:@"COMM_SEND_CLOAK_REQ" userInfo:[NSNumber numberWithBool:NO]];                
            } else {
                [notificationCenter postNotificationName:@"COMM_SEND_CLOAK_REQ" userInfo:[NSNumber numberWithBool:YES]];
            }
            break;
	    case ACTION_DET_ENEMY:
            // $$ JTrek checks if current time - last det time > 100 ms before sending this again
            // sounds sensible...
            [notificationCenter postNotificationName:@"COMM_SEND_DETONATE_REQ" userInfo:nil];
            break;
	    case ACTION_DET_OWN: // detting ALL
            [notificationCenter postNotificationName:@"COMM_SEND_DET_MINE_ALL_REQ" userInfo:nil];
            break;
	    case ACTION_FIRE_PLASMA:
            // $$ we can check if we are able to fire plasmas at all before poluting the network
            [angleConvertor setCourse:[self mouseDir]];            
            [notificationCenter postNotificationName:@"COMM_SEND_PLASMA_REQ" userInfo:[NSNumber numberWithChar:[angleConvertor netrekFormatCourse]]];
            break;
	    case ACTION_FIRE_TORPEDO:
            [angleConvertor setCourse:[self mouseDir]];            
            [notificationCenter postNotificationName:@"COMM_SEND_TORPS_REQ" userInfo:[NSNumber numberWithChar:[angleConvertor netrekFormatCourse]]];
            break;
	    case ACTION_FIRE_PHASER:
            [angleConvertor setCourse:[self mouseDir]];            
            [notificationCenter postNotificationName:@"COMM_SEND_PHASER_REQ" userInfo:[NSNumber numberWithChar:[angleConvertor netrekFormatCourse]]];
            break;
	    case ACTION_SHIELDS:
            if ([me flags] & PLAYER_SHIELD) {
                [notificationCenter postNotificationName:@"COMM_SEND_SHIELD_REQ" userInfo:[NSNumber numberWithBool:NO]];                
            } else {
                [notificationCenter postNotificationName:@"COMM_SEND_SHIELD_REQ" userInfo:[NSNumber numberWithBool:YES]];
            }
            break;
	    case ACTION_TRACTOR:
            // convert the mouse pointer to a point in the game grid
            targetGamePoint = [painter gamePointFromViewPoint:[self mousePos] 
                                                     viewRect:[self bounds]
                                        gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                                    withScale:scale];
            // find the nearest player
            target = [universe playerNearPosition:targetGamePoint ofType:UNIVERSE_TARG_PLAYER];
            
            // if we are already tracktoring/pressoring, disable
            if ([[universe playerThatIsMe] flags] & PLAYER_TRACT) {
                // $$ it is probaly not needed to figure out the correct playerId..
                [notificationCenter postNotificationName:@"COMM_SEND_TRACTOR_OFF_REQ" 
                                                userInfo:[NSNumber numberWithInt:[target playerId]]];
            } else {
                [notificationCenter postNotificationName:@"COMM_SEND_TRACTOR_ON_REQ" 
                                                userInfo:[NSNumber numberWithInt:[target playerId]]];
                [[universe playerThatIsMe] setTractorTarget:target];
            }
                break;
	    case ACTION_PRESSOR:
            // convert the mouse pointer to a point in the game grid
            targetGamePoint = [painter gamePointFromViewPoint:[self mousePos] 
                                                     viewRect:[self bounds]
                                        gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                                    withScale:scale];
            // find the nearest player
            target = [universe playerNearPosition:targetGamePoint ofType:UNIVERSE_TARG_PLAYER];
            
            // if we are already tracktoring/pressoring, disable
            if ([[universe playerThatIsMe] flags] & PLAYER_PRESS) {
                // $$ it is probaly not needed to figure out the correct playerId..
                [notificationCenter postNotificationName:@"COMM_SEND_REPRESSOR_OFF_REQ" 
                                                userInfo:[NSNumber numberWithInt:[target playerId]]];
            } else {
                [notificationCenter postNotificationName:@"COMM_SEND_REPRESSOR_ON_REQ" 
                                                userInfo:[NSNumber numberWithInt:[target playerId]]];
                // $$ bit strange, but i assume we cannot pressor one target and tractor another at
                // the same time
                [[universe playerThatIsMe] setTractorTarget:target];
            }
            break;
        case ACTION_WARP_0:  
            [self sendSpeedReq:0];
            break;
	    case ACTION_WARP_1:
            [self sendSpeedReq:1];
            break;
	    case ACTION_WARP_2:
            [self sendSpeedReq:2];
            break;
	    case ACTION_WARP_3:
            [self sendSpeedReq:3];
            break;
        case ACTION_WARP_4:
            [self sendSpeedReq:4];
            break;
        case ACTION_WARP_5:
            [self sendSpeedReq:5];
            break;
        case ACTION_WARP_6:
            [self sendSpeedReq:6];
            break;
        case ACTION_WARP_7:
            [self sendSpeedReq:7];
            break;
        case ACTION_WARP_8:
            [self sendSpeedReq:8];
            break;
        case ACTION_WARP_9:
            [self sendSpeedReq:9];
            break;
        case ACTION_WARP_10:
            [self sendSpeedReq:10];
            break;
        case ACTION_WARP_11:
            [self sendSpeedReq:11];
            break;
        case ACTION_WARP_12:
            [self sendSpeedReq:0];
            break;
        case ACTION_WARP_MAX:
            maxSpeed = [[[universe playerThatIsMe] ship] maxSpeed];
            [self sendSpeedReq:maxSpeed];
            break;
        case ACTION_WARP_HALF_MAX:
            maxSpeed = [[[universe playerThatIsMe] ship] maxSpeed];
            [self sendSpeedReq:maxSpeed / 2];
            break;
        case ACTION_WARP_INCREASE:
            speed = [[universe playerThatIsMe] speed];
            [self sendSpeedReq:speed + 1];
            break;
        case ACTION_WARP_DECREASE:
            speed = [[universe playerThatIsMe] speed];
            [self sendSpeedReq:speed - 1];
            break;
        case ACTION_SET_COURSE:
            [angleConvertor setCourse:[self mouseDir]];            
            [notificationCenter postNotificationName:@"COMM_SEND_DIR_REQ" userInfo:[NSNumber numberWithChar:[angleConvertor netrekFormatCourse]]];
            // remove the planet lock
            [me setFlags:[me flags] & ~(PLAYER_PLOCK | PLAYER_PLLOCK)];
            break;
        case ACTION_LOCK:
            // convert the mouse pointer to a point in the game grid
            targetGamePoint = [painter gamePointFromViewPoint:[self mousePos] 
                                                     viewRect:[self bounds]
                                        gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                                    withScale:scale];
            // find the nearest player
            target = [universe playerNearPosition:targetGamePoint ofType:UNIVERSE_TARG_PLAYER];
            // find the nearest planet
            planet = [universe planetNearPosition:targetGamePoint];
            // lock on the closest
            if ([universe entity:target closerToPos:targetGamePoint than:planet]) {
                // lock on player
                [notificationCenter postNotificationName:@"COMM_SEND_PLAYER_LOCK_REQ" 
                                                userInfo:[NSNumber numberWithInt:[target playerId]]];
                [me setPlayerLock:target];
            } else {
                // lock on planet
                [notificationCenter postNotificationName:@"COMM_SEND_PLANET_LOCK_REQ" 
                                                userInfo:[NSNumber numberWithInt:[planet planetId]]];
                [me setPlanetLock:planet];
            }
            break;
        case ACTION_PRACTICE_BOT:
            [notificationCenter postNotificationName:@"COMM_SEND_PRACTICE_REQ"];
            break;
        case ACTION_TRANSWARP:
            // netrek uses the same message for this, it could lead to very
            // funny results now we seperate it.
            [notificationCenter postNotificationName:@"COMM_SEND_PRACTICE_REQ"];
            break;
        case ACTION_BOMB:
            if (([me flags] & PLAYER_BOMB) == 0) { // already bombing?
                [notificationCenter postNotificationName:@"COMM_SEND_BOMB_REQ" 
                                                userInfo:[NSNumber numberWithBool:YES]];
            }
            break;
        case ACTION_ORBIT:
            [notificationCenter postNotificationName:@"COMM_SEND_ORBIT_REQ" 
                                            userInfo:[NSNumber numberWithBool:YES]];
            break;
        case ACTION_BEAM_DOWN:
            if (([me flags] & PLAYER_BEAMDOWN) == 0) { // already beaming?
                [notificationCenter postNotificationName:@"COMM_SEND_BEAM_REQ" 
                                                userInfo:[NSNumber numberWithBool:NO]]; // no means down
            }
            break;
        case ACTION_BEAM_UP:
            if (([me flags] & PLAYER_BEAMUP) == 0) { // already beaming?
                [notificationCenter postNotificationName:@"COMM_SEND_BEAM_REQ" 
                                                userInfo:[NSNumber numberWithBool:YES]]; // no means down
            }
            break;
        case ACTION_DISTRESS_CALL:
            LLLog(@"GameView.performAction send distress"); 
			[macroHandler sendDistress:DC_GENERIC];
            break;
        case ACTION_ARMIES_CARRIED_REPORT:
            LLLog(@"GameView.performAction send carry report"); 
			[macroHandler sendDistress:DC_CARRYING];
            break;
        case ACTION_MESSAGE:
            //LLLog(@"GameView.performAction MESSAGE not implemented"); 
            // update warning
            [notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:@"A=all, [TFORK]=team, [0..f]=player"];
            inputMode = GV_MESSAGE_MODE;
            // next keystroke gets handled differently and will cause the 
            // destination to be set and may set the focus to input panel.
            break;
        case ACTION_DOCK_PERMISSION:
            if (([me flags] & PLAYER_DOCKOK) == 0) {  // toggle
                [notificationCenter postNotificationName:@"COMM_SEND_DOCK_REQ" 
                                                userInfo:[NSNumber numberWithBool:YES]]; 
            } else {
                [notificationCenter postNotificationName:@"COMM_SEND_DOCK_REQ" 
                                                userInfo:[NSNumber numberWithBool:NO]]; 
            }
            break;
        case ACTION_INFO:
            // convert the mouse pointer to a point in the game grid
            targetGamePoint = [painter gamePointFromViewPoint:[self mousePos] 
                                                     viewRect:[self bounds]
                                        gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                                    withScale:scale];
            // find the nearest player
            target = [universe playerNearPosition:targetGamePoint ofType:(UNIVERSE_TARG_PLAYER | UNIVERSE_TARG_SELF)];
            // find the nearest planet
            planet = [universe planetNearPosition:targetGamePoint];
            // lock on the closest            
            if ([universe entity:target closerToPos:targetGamePoint than:planet]) {
                // toggle info on player
				if (![target isMe]){ // i'm already showing
					[universe resetShowInfoPlayers]; // close any other one
					[target setShowInfo:![target showInfo]];		
				}
            } else {
				[universe resetShowInfoPlanets]; // close any other one
                [planet setShowInfo:![planet showInfo]];
            }
            break;
        case ACTION_REFIT:
            //LLLog(@"GameView.performAction REFIT not implemented"); 
            // update warning
            [notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:@"s=scout, d=destroyer, c=cruiser, b=battleship, a=assault, g=galaxy, o=starbase"];
            inputMode = GV_REFIT_MODE;
            // next keystroke gets handled differently            
            break;
		case ACTION_WAR:
			// convert the mouse pointer to a point in the game grid
            targetGamePoint = [painter gamePointFromViewPoint:[self mousePos] 
                                                     viewRect:[self bounds]
                                        gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                                    withScale:scale];
            // find the nearest planet
            planet = [universe planetNearPosition:targetGamePoint];
			warTeam = [planet owner];
			if ([me team] == warTeam) {
				[notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:@"Civil war not allowed"];
				warTeam = nil;				
			} else if (([warTeam teamId] < TEAM_FED) || ([warTeam teamId] > TEAM_ORI)) {
				[notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:@"No contact with that goverment"];
				warTeam = nil; 
			} else {
				// update warning
				[notificationCenter postNotificationName:@"GV_MODE_INFO" userInfo:[NSString stringWithFormat:@"Declare h=hostile or p=peace on %@", [warTeam abbreviation]]];
				inputMode = GV_WAR_MODE;
				// next keystroke gets handled differently     
			}       
            break;
        case ACTION_REPAIR:
            // $$ no toggle ?
            [notificationCenter postNotificationName:@"COMM_SEND_REPAIR_REQ" 
                                            userInfo:[NSNumber numberWithBool:YES]];
            break;
        case ACTION_QUIT:
            // $$ how do we quit ? send BYE, reset some data and flip to the outfit
            // or go through state machine to main menu...
			// $$ should play self destruct sound too
			[notificationCenter postNotificationName:@"COMM_SEND_QUIT_REQ"];
            break;
        case ACTION_HELP:
			[notificationCenter postNotificationName:@"GV_SHOW_HELP"];
            LLLog(@"GameView.performAction HELP should raise panel"); 
			break;
        case ACTION_DEBUG:
            [painter setDebugLabels:![painter debugLabels]];
            break;
		case ACTION_SCREENSHOT:
			[screenshotController snap];
			break;
		case ACTION_COUP:
			LLLog(@"GameView.performAction sending coup request");
            [notificationCenter postNotificationName:@"COMM_SEND_COUP_REQ" userInfo:nil]; 
            break;
        default:
            LLLog(@"GameView.performAction unknown action %d", action);
            return NO;
            break;
    }
    return YES;
}

@end
