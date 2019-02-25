//
//  GameController.h
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "Data.h"
#import "GameView.h"
#import "MapView.h"
#import "MessagesDataSource.h"
#import "PlayerListDataSource.h"
#import "MTKeyMap.h"
#import "Luky.h"
#import "PlayerListView.h"
#import "MessagesListView.h"
#import "MTVoiceController.h"
#import "MTMouseMap.h"
#import "SwiftNetrek-Swift.h"

// once per second 
#define FRAMES_PER_FULL_UPDATE_DASHBOARD FRAME_RATE

@interface GameController : BaseClass <NSSpeechSynthesizerDelegate> {
   
    // dashboard
    IBOutlet LLBar *shieldBar;  
    IBOutlet LLBar *speedBar;
    IBOutlet LLBar *hullBar;
    IBOutlet LLBar *fuelBar;
    IBOutlet LLBar *torpsBar;
    IBOutlet LLBar *phasersBar;
    IBOutlet LLBar *eTempBar;
    IBOutlet LLBar *wTempBar;
    IBOutlet LLBar *armiesBar;
    IBOutlet NSTextField *shieldValue;
    IBOutlet NSTextField *speedValue;
    IBOutlet NSTextField *hullValue;
    IBOutlet NSTextField *fuelValue;
    IBOutlet NSTextField *eTempValue;
    IBOutlet NSTextField *wTempValue;
    
    // commputer message
    IBOutlet NSTextField *messageTextField;
    NSSpeechSynthesizer* synth;
	MTVoiceController *voiceCntrl;
    bool shouldSpeak;
    
    // players
    //IBOutlet NSTableView      *playerList;
    //IBOutlet PlayerListDataSource *playerListDataSource;
    IBOutlet PlayerListView    *playerList;
    
    // messages
    //IBOutlet NSTableView      *messages;
    //IBOutlet MessagesDataSource *messagesDataSource;
    IBOutlet MessagesListView   *messages;
    
    // game window
    IBOutlet GameView         *gameView;
    IBOutlet MapView          *mapView;
	
	// other
	float frameRate;    
}

- (GameView *)gameView;
- (MapView *)mapView;
- (void) repaint:(float)timeSinceLastDraw;
- (void) startGame;
- (void) stopGame;
- (void) newMessage:(NSString*)message;
- (void) updateDashboard:(Player*) me;
/* FR 1682996 refactor settings
- (void) setDistressKeyMap:(MTKeyMap *)newKeyMap;
- (void) setActionKeyMap:(MTKeyMap *)newKeyMap;
- (void) setMouseMap:(MTMouseMap *)newMouseMap;
*/
- (void) updateBar:(LLBar*) bar andTextValue:(NSTextField*)field 
         withValue:(int)value max:(int)maxValue inverseWarning:(bool)inverse;
- (void) updateBar:(LLBar*) bar andTextValue:(NSTextField*)field 
         withValue:(int)value max:(int)maxValue tempMax:(int)tempMax 
    inverseWarning:(bool)inverse;
- (void) setPainter:(PainterFactory*)newPainter;
- (void) setSpeakComputerMessages:(bool)speak;
- (void) setListenToVoiceCommands:(bool)listen;


@end
