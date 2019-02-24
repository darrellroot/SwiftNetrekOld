//
//  LLVector.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLVector.h"

@implementation LLVector

-(float) angleFromComponent:(int)x andComponent:(int) y {
    // Determine the angle to the given set of coords
    if (y > 0) {
		return atan(x / y);
    }
    if (y < 0) {
		return atan(x / y) + pi;
    }
    if ((y = 0) && (x < 0)) {
		return 3 * pi / 2;
    }
    
    return pi / 2;
}

-(LLVector*)add:(LLVector*)other {

	LLVector *result = [[LLVector alloc] init];

	// first add the position (may not be interesing)
    NSPoint resP;
    NSPoint otherP = [other origin];
	resP.x = origin.x + otherP.x;
	resP.y = origin.y + otherP.y;
    [result setOrigin:resP];

    	// Determine the X and Y components of the resultant vector
     	int xv = [other size] * sin([other angle]) + size * sin(angle);
     	int yv = [other size] * cos([other angle]) + size * cos(angle);

	// Determine the resultant magnitude
    [result setSize: sqrt (xv*xv + yv*yv)];

	// and the angle
	[result setAngle: [self angleFromComponent: xv andComponent: yv]];

	return result;
}

-(LLVector*)substract:(LLVector*)other {
    
	LLVector *result = [[LLVector alloc] init];
    
	// first substract the position (may not be interesing)
    NSPoint resP;
    NSPoint otherP = [other origin];
	resP.x = origin.x - otherP.x;
	resP.y = origin.y - otherP.y;
    [result setOrigin:resP];
    
    // Determine the X and Y components of the resultant vector
    int xv = [other size] * sin([other angle]) + size * sin(angle + pi);
    int yv = [other size] * cos([other angle]) + size * cos(angle + pi);
    
	// Determine the resultant magnitude
    [result setSize: sqrt (xv*xv + yv*yv)];
    
	// and the angle
	[result setAngle: [self angleFromComponent: xv andComponent: yv]];
    
	return result;
}

-(NSPoint) origin {
        return origin;
}

-(float) angle {
        return angle;
}

-(int) size {
        return size;
}

-(void) setOrigin:(NSPoint) pos {
        origin = pos;
}

-(void) setAngle: (float) course {
        angle = course;
}

-(void) setSize:  (int) newSize {
        size = newSize;
}

@end

