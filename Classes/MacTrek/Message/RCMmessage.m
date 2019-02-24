//
//  RCMmessage.m
//  MacTrek
//
//  Created by Aqua on 30/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "RCMmessage.h"


@implementation RCMmessage

- (id) init {
    self = [super init];
    if (self != nil) {
        to = 0;
    }
    return self;
}

- (void) setFlags: (int) newFlags {
    macro_flag = newFlags;
}

- (void) setTo: (int) newTo{
    to = newTo;
}

- (void) setType: (int) newType{
    distress_type = newType;
}

- (void) setSender: (Player *)newSender{
    sender = newSender;
}


- (void) setTargetPlayer: (Player *)newTargetPlayer{
    target_player = newTargetPlayer;
}


- (void) setArmies: (int) newArmies{
    armies = newArmies;
}

- (void) setDamage: (int) newDamage{
    damage = newDamage;
}

- (void) setShields: (int) newShields{
    shields = newShields;
}

- (void) setTargetPlanet: (Planet *)newTargetPlanet{
    target_planet = newTargetPlanet;
}

- (void) setWeaponTemp: (int) newWeaponTemp {
    wtemp = newWeaponTemp;
}

@end
