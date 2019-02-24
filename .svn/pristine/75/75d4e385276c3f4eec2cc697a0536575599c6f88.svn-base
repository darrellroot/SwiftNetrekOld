//
//  OutfitMenuController.h
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "Data.h"
#import "PainterFactory.h"


@interface OutfitMenuController : BaseClass {
    
    IBOutlet NSButton *fedButton;
    IBOutlet NSButton *romButton;
    IBOutlet NSButton *kliButton;
    IBOutlet NSButton *oriButton;
    
    IBOutlet NSButton *scButton;
    IBOutlet NSButton *ddButton;
    IBOutlet NSButton *caButton;
    IBOutlet NSButton *bbButton;
    IBOutlet NSButton *asButton;
    IBOutlet NSButton *sbButton;
    
    IBOutlet NSButton *playButton;
    IBOutlet NSLevelIndicator *loginClock;
    
    IBOutlet NSTextField *instructionField; // dummy otherwise IB will not connect messageTextField
    IBOutlet NSTextField *messageTextField; // bug in IB
	
	PainterFactory* painter;
	bool quickConnect;
	bool quickConnecting;
}

// IB
- (IBAction)selectTeam:(id)sender;
- (IBAction)selectShip:(id)sender;
- (IBAction)play:(id)sender;

// controller functions set from GuiManager
- (void) setInstructionField:(NSString *)message;
- (void) setInstructionFieldToDefault;
- (void) setActivePainter:(PainterFactory*)painter;
- (void) setQuickConnect:(bool)yesno;
- (void) findTeam;

@end
