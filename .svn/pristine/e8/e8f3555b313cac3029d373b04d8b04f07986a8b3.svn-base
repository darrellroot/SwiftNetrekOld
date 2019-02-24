//
//  LLInterceptorAngle.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLInterceptAngle.h"


@implementation LLInterceptAngle

-(int) findAngleFrom:(NSPoint) pos1 to:(NSPoint) pos2 {
    return 0; 
}

- (int) angleForTarget:(LLTarget*) target fromSource:(LLTarget*)source projectileSpeed:(int)speed {
	
	bool interceptPossible = YES;
	int interceptTime = 0;
	
	// relative position of target
	LLVector *delta = [target substract:source];
	
	// set up the quadratic equation's variables
	int a = speed * speed - [delta size] * [delta size];
	int b = -( 2 * [delta size] * 
			   ( [delta origin].x * sin([delta angle]) - [delta origin].y * cos([delta angle]) ) );
	int c = - ([delta origin].x * [delta origin].x + [delta origin].y * [delta origin].y);
    
	// ensure there's no problem with the square root, and no divide by zero
	int sq = (b * b) - (4 * a * c);
	if ((sq < 0) || (a == 0)) {
		interceptPossible = NO;
	} else {
		// we're good to go, get the two results of the quadratic equation
		int t1 = (-b - sqrt(sq)) / (2 * a);
		int t2 = (-b + sqrt(sq)) / (2 * a);
		
		// is the first Time value the optimal one?
		if ((t1 > 0) && (t1 < t2)) {
			interceptTime = t1;	
		} else if (t2 > 0) {
			interceptTime = t2;
		} else {
		 	interceptPossible = NO;
		}
	}
    
	// is there a solution?
	if (interceptPossible) {
		// where will the target be, in interceptTime seconds?
		NSPoint hit;
		hit.x = [target position].x + [target speed] * sin([target course]) * interceptTime;
		hit.y = [target position].y - [target speed] * cos([target course]) * interceptTime;
		// return the angle to hit the target
		return [self findAngleFrom:[source position] to:hit];
	}
	else {
		return INTERCEPT_NOT_POSSIBLE;
	}
}

@end
