//
//  Weapon.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Entity.h"
#import "Player.h"

@interface Weapon : Entity {
	int status;						// State information
    int previousStatus;				// State information used for the last update
	int war;						// enemies
    Player *owner; 
    int nr;                         // id
}

- (id) initWithId:(int) nr;

- (Player *) owner;
- (int)  status;
- (int)  previousStatus;
- (int)  war;
- (int)  weaponId;

- (void) setStatus:(int) status;
- (void) setPreviousStatus:(int) status;
- (void) setWar:(int) war;
- (void) setOwner:(Player*)player; 

@end
