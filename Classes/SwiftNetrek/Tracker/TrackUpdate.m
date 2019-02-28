//
//  TrackUpdate.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 19/11/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "TrackUpdate.h"


@implementation TrackUpdate

- (id) init {
	self = [super init];
	if (self != nil) {
		ident = @"unknown";
	}
	return self;
}


- (NSString*) ident {
    return ident;
}

- (void)setIdent:(NSString*) name {
    [ident release];
	ident = name;
	[ident retain];
}

@end
