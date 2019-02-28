//
//  Phaser.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Phaser.h"


@implementation Phaser

- (id) init {
    self = [super init];
    if (self != nil) {
        target = nil;
    }
    return self;
}

- (char) statusChar {
    switch (status) {
    case PHASER_FREE:
        return 'F';
        break;
    case PHASER_HIT:
        return 'H';
        break;
    case PHASER_HIT2:
        return 'P';
        break;
    case PHASER_MISS:
        return 'M';
        break;
    default:
        return '?';
        break;
    }
}

- (void) setTarget:(Player *)targ {
    target = targ;
}

- (Player*) target {
    return target;
}

@end
