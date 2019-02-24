//
//  OutfitMenuController.m
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "OutfitMenuController.h"


@implementation OutfitMenuController

char teamMask = 0xFF;

// this we should not do, let the user make a choice (esp. when FED is blocked) $$
// thus start empty and disable the play button
char myTeam = TEAM_FED;
char myship = SHIP_CA;

- (id) init {
    self = [super init];
    if (self != nil) {
        // the server will send SP_MASK to tell us in which team we are welcome
        [notificationCenter addObserver:self selector:@selector(handleTeamMask:) name:@"SP_MASK" object:nil];
		quickConnect = NO;
		quickConnecting = NO;
		painter = nil;
    }
    return self;
}

- (void) awakeFromNib { 
    LLLog(@"OutfitMenuController.awakeFromNib reached");
}

- (void) setQuickConnect:(bool)yesno {
	quickConnect = yesno;
}

- (void) redrawButton:(NSButton*)but withShip:(int)shiptType{
	// get general size
	NSSize imageSize = [[but image] size];
	//NSSize imageSize = [but frame].size;
	NSRect imageRect;
	imageRect.size = imageSize;
	imageRect.origin = NSZeroPoint;	
	
	// the actual drawing    
	NSImage *img = [[[NSImage alloc] initWithSize:imageSize] autorelease];
	[img setFlipped:YES];
	[img lockFocus];
	[painter drawShipType:shiptType forTeamId:myTeam withCloakPhase:0 inRect:imageRect];
	[img unlockFocus];
	[but setImage:img];
	[but setNeedsDisplay:YES];
}

- (void) redrawButtonImages {
	
	[self redrawButton:scButton withShip:SHIP_SC];
	[self redrawButton:ddButton withShip:SHIP_DD];
	[self redrawButton:caButton withShip:SHIP_CA];
	[self redrawButton:bbButton withShip:SHIP_BB];
	[self redrawButton:asButton withShip:SHIP_AS];
	[self redrawButton:sbButton withShip:SHIP_SB];
}

-(NSButton *) buttonForTeam:(int) teamId {
	
	switch (teamId) {
		case TEAM_FED:
			return fedButton;
			break;
		case TEAM_KLI:
			return kliButton;
			break;
		case TEAM_ORI:
			return oriButton;
			break;
		case TEAM_ROM:
			return romButton;
			break;
		default:
			return nil;
			break;
	}
}

- (bool) freeSeatOnTeam:(int)teamId {
	return [[self buttonForTeam:teamId] isEnabled];	
}

- (void) findTeam {
	if ([self freeSeatOnTeam:myTeam]) {
		if (quickConnect) {
			// continue
			quickConnect = NO;
			quickConnecting = YES; // keep state since it may go wrong
			LLLog(@"OutfitMenuController.findTeam quick connecting with selected team");
			[self play:self];
			return;
		}
		if (quickConnecting) {  // initial quick connect must have failed, but a handleTeamMask brought us here
			quickConnecting = NO;  // can't go wrong now
			LLLog(@"OutfitMenuController.findTeam quick connecting with selected team attempt 2");
			[self play:self];			
			return;
		}
		return; // no need
	}
	
	int newTeam = myTeam;
	// check if myTeam is enabled, if not find next team that is
	for (int i=TEAM_FIRST; i < TEAM_MAX; i++) {
		if (![self freeSeatOnTeam:newTeam]) {
			newTeam++; // increase
			newTeam %= TEAM_MAX; // rollover
		}
	}
	
	if ([self freeSeatOnTeam:newTeam]) {  // found one
		LLLog(@"OutfitMenuController.findTeam moved from team %d to %d", myTeam, newTeam);
		[self selectTeam:[self buttonForTeam:newTeam]];
		if (quickConnect) {
			// continue
			quickConnect = NO;
			quickConnecting = YES;
			LLLog(@"OutfitMenuController.findTeam quick connecting after team move");
			[self play:self];
			return;
		}
		if (quickConnecting) {  // initial quick connect must have failed, but a handleTeamMask brought us here
			quickConnecting = NO;  // can't go wrong now
			LLLog(@"OutfitMenuController.findTeam quick connecting after team move attempt 2");
			[self play:self];
			return;
		}
	} else {
		LLLog(@"OutfitMenuController.findTeam NO free team, might as well go home");
		[self setInstructionField:@"NO free team, better try different server"];
	}
}

- (void) handleTeamMask:(NSNumber *) mask{
    
    char newTeamMask = [mask charValue];
    if (newTeamMask != teamMask) {
        
        // $$ hmm teamMask seems to shifted, Kli becomes Rom etc..
        
        // store the mask
        teamMask = newTeamMask;
        
        // check
        if (universe == nil) {
            LLLog(@"OutfitMenuController.handleTeamMask NO ! my universe is too small");
            return;
        }
        
        // enable or disable buttons
        Team *team;
        bool open;       
        
        team = [universe teamWithId:TEAM_FED];
        open = (([team bitMask] & teamMask) != 0);
        [fedButton setEnabled:open];        
        [fedButton setTitle:[NSString stringWithFormat:@"%d\nFederation", [team count]]];
		
        team = [universe teamWithId:TEAM_KLI];
        open = (([team bitMask] & teamMask) != 0);
        [kliButton setEnabled:open];
        [kliButton setTitle:[NSString stringWithFormat:@"%d\nKlingon", [team count]]];
        
        team = [universe teamWithId:TEAM_ORI];
        open = (([team bitMask] & teamMask) != 0);
        [oriButton setEnabled:open];
        [oriButton setTitle:[NSString stringWithFormat:@"%d\nOrion", [team count]]];
        
        team = [universe teamWithId:TEAM_ROM];
        open = (([team bitMask] & teamMask) != 0);
        [romButton setEnabled:open];       
        [romButton setTitle:[NSString stringWithFormat:@"%d\nRomulan", [team count]]];
		
		[self findTeam];
    }    
}

- (IBAction)selectTeam:(id)sender {

    // check if the player is really selecting
    // or deselecting
    if ([sender state] == NSOffState) {
        // no way
        [sender setState:NSOnState];
    }
    
    // deselect all other buttons
    // and set the selected team
    if (sender != fedButton) {
        [fedButton setState: NSOffState];
    } else {
        myTeam = TEAM_FED;
    }
    if (sender != romButton) {
        [romButton setState: NSOffState];
    } else {
        myTeam = TEAM_ROM;
    }
    if (sender != kliButton) {
        [kliButton setState: NSOffState];
    } else {
        myTeam = TEAM_KLI;
    }
    if (sender != oriButton) {
        [oriButton setState: NSOffState];
    } else {
        myTeam = TEAM_ORI;
    }
	[self redrawButtonImages];
}

- (IBAction)selectShip:(id)sender {
    // deselect all other buttons
    // and set the selected ship
    if (sender != scButton) {
        [scButton setState: NSOffState];
    } else {
        myship = SHIP_SC;
    }    
    if (sender != ddButton) {
        [ddButton setState: NSOffState];
    } else {
        myship = SHIP_DD;
    }    
    if (sender != caButton) {
        [caButton setState: NSOffState];
    } else {
        myship = SHIP_CA;
    }    
    if (sender != bbButton) {
        [bbButton setState: NSOffState];
    } else {
        myship = SHIP_BB;
    }    
    if (sender != asButton) {
        [asButton setState: NSOffState];
    } else {
        myship = SHIP_AS;
    }    
    if (sender != sbButton) {
        [sbButton setState: NSOffState];
    } else {
        myship = SHIP_SB;
    }  
}

- (IBAction)play:(id)sender {
    
    // ask if this is a valid team for me
    // note: team is minus one $$
    [notificationCenter postNotificationName:@"COMM_SEND_TEAM_REQ" 
                                      object:nil 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys: 
                                        [NSNumber numberWithChar:(myTeam - 1)] , @"team",
                                        [NSNumber numberWithChar:myship] , @"ship", 
                                        nil]];
    
    // server responds with SP_PICKOK
    // or SP_PICKNOK the latter should deselect all choices
    // $$ check outfit
}

- (void) setInstructionFieldToDefault {
    [self setInstructionField:@"-"];
}

- (void) setInstructionField:(NSString *)message {
    
    if (messageTextField == nil) { // very strange, we get called by nibInstantiate asm code before we awoke..
        return;
    }
    
	if ([message isKindOfClass:[NSString class]] == NO) { // very strange, we get called by nibInstantiate asm code but not with a string...
        return;
    }
	
    if ([[messageTextField stringValue] isEqualToString:message]) {
        return; // no need to update
    }
    [messageTextField setStringValue:message]; 
}

- (void) setActivePainter:(PainterFactory*)newPainter {
	// we use this painter to repaint our buttons when needed
	painter = newPainter;
	[self redrawButtonImages];
}

@end
