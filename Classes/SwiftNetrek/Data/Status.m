//
//  Status.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Status.h"


@implementation Status

- (id) init {
    self = [super init];
    if (self != nil) {
        tourn = NO;
        promoted = NO;     
        armsbomb = 0; 
        planets = 0;
        kills = 0; 
        losses = 0;
        timeElapsed = 0;
        timeprod = 0;
        observer = NO;
    }
    return self;
}

-(int) armiesBombed {
    return armsbomb;
} 

-(int) planets {
    return planets;
}

-(int) kills {
    return kills;
}

-(int) losses {
    return losses;
}

-(long) timeProductive {
    return timeprod;
}

-(void) setObserver:(bool)on {
    observer = on;
}

-(void) setPromoted:(bool)prom {
    promoted = prom;
}

-(void) updateTournament: (int)newTournament
            armiesBombed: (int)newArmiesBombed
            planetsTaken: (int)newPlanets
                   kills: (int)newKills	
                  losses: (int)newLosses
                    time: (int)newTime
                timeProd: (int)newTimeProd {
    
    tourn    = newTournament;
    armsbomb = newArmiesBombed;
    planets  = newPlanets;
    kills    = newKills;
    losses   = newLosses;
    timeElapsed = newTime;
    timeprod = newTimeProd;
}

@end
