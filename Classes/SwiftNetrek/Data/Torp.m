//
//  Torp.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Torp.h"

@implementation Torp

// fixed size 10x10?
- (NSSize) size {
    return NSMakeSize(80, 80);
}

- (NSSize) explosionSize {
    return NSMakeSize(100, 100);;
}

- (NSString*) ident {
	int torpId = [[owner torps] indexOfObject:self];
	return [[NSString stringWithFormat:@"%@-T%d", [owner mapChars], torpId] autorelease];
}

@end
