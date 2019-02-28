//
//  Planet.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Planet.h"

@implementation Planet

- (id) init {
    self = [super init];
    if (self != nil) {
        flags = 0;							// State information
        owner = nil;
        name = @"??";
        position.x = -1000;
        position.y = -1000;
        name = @"??";
        armies = 0;
        info = 0;							// Teams which have info on planets    
        orbit = 0;
        planetId = -1;
    }
    return self;
}

- (id)initWithPlanetId:(int)id {
    self = [self init];
    if (self != nil) {
        planetId = id;
    }
    return self;
}

- (int)planetId {
    return planetId;
}

- (void) trackUpdate {
	// no need, planets remain steady
}

- (NSPoint) predictedPosition {
    // no need, planets remain steady
	return position;
}

- (NSString*) ident {
	return name;
}

- (NSString*) nameWithArmiesIndicator {
    char hasArmies = ' ';
    if (armies > 4) {
        hasArmies = '+';
    }
    return [NSString stringWithFormat:@"%c%@", hasArmies, name];
}

- (NSString*) abbrWithArmiesIndicator {
    char hasArmies = ' ';
    if (armies > 4) {
        hasArmies = '+';
    }
    
    return [NSString stringWithFormat:@"%c%@", hasArmies, [[self abbreviation] lowercaseString]];
}

- (NSString*) name {
    return name;
}

- (NSString*) abbreviation {
    if ([name length] > 3) {
        return [[name substringWithRange:NSMakeRange(0,3)] uppercaseString];
    }
    return name;
}

- (bool) needsDisplay {
    return needsDisplay;
}

- (Team*) owner {
    return owner;
}

- (void) setOwner: (Team*) team {
    owner = team;
}

- (int)  info {
    return info;
}

- (void) setInfo: (int) newInfo {
    info = newInfo;
}		

- (int)  flags {
    return flags;
}

- (int)  armies {
    return armies;
}

- (void) setName:(NSString *)newName {
    [name release];
    name = newName;
    [name retain];
}

- (void) setFlags: (int) newFlags {
    flags = newFlags;
}

- (void) setArmies: (int) newArmies {
    armies = newArmies;
}

- (void) setNeedsDisplay: (bool) redraw {
    needsDisplay = redraw;
}

// fixed size 1200 by 1200 game pix (30x30 view pix)
- (NSSize) size {
    return NSMakeSize(1200, 1200);
}

@end
