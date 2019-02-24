//
//  Player.m
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 __MyCompanyName__. See Licence.txt for licence details.
//

#import "Player.h"


@implementation Player

- (id) init {
    self = [super init];
    if (self != nil) {
        status = PLAYER_FREE;
        previousStatus = PLAYER_FREE;
        previousFlags = 0;
        playerId = -1;
        team = nil;
        ship = nil;
        mapChars = nil;
        name = nil;
        position.x = -1000;
        position.y = -1000;
        me = NO;
        name = @"??";
        login = @"??";
        monitor = @"??";
        stats = [[PlayerStats alloc] init];
        dir = 0;									// Real direction
        speed = 0;									// Real speed
        damage = 0;									// Current damage
        shield = 0;									// Current shield power
        cloakphase = 0;								// Drawing stage of cloaking engage/disengage.
        ntorp = 0;									// Number of torps flying
        nplasmatorp = 0;							// Number of plasma torps active
        hostile = 0;								// Who my torps will hurt
        swar = 0;									// Who am I at sticky war with
        kills = 0;                                  // Enemies killed
        planet = nil;             					// Planet orbiting or locked onto
        playerLock = nil;							// Player locked onto
        armies = 0;									// Number of armies carried
        fuel = 0;									// Amount of fuel
        explode = 0;								// Keeps track of final explosion
        etemp = 0;									// Engine Temperature
        wtemp = 0;									// Weapon Temperature
        whydead = 0;								// Tells you why you died
        whodead = 0;								// Tells you who killed you
        tractor = nil;								// What player is in tractor lock
    }
    return self;
}

- (NSString*) ident {
	return mapChars;
}

- (id) initWithPlayerId:(int)player {
    self = [self init];
    if (self != nil) {
        playerId = player;
    }
    return self;
}

- (Planet*) planetLock {
    return planet;
}

- (NSString *) statusString {
    switch (status) {
    case PLAYER_FREE:
        return @"PLAYER_FREE";
        break;
    case PLAYER_OUTFIT:
        return @"PLAYER_OUTFIT";
        break;
    case PLAYER_ALIVE:
        return @"PLAYER_ALIVE";
        break;
    case PLAYER_EXPLODE:
        return @"PLAYER_EXPLODE";
        break;
    case PLAYER_DEAD:
        return @"PLAYER_DEAD";
        break;
    default:
        return @"Unknown";
        break;
    }
}

- (int)  previousFlags {
    return previousFlags;
}

- (void) setPreviousFlags:(int) flag {
    previousFlags = flag;
}

- (int)  previousStatus {
    return previousStatus;
}

- (void) setPreviousStatus:(int) stat {
    previousStatus = stat;
}

- (void) setPlanetLock:(Planet *)planetInLock {
    planet = planetInLock;
}

- (id) playerLock {
    return playerLock;
}

- (void) setPlayerLock:(id) playerInLock {
    playerLock = playerInLock;
}

- (int) hostile {
    return hostile;
}

- (void) setTorps:(NSMutableArray*) newTorps {
    torps = newTorps;
}

- (void) setIsMe:(bool)newMe {
    me = newMe;
}

- (NSMutableArray*) torps {
	return torps;      				
}

- (int) phaserId {
    return playerId; // for now assume one on one
}

- (int) plasmaId {
    return playerId; // for now assume one on one
}

- (int) damage {
    return damage;
}

- (int) playerId {
    return playerId;
}

- (int) stickyWar {
    return swar;
}

- (int) shield {
    return shield;
}

- (bool) friendlyToPlayer:(Player*) other {
    return(([team bitMask] & ([other stickyWar] | [other hostile])) == 0 && ([[other team] bitMask] & (swar | hostile)) == 0);
}

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
              thisIsMe: (bool) newIsMe {
    
    hostile = newhostile;
    swar    = newSWar;
    armies  = newArmies;
    flags   = newFlags;
    damage  = newDamage;
    shield  = newShield;
    fuel    = newFuel;
    etemp   = newETemp;
    wtemp   = newWTemp;
    whydead = newWhyDead;
    whodead = newWhoDead;
    me      = newIsMe;
}

- (void) updateHostile: (int) newhostile
             stickyWar: (int) newSWar
                armies: (int) newArmies
                 flags: (int) newFlags
               whyDead: (int) newWhyDead
           whoKilledMe: (int) newWhoDead
              thisIsMe: (bool) newIsMe {
    
    hostile = newhostile;
    swar    = newSWar;
    armies  = newArmies;
    flags   = newFlags;
    whydead = newWhyDead;
    whodead = newWhoDead;
    me      = newIsMe;
}

- (void) updateDamage: (int) newDamage
       shieldStrenght: (int) newShield
                 fuel: (int) newFuel
           engineTemp: (int) newETemp
          weaponsTemp: (int) newWTemp
             thisIsMe: (bool) newIsMe {
    damage  = newDamage;
    shield  = newShield;
    fuel    = newFuel;
    etemp   = newETemp;
    wtemp   = newWTemp;
    me      = newIsMe;
}

- (void) setStickyWar:(int)newSWar {
    swar =newSWar;
}

- (int)  flags {
    return flags;
}

- (Ship*)ship {
    return ship;
}

- (void) setName:(NSString*)newName {
    [name release]; 
    name = newName;
    [name retain];
}

- (void) setLogin:(NSString*)newLogin {
    [login release];
    login = newLogin;
    [login retain];
}

- (void) setMonitor:(NSString*)newMonitor {
    [monitor release];
    monitor = newMonitor;
    [monitor retain];
}

- (Team*)team {
    return team;
}

- (void) setHostile:(int)newhostile {
    hostile = newhostile;
}

- (int)  status {
    return status;
}

- (void) setStatus:(int)newStatus {
    status = newStatus;
}

- (void) setExplode:(int)newExplode {
    explode = newExplode;
}

- (PlayerStats *) stats {
    return stats;
}

- (void) setFlags:(int)newFlags {
    flags = newFlags;
}

- (bool) isMe {
    return me;
}

- (void) setTractorTarget:(Player *)new {
    tractor = new;
}

- (Player *) tractorTarget {
    return tractor;
}

- (void) setShip:(Ship *)newShip {
    ship = newShip;
}

- (void) setPlasmaCount:(int)nrOfPlasmas {
    nplasmatorp = nrOfPlasmas;
}

- (void) setTorpCount:(int)nrOfTorps {
    ntorp = nrOfTorps;
}

- (void) setKills:(int)kill {
    kills = kill;
}

- (void) setTeam:(Team *)newTeam {
    team = newTeam;
    // recreate the mapchars
    [mapChars release];
    mapChars = [team mapCharsForPlayerWithId:playerId];
    [mapChars retain];
}

- (int)wins {
    if ([ship type] == SHIP_SB) {
        return [stats starbaseKills];
    } else {
        return [stats kills];
    }
}

- (int)losses {
    if ([ship type] == SHIP_SB) {
        return [stats starbaseLosses];
    } else {
        return [stats losses];
    }
}

- (int)maxKills {
    if ([ship type] == SHIP_SB) {
        return [stats starbaseMaxKills];
    } else {
        return [stats maxKills];
    }
}

- (NSString*)name {
    return name;
}

- (NSString*)nameWithRankAndKillIndicatorAndShipType {
	return [NSString stringWithFormat: @"%@ (%@) %@", 
		[self nameWithRankAndKillIndicator],
		[self mapChars],
		[[self ship] longName] ];
}

- (NSString*)nameWithRankAndKillIndicator {
    if (kills >= 1) {
        return [NSString stringWithFormat: @"+%@", 
			[self nameWithRank]];
    } else {
		return [self nameWithRank];	 
	}  
}

- (NSString*)nameWithRank {
	return [NSString stringWithFormat: @"%@ %@", 
			[[stats rank] abbrev], name];	 
}


- (NSString*)longNameWithKillIndicator {
    char hasKilled = ' ';
    if (kills >= 1) {
        hasKilled = '+';
    }
        
    return [NSString stringWithFormat: @"%c%@ (%@)", 
        hasKilled, name, mapChars];
}

- (NSString*)longName {
    
    return [NSString stringWithFormat: @"%@ (%@)", name, mapChars];
}

- (NSString *) mapChars {
    return mapChars;
}

- (NSString *) mapCharsWithKillIndicator {
    char hasKilled = ' ';
    if (kills >= 1) {
        hasKilled = '+';
    }
    
    return [NSString stringWithFormat: @"%c%@", 
        hasKilled, mapChars];
}

- (void) increasePlasmaCount {
    nplasmatorp++;
}

- (void) decreasePlasmaCount {
    nplasmatorp--;
}

- (void) increaseTorpCount {
    ntorp++;
}

- (void) decreaseTorpCount {
    ntorp--;
}

- (int) hull {
    // hull strenght is the amount of damage we can still take
    return [ship maxDamage] - damage;
}

- (int) fuel {
    return fuel;
}

- (int) speed {
    return speed;
}

- (int) engineTemp {
    return etemp;
}

- (int) weaponTemp {
    return wtemp;
}

- (int) kills {
    return kills;
}

- (int) maxArmiesForKills {
    // i can carry
    int maxMe = 0;
    if ([ship type] == SHIP_AS) {
        maxMe = 3*kills;
    } else {
        maxMe = 2*kills;
    }
    return maxMe;
}

- (int) maxArmies {
    // my ship can carry max
    int maxShip = [ship maxArmies];
    
    // i can carry
    int maxMe = [self maxArmiesForKills];
    
    // take the minimum
    return (maxShip > maxMe ? maxMe : maxShip);
}

- (int) maxSpeed {
    // limited by damage
    int maxspeed = ([ship maxSpeed] + 2) - 
            (([ship maxSpeed] + 1) * ((float) damage / (float) ([ship maxDamage])));
    
    //int maxspeed = (int)(((float)[ship maxSpeed] + 1) * ((float)[self hull] / (float)([ship maxDamage])));
    if (maxspeed > [ship maxSpeed]) {
        maxspeed = [ship maxSpeed];
    }
    if (maxspeed < 0) {
        maxspeed = 0;
    }
    return maxspeed;
}

- (int) maxTorps {
    // $$ look in getship.c and move that in here
    // so we can calculate based on the fuel left
    return [ship maxTorps];
}

- (int) armies {
    return armies;
}

- (int)  cloakPhase {
    return cloakphase;
}

- (void) increaseCloakPhase {
    cloakphase++;
}

- (void) decreaseCloakPhase {
    cloakphase--;
}

-(char) letterForPlayer {
    
    char letters[] = "0123456789abcdefghijklmnopqrstuvwxyz";
    return letters[playerId];
}

- (int) availableTorps {
    
    // what can we fire ? based on fuel 
    int maxTorps = [self maxTorps];
    
    // but no more then TORPS_MAX
    int freeSlots = ntorp;
        
    return (maxTorps > freeSlots ? freeSlots : maxTorps);
}

- (int) availablePhaserShots {
    // $$ based on fuel and shiptype
    // quick hack 10 bits of fuel 
    return fuel / 1000;
}

- (int) maxPhaserShots {
    // $$ based on fuel and shiptype
    // i'd say about 10 shots per fuel?
    return [ship maxFuel] / 1000;
}


@end
