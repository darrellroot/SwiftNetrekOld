//
//  LLShapes.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

@interface LLShapes : LLObject {

}

- (NSRect) rectWithHeight:(int)height width:(int)width centerPoint:(NSPoint)centerGravity;
- (void)   drawTriangleNotchUpInRect:(NSRect)rect;
- (void)   drawTriangleNotchDownInRect:(NSRect)rect;
- (void)   drawCircleInRect:(NSRect) rect;
- (void)   drawSpaceShipInRect:(NSRect) rect;
- (void)   drawDoubleCircleInRect:(NSRect) rect;
- (NSRect) createRectAroundOrigin:(NSRect)Rect;
- (NSPoint)centreOfRect:(NSRect)Rect;
- (void)   roundedRectangle:(NSRect)aRect withRadius:(float)radius fill:(bool)fill;
- (void)   roundedLabel:(NSRect)aRect withColor:(NSColor *)col;

@end
