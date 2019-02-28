//
//  Universe.m
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Universe.h"
#import "LLTrigonometry.h"


@implementation Universe

LLTrigonometry *trigonometry;
Universe *defaultInstance;
NSLock *synchronizeAccess;

// performance improvement, keep me
static Player *me;

- (id) init {
    self = [super init];
    if (self != nil) {
        // create helper
        trigonometry = [LLTrigonometry defaultInstance];
		
		SimpleTracker *tracker = [SimpleTracker defaultTracker]; // obtain pointer to default tracker
        
        status    = [[Status alloc] init];
        players   = [[NSMutableArray alloc] init];
        planets   = [[NSMutableArray alloc] init];
        teams     = [[NSMutableArray alloc] init];
        shipTypes = [[NSMutableArray alloc] init];
        phasers   = [[NSMutableArray alloc] init];
        torps     = [[NSMutableArray alloc] init];
        plasmas   = [[NSMutableArray alloc] init];
        me        = nil;
        synchronizeAccess = [[NSLock alloc] init];

        int torpId = 0;
        for (int i = 0; i < UNIVERSE_MAX_PLAYERS; i++) {
             // create players with one phaser and one plasma
            Player* player = [[Player alloc] initWithPlayerId:i]; 
            [players addObject:player];
			// track players
			[tracker registerEntity:player];
            // $$ should add these to the player as well for easy reference
            Phaser *phaser = [[Phaser alloc] init];
            [phaser setOwner:player];
            [phasers addObject:phaser];
            Plasma *plasma = [[Plasma alloc] init];
            [plasma setOwner:player];
            [plasmas addObject:plasma];
            // create torps for player
            NSMutableArray *playerTorps = [[NSMutableArray alloc] init];
            for (int j = 0; j < UNIVERSE_MAX_TORPS; j++) {
                Torp *torp = [[Torp alloc] initWithId:torpId];
                torpId++;
                [torp setOwner:player];                
                // add to general stack
                [torps addObject:torp];
                // and to player
                [playerTorps addObject:torp];
            }
            // add torps to player
            [player setTorps:playerTorps];            
        } 
       
        // and planets
        for (int i = 0; i < UNIVERSE_MAX_PLANETS; i++) {
            [planets addObject:[[Planet alloc] initWithPlanetId:i]];
        }
        // and teams
        for (int i = 0; i < TEAM_MAX; i++) {
            [teams addObject:[[Team alloc] initWithTeamId:i]];
        }
        // and ships
        for (int i = 0; i < SHIP_MAX; i++) {
            [shipTypes addObject:[[Ship alloc] initWithType:i]];
        } 

    }
    return self;
}

+ (Universe*) defaultInstance {
    
    if (defaultInstance == nil) {
        defaultInstance = [[Universe alloc] init];
    }
    return defaultInstance;
}

- (void) resetShowInfoPlanets {
	for (int i = 0; i < UNIVERSE_MAX_PLANETS; i++) {
		[[planets objectAtIndex:i] setShowInfo:NO];
	}
}

- (void) resetShowInfoPlayers {
	for (int i = 0; i < UNIVERSE_MAX_PLAYERS; i++) {
		Player *p = [players objectAtIndex:i];
		if (![p isMe]) {     // except me
			[p setShowInfo:NO];
		}
	}
}

- (int) distanceToEntity:(Entity*)obj1 from:(Entity*)obj2 {
    return [trigonometry hypotOfBase:([obj2 position].x - [obj1 position].x) heigth: ([obj2 position].y - [obj1 position].y)];
}

- (float)angleDegBetweenEntity:(Entity*)obj1 from:(Entity*)obj2  {
    
    return [trigonometry angleDegBetween:[obj1 position] andPoint:[obj2 position]];
}

- (float)angleDegBetween:(NSPoint)p1 andPoint:(NSPoint)p2 {
    
    return [trigonometry angleDegBetween:p1 andPoint:p2];
}


- (bool) entity:(Entity*)obj1 closerToPos:(NSPoint)pos than:(Entity*)obj2 {
    
    int distanceTo1 = [trigonometry hypotOfBase:(pos.x - [obj1 position].x) heigth: (pos.y - [obj1 position].y)];
    int distanceTo2 = [trigonometry hypotOfBase:(pos.x - [obj2 position].x) heigth: (pos.y - [obj2 position].y)];
    
    if (distanceTo1 < distanceTo2) {
        return YES;
    } else {
        return NO;
    }
}

// universal lock, logic must be added by users that have a conflict
// themselfs, eg. a view (painter) and the communications thread
// just lock and unlock on desire.
-(NSLock *)synchronizeAccess {
    return synchronizeAccess;
}

-(int)remappedTeamIdWithId:(int)teamId {
    
    // remapped team id in new protocol?
    switch (teamId) {
    case 1:
        return TEAM_FED;
        break;
    case 2:
        return TEAM_ROM;
        break;
    case 4:
        return TEAM_KLI;
        break;
    case 8:
        return TEAM_ORI;
        break;
    default:
        return TEAM_IND;
        break;
    }
}

-(Rank *) rankWithId:(int)rankId {
    // take any player
    Player *player = [players objectAtIndex:0];
    // get his stats
    PlayerStats *stats = [player stats];
    // get the rank
    return [stats rankWithId:rankId];
}

- (bool) entity:(Entity*)obj1 closerToPlayer:(Player*)player than:(Entity*)obj2 {
    return [self entity:obj1 closerToPos: [player position] than:obj2];
}

- (bool) entity:(Entity*)obj1 closerToMeThan:(Entity*)obj2 {
    return [self entity:obj1 closerToPlayer: [self playerThatIsMe] than:obj2];
}

- (Planet *) planetNearPosition:(NSPoint) pos {
          
    // start with the first one
    Planet *closest = [planets objectAtIndex:0];
    Planet *planet = nil;
    
    // check if the others are closer
    for(int p = 1; p < [planets count]; p++) {
        planet = [planets objectAtIndex:p];
        
        if ([self entity:planet closerToPos:pos than:closest]) {
            closest = planet;
        }
    }

    return closest;
}
    
- (Player *) playerNearPosition:(NSPoint) pos ofType:(int) target_type {
    
    if((target_type & (UNIVERSE_TARG_PLAYER | UNIVERSE_TARG_FRIEND | UNIVERSE_TARG_ENEMY | UNIVERSE_TARG_BASE)) != 0) {
        bool friendly;
        Player *player;
        Player *closest = nil;
        for(int p = 0; p < [players count]; p++) {
            player = [players objectAtIndex:p];
            if([player status] != PLAYER_ALIVE) {
                continue;
            }
            if(([player flags] & PLAYER_CLOAK) != 0 && (target_type & UNIVERSE_TARG_CLOAK) == 0) {
                continue;
            }
            if([player isMe] && (target_type & UNIVERSE_TARG_SELF) == 0) {
                continue;
            }
            if((target_type & UNIVERSE_TARG_BASE) != 0 && [[player ship] type] != SHIP_SB) {
                continue;
            }
            // friendly to me?
            friendly = [player friendlyToPlayer:[self playerThatIsMe]];
            if (friendly && (target_type & UNIVERSE_TARG_ENEMY) != 0) {
                continue;
            }
            if (!friendly && (target_type & UNIVERSE_TARG_FRIEND) != 0) {
                continue;
            }
            
            if (closest == nil) {
                // first one
                closest = player;
            } else {
                if ([self entity:player closerToPos:pos than:closest]) {
                    closest = player;
                }  
            }

        }
        return closest;
    }
    return nil;
    
}

- (Player *) playerNearPlayer:(Player *) player ofType:(int) type {
    return [self playerNearPosition:[player position] ofType: type];
}

- (Player *) playerNearMeOfType:(int) type {
    return [self playerNearPlayer:[self playerThatIsMe] ofType:type];
}

- (Planet *) planetNearPlayer:(Player *) player {
    return [self planetNearPosition:[player position]];
}

- (Planet *) planetNearMe {
    return [self planetNearPlayer:[self playerThatIsMe]];
}

- (Planet *) planetWithId:(int)planetId {
    if (planetId > [planets count]) {
		LLLog([NSString stringWithFormat: @"Universe.planetWithId: %d", planetId]);
		return nil;
	}
    return [planets objectAtIndex:planetId];
}

- (Player *) playerWithId:(int)playerId {
	if (playerId > [players count]) {
		LLLog([NSString stringWithFormat: @"Universe.playerWithId: %d outside index", playerId]);
		return nil;
	}
    return [players objectAtIndex:playerId];
}

- (Player *) playerThatIsMe {
    
    // check if i still exist
    if ((me != nil) && ([me isMe])) {
        return me;
    }
    
    for (int i = 0; i < [players count]; i++) {
        if ([[players objectAtIndex:i] isMe]) {
            me = [players objectAtIndex:i];
            return me;
        }
    }
    return nil;
}

- (int)      playerCount {
    return [players count];
}

- (Ship *)   shipOfType:(int)shipType {
    return [shipTypes objectAtIndex:shipType];
}

- (Ship *)   shipWithPhaserId:(int)phaserId {
	if (phaserId > [players count]) {
		return nil;
	}
    // we store phasers with the same index as players
    // as each player has only one ship and each ship
    // has only one phaser
    return [[players objectAtIndex:phaserId] ship];
}

- (Team *)   teamWithId:(int)teamId {
    return [teams objectAtIndex:teamId];
}

- (Status *) status {
    return status;
}

- (Torp *)   torpWithId:(int)torpId {
	if (torpId > [torps count]) {
		return nil;
	}
    return [torps objectAtIndex:torpId];
}

- (Phaser *) phaserWithId:(int)phaserId {
	if (phaserId > [phasers count]) {
		return nil;
	}
    return [phasers objectAtIndex:phaserId];
}

- (Plasma *) plasmaWithId:(int)plasmaId {
	if (plasmaId > [plasmas count]) {
		return nil;
	}
    return [plasmas objectAtIndex:plasmaId];
}

- (void)     movePlayer:(Player *)player toTeam: (Team *)targetTeam {
    for (int i = 0; i < [teams count]; i++) {
        Team *team = [teams objectAtIndex:i];
        if (team == targetTeam) {
            [team addPlayer:player];
        } else {
            [team removePlayer:player];
        }
    }
}

- (void)     movePlanet:(Planet *)planet toTeam: (Team *)targetTeam{
    //LLLog([NSString stringWithFormat: @"Universe.movePlanet %@ to team %@", [planet name], [targetTeam abbreviation]]);
    for (int i = 0; i < [teams count]; i++) {
        Team *team = [teams objectAtIndex:i];
        if (team == targetTeam) {
            [team addPlanet:planet];
        } else {
            [team removePlanet:planet];
        }
    } 
    [planet setOwner:targetTeam];
}

// private function
- (void)     setAllWeapons:(NSArray*) weapons toStatus:(int) newStatus {
    for (int i = 0; i < [weapons count]; i++) {
        [[weapons objectAtIndex:i] setStatus:newStatus];
    } 
}

- (void)     setAllTorpsStatus:(int) newStatus {
	[self setAllWeapons:torps toStatus:newStatus];
    for(int p = 0; p < [players count]; ++p) {
        [[players objectAtIndex:p] setTorps:0];
	}
}

- (void)     setAllPlasmasStatus:(int) newStatus {
	   [self setAllWeapons:plasmas toStatus:newStatus];
    for(int p = 0; p < [players count]; ++p) {
        [[players objectAtIndex:p] setPlasmaCount:0];
	}
}

- (void)     setAllPhasersStatus:(int) newStatus {
	   [self setAllWeapons:phasers toStatus:newStatus];
}

- (void)     resetWeaponInfo {
    [self setAllTorpsStatus:TORP_FREE];
    [self setAllPlasmasStatus:PLASMA_FREE];
    [self setAllPhasersStatus:PHASER_FREE];
}

@end
