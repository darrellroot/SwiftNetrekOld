//
//  LLShapes.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLShapes.h"


@implementation LLShapes

static NSBezierPath *line = nil; // this makes us fast, but not rentrant

- (id) init {
    self = [super init];
    if (self != nil) {
                line = [[NSBezierPath alloc] init];   
    }
    return self;
}

- (NSRect) rectWithHeight:(int)height width:(int)width centerPoint:(NSPoint)centerGravity {
    
    NSRect result;
    
    result.size.width = width;
    result.size.height = height;
    result.origin.x = centerGravity.x - width / 2;
    result.origin.y = centerGravity.y - height / 2;
    
    return result;
}

- (void)drawTriangleNotchUpInRect:(NSRect)rect {
    
    // left is bottom left
    NSPoint left = rect.origin;
    left.y += rect.size.height;
    // right is left + width
    NSPoint right = left;
    right.x += rect.size.width;
    // mid is mid top
    NSPoint mid = rect.origin;
    mid.x += rect.size.width/2; 
    
    // color must be set outside!
    [line removeAllPoints];
    [line moveToPoint:left];
    [line lineToPoint:right];
    [line lineToPoint:mid];
    [line lineToPoint:left];
    [line closePath];
    [line stroke];
}

- (void)drawTriangleNotchDownInRect:(NSRect)rect {
    
    // left is top left
    NSPoint left = rect.origin;
    // right is left + width
    NSPoint right = rect.origin;
    right.x += rect.size.width;
    // mid is mid bottom
    NSPoint mid = rect.origin;
    mid.x += rect.size.width/2; 
    mid.y += rect.size.height;
              
    // color must be set outside!
    [line removeAllPoints];
    [line moveToPoint:left];
    [line lineToPoint:right];
    [line lineToPoint:mid];
    [line lineToPoint:left];
    [line closePath];
    [line stroke];
}

- (void) drawCircleInRect:(NSRect) rect {
    // color must be set outside!
    [line removeAllPoints];
    [line appendBezierPathWithOvalInRect:rect];
    [line stroke];  
}

- (void)   drawSpaceShipInRect:(NSRect) rect {
    
    [line removeAllPoints];
    
    // soucer section first
    NSPoint p;
    NSRect r;
    
    // center x
    p.x = rect.origin.x + rect.size.width / 2;
    // diameter 1/2 with 1/4 space on each side
    p.y = rect.origin.y + rect.size.height / 4;
    // draw
    [line appendBezierPathWithArcWithCenter:p radius:(rect.size.height / 4)
                                 startAngle:0 endAngle:360];
    
    // create a nascell half hight (lower)  1/5 width
    r.origin.x = rect.origin.x;
    r.origin.y = rect.origin.y + rect.size.height / 2;
    r.size.width = rect.size.width / 5;
    r.size.height = rect.size.height / 2;
    // add left
    [line appendBezierPathWithRect:r];
    // calc right (shift 4/5)
    r.origin.x += 4 * r.size.width;
    [line appendBezierPathWithRect:r];

    // t shape enginering  soucer to nascells
    // place nacell 2 steps back and a little up
    r.origin.x -= 2 * r.size.width; 
    r.origin.y -= (rect.size.width / 5);
    [line appendBezierPathWithRect:r];
    // cross beam
    r = rect; // start with whole and reduce
    r.size.height = (rect.size.width / 5);
    r.origin.y += (rect.size.height - 2*r.size.height);
    [line appendBezierPathWithRect:r];

    // draw it
    [line fill];  
}

- (void) drawDoubleCircleInRect:(NSRect) rect {
    // color must be set outside!
    [line removeAllPoints];
    [line setWindingRule:NSEvenOddWindingRule];
    [line appendBezierPathWithOvalInRect:rect];
    [line appendBezierPathWithOvalInRect:NSInsetRect(rect, 5, 5)];
    [line stroke];  
    // reset
    [line setWindingRule:[NSBezierPath defaultWindingRule]];
}

- (NSRect) createRectAroundOrigin:(NSRect)Rect {
    NSRect result = Rect;
    result.origin.x = -(result.size.width/2);
    result.origin.y = -(result.size.height/2);
    return result;
}

- (NSPoint) centreOfRect:(NSRect)Rect { 
    NSPoint result = Rect.origin;
    result.x += Rect.size.width/2;
    result.y += Rect.size.height/2;
    return result;
}

- (void)roundedLabel:(NSRect)aRect withColor:(NSColor *)col {
    
    float radius = 0.25 * aRect.size.height;
    [[col colorWithAlphaComponent:0.5] set];
    [self roundedRectangle:aRect withRadius:radius fill:YES];
    [col set];
    //    [self roundedRectangle:aRect withRadius:radius fill:NO];
    // dirty enhancement, we know line still holds the correct figure
    [line stroke];
}

- (void)roundedRectangle:(NSRect)aRect withRadius:(float)radius fill:(bool)fill {
    
    // make sure it fits
    if (aRect.size.height < 2*radius) {
        radius = aRect.size.height / 2;
    }
    if (aRect.size.width < 2*radius) {
        radius = aRect.size.width / 2;
    }
    
    NSPoint topMid = NSMakePoint(NSMidX(aRect), NSMaxY(aRect));
    NSPoint topLeft = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
    NSPoint topRight = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
    NSPoint bottomRight = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
    
    // color must be set outside!
    [line removeAllPoints];
    [line moveToPoint:topMid];
    [line appendBezierPathWithArcFromPoint:topLeft toPoint:aRect.origin radius:radius];
    [line appendBezierPathWithArcFromPoint:aRect.origin toPoint:bottomRight radius:radius];
    [line appendBezierPathWithArcFromPoint: bottomRight toPoint:topRight radius:radius];
    [line appendBezierPathWithArcFromPoint:topRight toPoint:topLeft radius:radius];
    [line closePath];
    
    if (fill) {
        [line fill];
    } else {
        [line stroke];
    }
}

@end
