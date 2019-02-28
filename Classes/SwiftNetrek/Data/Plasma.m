//
//  Plasma.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Plasma.h"


@implementation Plasma

- (id) init {
    self = [super init];
    if (self != nil) {
        team = nil;
    }
    return self;
}


- (Team *) team {
    return team;
}

- (void) setTeam:(Team*)newTeam {
    team = newTeam;
}

// fixed size 10x10?
- (NSSize) size {
    return NSMakeSize(100, 100);
}

- (NSSize) explosionSize {
    return NSMakeSize(120, 120);
}

@end
