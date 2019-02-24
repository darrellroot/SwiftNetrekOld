//
//  MTMouseMap.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 23/02/2007.
//  Copyright 2007 Luky Soft.See Licence.txt for licence details.
//

#import "MTMouseMap.h"


@implementation MTMouseMap

- (id) init {
	self = [super init];
	if (self != nil) {		
		actionMouseLeft = ACTION_SET_COURSE;
		actionMouseMiddle = ACTION_FIRE_PHASER;
		actionMouseRight = ACTION_FIRE_TORPEDO;
		actionMouseWheel = ACTION_ZOOM;
	}
	return self;
}

- (int) actionMouseLeft {
	return actionMouseLeft;
}

- (int) actionMouseMiddle {
	return actionMouseMiddle;
}

- (int) actionMouseRight {
	return actionMouseRight;
}

- (int) actionMouseWheel {
	return actionMouseWheel;
}


- (void) setActionMouseLeft:(int)action {
	actionMouseLeft = action;
}

- (void) setActionMouseMiddle:(int)action{
	actionMouseMiddle = action;
}


- (void) setActionMouseRight:(int)action{
	actionMouseRight = action;
}


- (void) setActionMouseWheel:(int)action{
	actionMouseWheel = action;
}



@end
