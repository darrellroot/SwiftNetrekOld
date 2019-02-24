//
//  Rank.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Rank.h"


@implementation Rank

- (id) init {
    self = [super init];
    if (self != nil) {
        hours = 0;
        ratings = 0;
        defense = 0;
        name = nil;
    }
    return self;
}

-(id)initWithHours:(float)hrs ratings:(float)rate defense:(float)def name:(NSString*)rankName abbrev:(NSString*)rankAbb {
    self = [self init];
    if (self != nil) {
        hours   = hrs;
        ratings = rate;
        defense = def;
        name    = rankName;
        abbrev  = rankAbb;
    }
    return self;  
}


-(NSString *)abbrev {
    return abbrev;
}

-(NSString *)name {
    return name;
}

@end
