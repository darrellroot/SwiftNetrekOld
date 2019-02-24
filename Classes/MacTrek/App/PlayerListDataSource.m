//
//  PlayerListDataSource.m
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PlayerListDataSource.h"


@implementation PlayerListDataSource


- (id) init {
    self = [super init];
    if (self != nil) {
        universe = nil;
        players = [[NSMutableArray alloc] init];
        universe = [Universe defaultInstance];
        [self refreshData];
    }
    return self;
}

- (void) awakeFromNib {
	// make sure we refresh when player info becomes available
    [notificationCenter addObserver:self selector:@selector(refreshData) name:@"SP_PLAYER_INFO" 
                             object:nil useLocks:NO useMainRunLoop:YES]; 
	
	// and clean up when we enter a game
	// to remove old players
	[notificationCenter addObserver:self selector:@selector(refreshData) name:@"GM_GAME_ENTERED" 
                             object:nil useLocks:NO useMainRunLoop:YES]; 
    
    // set up the toField
    [toField removeAllItems];
    [toField addItemWithTitle:@"ALL"];
    [toField addItemWithTitle:@"FED"];
    [toField addItemWithTitle:@"KLI"];
    [toField addItemWithTitle:@"ORI"];
    [toField addItemWithTitle:@"ROM"];
    [toField addItemWithTitle:@"GOD"];
    [toField selectItemWithTitle:@"ALL"];
}

// tie this to events that change players
- (void) refreshData {
    
    // clean up
    //[players removeAllObjects];
    
    // test for new
    if (universe == nil) {        
        return;
    }
    
    bool changed = NO;
    
    // find players
    for (int i = 0; i < UNIVERSE_MAX_PLAYERS; i++) {
        Player *player = [universe playerWithId:i];
        if ([player status] != PLAYER_FREE) {
            if (![players containsObject:player]) {
                [players addObject:player];
                changed = YES;
                [toField addItemWithTitle:[player mapChars]];
            } else { // player == FREE
                if ([players containsObject: player]) {
                    [players removeObject:player];
                    changed = YES;
                    [toField removeItemWithTitle:[player mapChars]];
                }
            }                       
        }        
    } 
    
    // show it
    if (changed) {
        // refresh the player list
        // (it will come and ask for data)
        [playerList reloadData];  
    } else {
        LLLog(@"PlayerListDataSource.refresh skipping, no change detected");
    }

}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [players count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {
    // get the player
    Player *player = [players objectAtIndex:rowIndex];
    
    if ([[aTableColumn identifier] isEqualToString:@"id"]) {
        return [player mapChars];        
    } else { // must be name
        return [player longName];
    }    
}

@end
