//
//  LLTarget.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLVector.h"

@interface LLTarget : LLVector {
	NSDate *timeStamp;
}

- (id) initWithPosition: (NSPoint) pos 
				 course: (float) course 
				  speed: (int) newSpeed;
-(NSPoint) position;
-(int) course;
-(int) speed;
-(NSDate*) timeStamp;
-(void) setPosition:(NSPoint) pos;
-(void) setCourse: (int) course;
-(void) setSpeed:  (int) newSize;
-(void) setTimeStamp:  (NSDate*) newTimeStamp;

@end
