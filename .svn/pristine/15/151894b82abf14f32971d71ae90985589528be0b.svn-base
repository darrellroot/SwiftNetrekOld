//
//  Ship.h
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"

#define SHIP_SC  0
#define SHIP_DD  1
#define SHIP_CA  2
#define SHIP_BB  3
#define SHIP_AS  4
#define SHIP_SB  5 
#define SHIP_GA  6
#define SHIP_AT  7
#define SHIP_MAX 8

@interface Ship : SimpleBaseClass {
	 NSString *abbrev;      
	 int phaserdamage;
	 int maxspeed;
	 int maxfuel;
	 int maxshield;
	 int maxdamage;
	 int maxegntemp;
	 int maxwpntemp;
	 int maxarmies;
	 int width;
	 int height;
	 int type;              // $$ never set
	 int torpspeed;
	// phaserfuse has problems because server doesn't always send new phaser
	 int phaserfuse;
}

- (id) initWithType:(int)shiptype;
- (NSString*)abbreviation;
- (int) phaserRange;
- (int) phaserDamage;
- (int) maxPhaserFuse;
- (int) maxDamage;
- (int) maxShield;
- (int) maxHull;
- (int) maxFuel;
- (int) maxSpeed;
- (int) maxTorps;
- (int) maxEngineTemp;
- (int) maxWeaponTemp;
- (int) maxArmies;
- (int) type;
- (NSString*)longName;
- (NSString*)shortName;
- (NSSize) size;
- (NSSize) explosionSize;

- (void) setTorpSpeed: (int) newSpeed;
- (void) setPhaserDamage: (int) newPhaserDamage;
- (void) setMaxSpeed: (int) newMaxSpeed;
- (void) setMaxFuel: (int) newMaxFuel;
- (void) setMaxShield: (int) newMaxShield;
- (void) setMaxDamage: (int) newMaxDamage;
- (void) setMaxWeaponTemp: (int) newMaxWeaponTemp;
- (void) setMaxEngineTemp: (int) newMaxEngineTemp;
- (void) setWidth: (int) newWidth;
- (void) setHeight: (int) newHeight;
- (void) setMaxArmies: (int) newMaxArmies;
@end
