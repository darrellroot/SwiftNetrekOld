//
//  Team.m
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Team.h"


@implementation Team

- (id) init {
    self = [super init];
    if (self != nil) {
        players = [[NSMutableArray alloc] init]; 
        planets = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id) initWithTeamId:(int)team {
    self = [self init];
    if (self != nil) {

        teamId = team;  
        switch (teamId) {
            case TEAM_IND:
                abbrev = [NSString stringWithString:@"Ind"];
                break;
            case TEAM_FED:
                abbrev = [NSString stringWithString:@"Fed"];
                break;
            case TEAM_KLI:
                abbrev = [NSString stringWithString:@"Kli"];
                break;
            case TEAM_ROM:
                abbrev = [NSString stringWithString:@"Rom"];
                break;
            case TEAM_ORI:
                abbrev = [NSString stringWithString:@"Ori"];
                break;
            default:
                abbrev = [NSString stringWithString:@"???"];
                break;
        }
        [abbrev retain];
        
    }
    return self;
}

-(int) bitMask {
    switch (teamId) {
        case TEAM_IND:
            return 0x0;
            break;
        case TEAM_FED:
            return 0x1;
            break;
        case TEAM_KLI:
            return 0x4;
            break;
        case TEAM_ROM:
            return 0x2;
            break;
        case TEAM_ORI:
            return 0x8;
            break;
        default:
            return 0x0;
            break;
    }
}

-(NSColor*) colorForTeam {
    switch (teamId) {
        case TEAM_IND:
            return [NSColor whiteColor];
            break;
        case TEAM_FED:
            return [NSColor yellowColor];
            break;
        case TEAM_KLI:
            return [NSColor greenColor];
            break;
        case TEAM_ROM:
            return [NSColor redColor];
            break;
        case TEAM_ORI:
            return [NSColor cyanColor];
            break;
        default:
            //return [NSColor orangeColor];
            return [NSColor whiteColor]; // use IND
            break;
    }
}

-(char)letterForTeam {
    switch (teamId) {
    case TEAM_IND:
        return 'I';
        break;
    case TEAM_FED:
        return 'F';
        break;
    case TEAM_KLI:
        return 'K';
        break;
    case TEAM_ROM:
        return 'R';
        break;
    case TEAM_ORI:
        return 'O';
        break;
    default:
        return '?';
        break;
    }
}

-(char) letterForPlayer:(int)i {
    
    char letters[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    return letters[i];
}

-(NSString *)mapCharsForPlayerWithId:(int)playerId {
    return [NSString stringWithFormat:@"%c%c", [self letterForTeam], [self letterForPlayer:playerId]];
}

-(void) addPlanet:(Planet *)planet {
    if (![planets containsObject:planet]) {
        [planets addObject:planet];
    }
}

-(NSString *)abbreviation {
    return abbrev;
}

-(void) removePlanet:(Planet*)planet {
    [planets removeObject:planet];
}

-(void) addPlayer:(Player *)player {
    if (![players containsObject:player]) {
        [players addObject:player];
    }
}

-(int)  teamId {
    return teamId;
}

-(void) removePlayer:(Player*)player {
    [players removeObject:player];
}

-(int)  count {
    int activePlayers = 0;
    for (int i = 0; i < [players count]; i++) {
        if ([[players objectAtIndex:i] status] == PLAYER_ALIVE) {
            activePlayers++;
        }
    }
    return activePlayers;
}

@end
