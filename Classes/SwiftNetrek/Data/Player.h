//
//  Player.h
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

@class Team;
@class Entity;

#import <Cocoa/Cocoa.h>
#import "Ship.h"
#import "Team.h"
#import "PlayerStats.h"
#import "Entity.h"


#define PLAYER_FREE     0 
#define PLAYER_OUTFIT   1 
#define PLAYER_ALIVE    2 
#define PLAYER_EXPLODE  3 
#define PLAYER_DEAD     4 

#define PLAYER_MAX_NR_OF_PLAYERS 16

#define PLAYER_SHIELD      0x00000001 
#define PLAYER_REPAIR      0x00000002 
#define PLAYER_BOMB        0x00000004 
#define PLAYER_ORBIT       0x00000008 
#define PLAYER_CLOAK       0x00000010 
#define PLAYER_WEP         0x00000020 
#define PLAYER_ENG         0x00000040 
#define PLAYER_ROBOT       0x00000080 
#define PLAYER_BEAMUP      0x00000100 
#define PLAYER_BEAMDOWN    0x00000200 
#define PLAYER_SELFDEST    0x00000400 
#define PLAYER_GREEN       0x00000800 
#define PLAYER_YELLOW      0x00001000 
#define PLAYER_RED         0x00002000 
#define PLAYER_PLOCK       0x00004000 			// Locked on a player
#define PLAYER_PLLOCK      0x00008000 		// Locked on a planet
#define PLAYER_COPILOT     0x00010000 		// Allow copilots
#define PLAYER_WAR         0x00020000 			// computer reprogramming for war
#define PLAYER_PRACTR      0x00040000 		// practice type robot (no kills)
#define PLAYER_DOCK        0x00080000 			// true if docked to a starbase
#define PLAYER_REFIT       0x00100000 			// true if about to refit
#define PLAYER_REFITTING   0x00200000 		// true if currently refitting
#define PLAYER_TRACT       0x00400000 			// tractor beam activated
#define PLAYER_PRESS       0x00800000 			// pressor beam activated
#define PLAYER_DOCKOK      0x01000000 		// docking permission
#define PLAYER_OBSERV      0x8000000 			// observer
#define PLAYER_CLOAK_PHASES   16 

@interface Player : Entity {
    int playerId;
    Ship *ship;
    Team *team;
    NSMutableArray *torps;                      // my torps
    PlayerStats *stats;                         // player statistics
    NSString *mapChars;
    int previousStatus;                         // State information used for the last update
    int status;									// Player status
    int previousFlags;
	int flags;									// Player flags
	NSString *name;
	NSString *login;
	NSString *monitor;  						// Monitor being played on    

	int damage;									// Current damage
	int shield;									// Current shield power
	int cloakphase;								// Drawing stage of cloaking engage/disengage.
	int ntorp;									// Number of torps flying
	int nplasmatorp;							// Number of plasma torps active
	int hostile;								// Who my torps will hurt
	int swar;									// Who am I at sticky war with
	int kills;								// Enemies killed
	Planet *planet;           					// Planet orbiting or locked onto
	id playerLock;								// Player locked onto
	int armies;									// Number of armies carried
	int fuel;									// Amount of fuel
	int explode;								// Keeps track of final explosion
	int etemp;									// Engine Temperature
	int wtemp;									// Weapon Temperature
	int whydead;								// Tells you why you died
	int whodead;								// Tells you who killed you
	id  tractor;	    						// What player is in tractor lock
    
	bool me;
}

- (id) initWithPlayerId:(int)player;

- (Planet*) planetLock;
- (void) setPlanetLock:(Planet *)planetInLock;
- (id) playerLock;
- (void) setPlayerLock:(id) playerInLock;
- (int)  previousStatus;
- (void) setPreviousStatus:(int) status;
- (int)  previousFlags;
- (void) setPreviousFlags:(int) flags;
- (NSString *) mapChars;
- (NSString *) statusString;
- (bool)isMe;
- (int) status;
- (int) flags;
- (int) playerId;
- (int) damage;
- (int) kills;
- (int) phaserId;
- (int) plasmaId;
- (int) hostile;
- (int) armies;
- (int) maxArmiesForKills;
- (Player *) tractorTarget;
- (int) stickyWar;
- (Team*)team;
- (Ship*)ship;
- (PlayerStats *) stats;
- (int)wins;
- (int)losses;
- (int) maxSpeed;
- (int) shield;
- (int)maxKills;
- (NSString*)mapCharsWithKillIndicator;
- (NSString*)nameWithRank;
- (NSString*)nameWithRankAndKillIndicator;
- (NSString*)nameWithRankAndKillIndicatorAndShipType;
- (NSString*)longNameWithKillIndicator;
- (NSString*)longName;
- (NSString*)name;
- (NSMutableArray*) torps;
- (int) hull;
- (int) fuel;
- (int) speed;
- (int) engineTemp;
- (int) weaponTemp;
- (int) maxArmies;
- (int) maxTorps;
- (int) maxPhaserShots;
- (int) availableTorps;
- (int) availablePhaserShots;
- (void) setShip:(Ship *)ship;
- (void) setKills:(int)kill;
- (void) setTeam:(Team *)team;
- (void) setFlags:(int)newFlags;
- (void) setStickyWar:(int)newSWar;
- (void) setHostile:(int)newhostile;
- (void) setName:(NSString*)name;
- (void) setLogin:(NSString*)login;
- (void) setMonitor:(NSString*)monitor;
- (void) setStatus:(int)newStatus;
- (void) setExplode:(int)newExplode;
- (void) setTorps:(NSMutableArray*) newTorps;
- (void) setPlasmaCount:(int)nrOfPlasmas;
- (void) setTorpCount:(int)nrOfTorps;
- (void) setIsMe:(bool)newMe;
- (void) setTractorTarget:(Player *)new;

- (int)  cloakPhase;
- (void) increaseCloakPhase;
- (void) decreaseCloakPhase;
- (void) increaseTorpCount;
- (void) decreaseTorpCount;
- (void) increasePlasmaCount;
- (void) decreasePlasmaCount;
- (bool) friendlyToPlayer:(Player*) player;
- (char) letterForPlayer;


- (void) updateHostile: (int) newhostile
            stickyWar: (int) newSWar
               armies: (int) newArmies
                flags: (int) newFlags
               damage: (int) newDamage
       shieldStrenght: (int) newShield
                 fuel: (int) newFuel
           engineTemp: (int) newETemp
          weaponsTemp: (int) newWTemp
              whyDead: (int) newWhyDead
          whoKilledMe: (int) newWhoDead
             thisIsMe: (bool) newIsMe;

- (void) updateHostile: (int) newhostile
             stickyWar: (int) newSWar
                armies: (int) newArmies
                 flags: (int) newFlags
               whyDead: (int) newWhyDead
           whoKilledMe: (int) newWhoDead
              thisIsMe: (bool) newIsMe;

- (void) updateDamage: (int) newDamage
        shieldStrenght: (int) newShield
                  fuel: (int) newFuel
            engineTemp: (int) newETemp
           weaponsTemp: (int) newWTemp
              thisIsMe: (bool) newIsMe;


@end
