//
//  Team.h
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>

@class Player;
@class Planet;

#import "Player.h"
#import "Planet.h"
#import "SimpleBaseClass.h"

#define TEAM_NOBODY  0
#define TEAM_IND     0
#define TEAM_FIRST   1
#define TEAM_FED     1
#define TEAM_ROM     2
#define TEAM_KLI     3
#define TEAM_ORI     4  
#define TEAM_MAX     5

@interface Team : SimpleBaseClass {
    NSMutableArray *players; 
    NSMutableArray *planets;
    int teamId;    
    NSString *abbrev;
}

-(int) bitMask;
- (id) initWithTeamId:(int)team;
-(NSString *)mapCharsForPlayerWithId:(int)playerId;
-(void) addPlayer:(Player *)player;
-(void) removePlayer:(Player*)player;
-(void) addPlanet:(Planet *)planet;
-(void) removePlanet:(Planet*)planet;
-(NSString *)abbreviation;
-(int)  teamId;
-(int)  count;
-(char) letterForPlayer:(int)i;
- (NSColor *) colorForTeam;
-(char)letterForTeam;

@end
