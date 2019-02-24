//
//  Projectile.m
//  MacTrek
//
//  Created by Aqua on 23/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Projectile.h"


@implementation Projectile

- (char) statusChar {
    switch (status) {
        case PROJECTILE_FREE:
            return 'F';
            break;
        case PROJECTILE_MOVE:
            return 'M';
            break;
        case PROJECTILE_EXPLODE:
            return 'E';
            break;
        case PROJECTILE_DET:
            return 'D';
            break;
        case PROJECTILE_OFF:
            return 'O';
            break;
        default:
            return '?';
            break;
    }
}

- (char) previousStatusChar {
    switch (previousStatus) {
        case PROJECTILE_FREE:
            return 'F';
            break;
        case PROJECTILE_MOVE:
            return 'M';
            break;
        case PROJECTILE_EXPLODE:
            return 'E';
            break;
        case PROJECTILE_DET:
            return 'D';
            break;
        case PROJECTILE_OFF:
            return 'O';
            break;
        default:
            return '?';
            break;
    }
}

@end
