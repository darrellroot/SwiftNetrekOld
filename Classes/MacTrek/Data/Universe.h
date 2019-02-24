//
//  Universe.h
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Data.h"
#import "SimpleBaseClass.h"
#import "SimpleTracker.h"

#define UNIVERSE_SCALE  40
#define UNIVERSE_MAX_PLANETS  40
// vanilla seems to send 32 players and not 16?
//#define UNIVERSE_MAX_PLAYERS  20
#define UNIVERSE_MAX_PLAYERS  32
#define UNIVERSE_MAX_TORPS  8

#define UNIVERSE_PIXEL_SIZE      100000
#define UNIVERSE_HALF_PIXEL_SIZE  (PIXEL_SIZE / 2)

#define UNIVERSE_TARG_PLAYER	 0x01
#define UNIVERSE_TARG_PLANET	 0x02
#define UNIVERSE_TARG_CLOAK      0x04
#define UNIVERSE_TARG_SELF       0x08
#define UNIVERSE_TARG_ENEMY      0x10
#define UNIVERSE_TARG_FRIEND	 0x20
#define UNIVERSE_TARG_BASE       0x40

@interface Universe : SimpleBaseClass {
    NSMutableArray *players;
    NSMutableArray *teams;
    NSMutableArray *shipTypes;  
    NSMutableArray *torps;
    NSMutableArray *plasmas;
    NSMutableArray *phasers;
    NSMutableArray *planets;
    Status *status;
}

+ (Universe*) defaultInstance;

- (void) resetShowInfoPlanets;
- (void) resetShowInfoPlayers;
- (NSLock *)synchronizeAccess;
- (int)remappedTeamIdWithId:(int)teamId;
- (Rank *) rankWithId:(int)rankId;
- (bool) entity:(Entity*)obj1 closerToPos:(NSPoint)pos than:(Entity*)obj2;
- (bool) entity:(Entity*)obj1 closerToPlayer:(Player*)player than:(Entity*)obj2;
- (bool) entity:(Entity*)obj1 closerToMeThan:(Entity*)obj2; 
- (int) distanceToEntity:(Entity*)obj1 from:(Entity*)obj2;
- (float)angleDegBetween:(NSPoint)p1 andPoint:(NSPoint)p2;
- (float)angleDegBetweenEntity:(Entity*)obj1 from:(Entity*)obj2;
- (Planet *) planetNearPosition:(NSPoint) pos;
- (Planet *) planetNearPlayer:(Player *) player;
- (Planet *) planetNearMe;
- (Player *) playerNearPosition:(NSPoint) pos ofType:(int) type;
- (Player *) playerNearPlayer:(Player *) player ofType:(int) type;
- (Player *) playerNearMeOfType:(int) type;
- (Player *) playerWithId:(int)playerId;
- (int)      playerCount;
- (Player *) playerThatIsMe;
- (Planet *) planetWithId:(int)planetId;
- (Ship *)   shipOfType:(int)shipType;
- (Ship *)   shipWithPhaserId:(int)phaserId;
- (Status *) status;
- (Team *)   teamWithId:(int)teamId;
- (Torp *)   torpWithId:(int)torpId;
- (Plasma *) plasmaWithId:(int)plasmaId;
- (Phaser *) phaserWithId:(int)phaserId;
- (void)     movePlayer:(Player *)player toTeam: (Team *)team;
- (void)     movePlanet:(Planet *)planet toTeam: (Team *)team;
- (void)     setAllTorpsStatus:(int) newStatus;
- (void)     setAllPlasmasStatus:(int) newStatus;
- (void)     setAllPhasersStatus:(int) newStatus;
- (void)     resetWeaponInfo;


@end
