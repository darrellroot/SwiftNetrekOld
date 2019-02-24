//
//  Plasma.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Projectile.h"
#import "Team.h"

#define PLASMA_FREE     PROJECTILE_FREE
#define PLASMA_MOVE     PROJECTILE_MOVE
#define PLASMA_EXPLODE  PROJECTILE_EXPLODE
#define PLASMA_DET      PROJECTILE_DET
#define PLASMA_OFF      PROJECTILE_OFF

@interface Plasma : Projectile {
    Team *team;                       // launching team
}

- (Team *) team;
- (void) setTeam:(Team*)newTeam;
- (NSSize) size;
- (NSSize) explosionSize;

@end
