//
//  LLTrigonometry.h
//  MacTrek
//
//  Created by Aqua on 29/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

@interface LLTrigonometry : LLObject {
    
}

+ (LLTrigonometry*) defaultInstance;
- (int)hypotOfBase:(int) base heigth:(int)heigth;
- (float)floatHypotOfBase:(float)x1 heigth:(float)y1;
- (float)angleDegBetween:(NSPoint)p1 andPoint:(NSPoint)p2;

// fast sin/cos base on a char angle, thus every +1 is approx +1.4 deg.
- (double) cos:(int) i;
- (double) sin:(int) i;
- (int) cosLength;
- (int) sinLength;
- (bool) rect:(NSRect) r1 isEqualToRect:(NSRect) r2;

@end
