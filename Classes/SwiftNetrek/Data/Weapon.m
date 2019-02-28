//
//  Weapon.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Weapon.h"


@implementation Weapon

- (id) init {
    self = [super init];
    if (self != nil) {
        status = 0;
        previousStatus = 0;
        war = 0;
        owner = nil;
    }
    return self;
}

- (id) initWithId:(int) newId {
    self = [self init];
    if (self != nil) {
        nr = newId;
    }
    return self;
}

- (int)  weaponId {
    return nr;
}

- (int)  status {
    return status;
}

- (int)  previousStatus {
    return previousStatus;
}

- (int)  war {
    return war;
}

-(Player *) owner {
    return owner;
}

- (void) setOwner:(Player*)player {
    owner = player;
}

- (void) setWar:(int) newWar {
    war = newWar;
}

- (void) setStatus:(int) stat {
    status = stat;
}

- (void) setPreviousStatus:(int) stat {
    previousStatus = stat;
}

@end
