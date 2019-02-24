//
//  LLBar.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLBar.h"


@implementation LLBar

static NSBezierPath *line = nil; // this makes us fast, but not rentrant

- (id) init {
    self = [super init];
    if (self != nil) {
        min = 0.0;
        max = 1.0;
		alpha = 1.0;
        value = max;
        tempMax = max;
        discrete = NO;
        line = [[NSBezierPath alloc] init];    
        name = [[NSString stringWithString:@"not set"] retain];
		background = YES;
    }
    return self;
}

- (bool) showBackGround {
	return background;
}

- (NSString *)name {
    return name;
}

- (float) min {
	return min;
}

- (float) max {
	return max;
}

- (float) value {
	return value;
}

- (float) tempMax {
	return tempMax;
}

- (float) warning {
	return warning;
}

- (bool) discrete {
	return discrete;
}

- (float) alpha {
	return alpha;
}

- (float) critical {
	return critical;
}

- (void) setShowBackGround:(bool)show {
	background = show;
}

- (void) setName:(NSString *) newValue {
    [name release];
    name = newValue;
    [name retain];
}

- (void) setDiscrete:(bool)newValue {
	discrete = newValue;
}

- (void) setMin:(float)newValue {
	min = newValue;
}

- (void) setMax:(float)newValue {
	max = newValue;
    tempMax = newValue; // assume temp max increases as well
}

- (void) setValue:(float)newValue {
	if ((value > max) || (value > tempMax)) {
		//LLLog(@"LLBar.setValue too large");
		//return;
        newValue = max;
	}
	value = newValue;
}

- (void) setTempMax:(float)newValue { // explicitly reduce the max, temporarly
	if (newValue > max) {
		LLLog(@"LLBar.setTempMax tempmax <= max");
		return;
	}
	tempMax = newValue;
}

- (void) setWarning:(float)newValue {
	if (newValue > max) {
		LLLog(@"LLBar.setWarning <= max");
		return;
	}
	warning = newValue;
}

- (void) setAlpha:(float)fraction {
	alpha = fraction;
}

- (void) setCritical:(float)newValue {
	if (newValue > max) {
		LLLog(@"LLBar.setCritical <= max");
		return;
	}
	critical = newValue;
}

- (void) drawRect:(NSRect)aRect {
    
	NSColor *barColor = [NSColor greenColor]; // assume ok
	NSRect  barRect = NSInsetRect(aRect, 2, 2); // assume 100% full
    NSRect  disabledBar = barRect;
	if (gradientRect == nil) {
		gradientRect = [[LLGradientRect alloc] init];
	}
    float maxBarLength = barRect.size.width;    
    int maxNrOfDescreteRects = max;
    int tempMaxNrOfDescreteRects = tempMax;
    int nrOfDescreteRects = 0; // assume empty
	NSString *gradientBarColor = LL_GREEN;
    
    // draw the background
	if (background){
	    [[NSColor whiteColor] set];
		NSRectFill(aRect);	
	}
    
	// draw the border
	[[NSColor grayColor] set];
    [line removeAllPoints];
    [line appendBezierPathWithRect:aRect];
    [line stroke];
    
	// determine the bar color and the barRect
	if (min < max) {// normal situation
                    // bar is relative to the max
		barRect.size.width = maxBarLength * value / max;
        nrOfDescreteRects = value;
		if (warning < critical) { // near max becomes crit
			if (value < min) { // empty bar
				barRect.size.width = 0; // do not create negative bar
			} else {
				if (value < warning) { // small green bar
                                       // default
				} else {
					if (value < critical) { // warning, but not crit
						barColor = [NSColor orangeColor];
						gradientBarColor = LL_YELLOW;
					} else {
						barColor = [NSColor redColor];
						gradientBarColor = LL_YELLOW;
					}
				}
			}
		} else { // near min becommes crit
			if (value < min) { // empty bar
				barRect.size.width = 0; // do not create negative bar
			} else {
				if (value > warning) { // large green bar
                                       // default
				} else {
					if (value > critical) { // warning, but not crit
						barColor = [NSColor orangeColor];
						gradientBarColor = LL_YELLOW;
					} else {
						barColor = [NSColor redColor];
						gradientBarColor = LL_RED;
					}
				}
			}
		}
	} else {
		//don't support this situation yet
	}
    
	// draw the bar
    if (!discrete) {
        
        // fill inside
        [barColor set];
        // NSRectFill(barRect);  use gradient bars now        
		[gradientRect fillRect:barRect withColor:gradientBarColor alpha:alpha];
		
        // stroke the outline with black
        [[NSColor blackColor] set];
        NSFrameRect(barRect); 
        
        // reduce the bar if needed
        if (tempMax < max) { // assumes min < max
            
            // the end point we know
            NSPoint end = barRect.origin;
            end.x += maxBarLength;
            
            // it starts at tempmax
            NSPoint start = barRect.origin;
            start.x += maxBarLength * tempMax / max;
            
            // draw a line to strike out ay half height
            // draw a straight line to strike out the disabled part
            start.y -= barRect.size.height / 2;	// assumes flipped...
            end.y = start.y;
            
            // first draw the disabled bar in grey
            disabledBar.origin.x = start.x;
            disabledBar.size.width = end.x - start.x;
            [[NSColor grayColor] set];
            //NSRectFill(disabledBar);
            [gradientRect fillRect:barRect withColor:LL_GRAY alpha:alpha];
			
            // draw the line
            // $$ for some reason we are not seeing this line...
            [[NSColor blackColor] set];
            [line removeAllPoints];
            [line moveToPoint:start];
            [line lineToPoint:end];
            [line stroke];
        }
    } else {
        
        // a discrete bar is filled with rectangles
        // we first draw nrOfDescreteRects for max maxNrOfDescreteRects
        //LLLog(@"LLBar.drawRect max %f tempMax %f value %f", max, tempMax, value);
        //LLLog(@"LLBar.drawRect maxNrOfDescreteRects %d tempMaxNrOfDescreteRects %d nrOfDescreteRects %d ", maxNrOfDescreteRects, tempMaxNrOfDescreteRects, nrOfDescreteRects);

        float discreteRectWidth = maxBarLength; // should hold nrOfDescreteRects
        //LLLog(@"LLBar.drawRect 1 width %f",discreteRectWidth);
        discreteRectWidth -= LLBAR_SEPERATION_BETWEEN_RECTS; // remove left seperator
        //LLLog(@"LLBar.drawRect 2 width %f",discreteRectWidth);
        discreteRectWidth /= maxNrOfDescreteRects; // with for rect+right seperator
        //LLLog(@"LLBar.drawRect 3 width %f",discreteRectWidth);
        discreteRectWidth -= LLBAR_SEPERATION_BETWEEN_RECTS; // width of single rect
        //LLLog(@"LLBar.drawRect 4 width %f",discreteRectWidth);
        barRect.size.width = discreteRectWidth;
               
        barRect.origin.x += LLBAR_SEPERATION_BETWEEN_RECTS; // left seperator
        for (int i = 0; i < nrOfDescreteRects; i++) {
            // fill inside
            [barColor set];
            //NSRectFill(barRect); 
			[gradientRect fillRect:barRect withColor:gradientBarColor alpha:alpha];
			
            // stroke the outline with black
            [[NSColor blackColor] set];
            NSFrameRect(barRect); 
            // shift to next
            barRect.origin.x += (discreteRectWidth + LLBAR_SEPERATION_BETWEEN_RECTS);
        }
        
        [[NSColor blackColor] set];
        // draw the remainder as empty squares
        for (int i = nrOfDescreteRects; i < tempMaxNrOfDescreteRects; i++) {
            // stroke the outline with black            
            NSFrameRect(barRect); 
            // shift to next
            barRect.origin.x += (discreteRectWidth + LLBAR_SEPERATION_BETWEEN_RECTS);
        }
        
        // and the disabled ones
        barColor = [[NSColor blackColor] colorWithAlphaComponent:0.5];
        for (int i = tempMaxNrOfDescreteRects; i < maxNrOfDescreteRects; i++) {
            // fill inside 50% black
            [barColor set];
            //NSRectFill(barRect); 
			[gradientRect fillRect:barRect withColor:LL_GRAY  alpha:alpha];
			
            // stroke the outline with black
            [[NSColor blackColor] set];
            NSFrameRect(barRect); 
            // shift to next
            barRect.origin.x += (discreteRectWidth + LLBAR_SEPERATION_BETWEEN_RECTS);
        }
    }

}

@end
