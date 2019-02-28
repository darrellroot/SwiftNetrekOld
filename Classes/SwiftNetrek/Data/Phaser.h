//
//  Phaser.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Weapon.h"
#import "Player.h"

#define PHASER_MAX_DISTANCE  6000 	/* At this range a player can do damage with phasers */
#define PHASER_FREE           0x0
#define PHASER_HIT            0x1	/* When it hits a person */
#define PHASER_MISS           0x2
#define PHASER_HIT2           0x4	/* When it hits a photon */

@interface Phaser : Weapon {
    Player *target;							// Who's being hit (for drawing) 
}

- (void) setTarget:(Player *)target;
- (Player*) target;
- (char) statusChar;

@end
