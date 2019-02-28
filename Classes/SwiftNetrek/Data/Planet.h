//
//  Planet.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

@class Team;

#import <Cocoa/Cocoa.h>
#import "Entity.h"
#import "Team.h"

// the lower bits represent the original owning team
#define PLANET_REPAIR   0x010
#define PLANET_FUEL     0x020
#define PLANET_AGRI     0x040
#define PLANET_REDRAW   0x080	// should the planet be redrawn on the galactic?
#define PLANET_HOME     0x100		// home planet for a given team
#define PLANET_COUP     0x200		// Coup has occured
#define PLANET_CHEAP    0x400		// Planet was taken from undefended team

#define PLANET_MAX_NR_OF_PLANETS 40

@interface Planet : Entity {
    int flags;							// State information
    Team *owner;
    NSString *name;
    int armies;
    int planetId;
    int info;							// Teams which have info on planets    
    int orbit;                      // $$ when set?
    bool needsDisplay;
}

- (id)initWithPlanetId:(int)id;
- (int)planetId;
- (int)  info;
- (int)  flags;
- (int)  armies;
- (Team *) owner;
- (NSString*) name;
- (NSString*) nameWithArmiesIndicator;
- (NSString*) abbrWithArmiesIndicator;
- (NSString*) abbreviation;
- (bool) needsDisplay;
- (NSSize) size;

- (void) setInfo: (int) newInfo;			
- (void) setFlags: (int) newFlags;
- (void) setArmies: (int) newArmies;
- (void) setOwner: (Team*) team;
- (void) setName:(NSString *)newName;
- (void) setNeedsDisplay: (bool) redraw;

@end
