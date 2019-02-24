//
//  LLVector.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

@interface LLVector : LLObject {
	NSPoint origin;
	float angle;
	int size;
}

-(LLVector*)substract:(LLVector*)other;
-(LLVector*)add:(LLVector*)other;

-(NSPoint) origin;
-(float) angle;
-(int) size;
-(void) setOrigin:(NSPoint) pos;
-(void) setAngle: (float) course;
-(void) setSize:  (int) newSize;

@end
