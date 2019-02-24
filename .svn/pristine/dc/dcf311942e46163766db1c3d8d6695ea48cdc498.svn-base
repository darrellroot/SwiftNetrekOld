//
//  LLTarget.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLTarget.h"

@implementation LLTarget

- (id) init {
	self = [super init];
	if (self != nil) {
		timeStamp = nil;
	}
	return self;
}

- (id) initWithPosition: (NSPoint) pos 
				 course: (float) course 
				  speed: (int) newSpeed {
	self = [self init];
	if (self != nil) {
		timeStamp = [NSDate date]; // now
		origin = pos;
		angle = course;
 	    size = newSpeed;
		LLLog(@"LLTarget.init %f (%f, %f) S%d C%f", 
			  [timeStamp timeIntervalSinceReferenceDate], pos.x, pos.y, size, course);
		
	}
	return self;
}

-(NSPoint) position {
        return origin;
}

-(int) course {
        return angle;
}

-(int) speed {
        return size;
}

-(NSDate*) timeStamp {
	return timeStamp;
}

-(void) setTimeStamp:  (NSDate*) newTimeStamp {
	[timeStamp release];
	timeStamp = newTimeStamp;
	[timeStamp retain];
}

-(void) setPosition:(NSPoint) pos {
        origin = pos;
}

-(void) setCourse: (int) course {
        angle = course;
}

-(void) setSpeed:  (int) newSpeed {
        size = newSpeed;
}

@end

