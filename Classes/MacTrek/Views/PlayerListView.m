//
//  PlayerListView.m
//  MacTrek
//
//  Created by Aqua on 01/08/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PlayerListView.h"


@implementation PlayerListView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    universe = [Universe defaultInstance];
    players = [[NSMutableArray alloc] init];
    
    [notificationCenter addObserver:self selector:@selector(refreshData) name:@"SP_PLAYER_INFO" 
                             object:nil useLocks:NO useMainRunLoop:YES];  
    [self setNrOfColumns:2];
    
    // user clicked on message list, disable our selection
    [notificationCenter addObserver:self selector:@selector(disableSelection) name:@"MV_MESSAGE_SELECTION"];
    // user manually choose a destination, disable our selection
    // $$$ [notificationCenter addObserver:self selector:@selector(disableSelection) name:@""];
}

- (void) addPlayer:(Player*)player {
    
    int column = 0;
    
    switch ([[player team] teamId]) {

        case TEAM_FED:
        case TEAM_KLI:
            column = 0;
            break;
        case TEAM_ROM:
        case TEAM_ORI:
        case TEAM_IND:
            column = 1;
            break;
        default:
            LLLog(@"PlayerListView.addPlayer illigal team");
            return;
            break;
    }
   // LLLog(@"PlayerListView.addPlayer [%@] to column %d", [player nameWithRank], column);
    [self addString:[player nameWithRankAndKillIndicatorAndShipType] withColor:[[player team] colorForTeam] toColumn:column];
}

- (void) removePlayer:(Player*)player {
    
    int column = 0;
    
    switch ([[player team] teamId]) {
        
        case TEAM_FED:
        case TEAM_KLI:
            column = 0;
            break;
        case TEAM_ROM:
        case TEAM_ORI:
        case TEAM_IND:
            column = 1;
            break;
        default:
            LLLog(@"PlayerListView.removePlayer illigal team");
            return;
            break;
    }
  //  LLLog(@"PlayerListView.removePlayer [%@] from column %d", [player nameWithRank], column);
    [self removeString:[player nameWithRankAndKillIndicatorAndShipType] fromColumn:column];
}

// tie this to events that change players
- (void) refreshData {
    
    // clean up
    [self emptyAllColumns];
    
    // find players
    for (int i = 0; i < UNIVERSE_MAX_PLAYERS; i++) {
        Player *player = [universe playerWithId:i];
        if ([player status] != PLAYER_FREE) {
            [self addPlayer:player];                  
        }        
    } 
    
    hasChanged = YES;   // $$ could be heavy, since we change all the time
}

- (void) newStringSelected:(NSString*)str { 
    [notificationCenter postNotificationName:@"PV_PLAYER_SELECTION" object:self userInfo:str];
}


@end
