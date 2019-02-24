//
//  LLGradientRect.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 20/09/2006.
//  Copyright 2006 __MyCompanyName__. LGPL Licence.
//

#import "LLGradientRect.h"


@implementation LLGradientRect

- (id) init {
	self = [super init];
	if (self != nil) {
		images = [[NSMutableDictionary alloc] init];
		[self addImage:@"highlight_blue.tiff" forKey:LL_BLUE];
		[self addImage:@"highlight_green.tiff" forKey:LL_GREEN];
		[self addImage:@"highlight_grey.tiff" forKey:LL_GRAY];
		[self addImage:@"highlight_red.tiff" forKey:LL_RED];
		[self addImage:@"highlight_yellow.tiff" forKey:LL_YELLOW];		
	}
	return self;
}

- (void) addImage:(NSString*)name forKey:(NSString *) key {
	
	NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
	NSString *pathToImage = [NSString stringWithFormat:@"%@/LLResources/%@", pathToResources, name];
	
	NSImage *image = [[NSImage alloc] initWithContentsOfFile:pathToImage];
	
	if (image == nil) {
		LLLog(@"LLGradientRect.addImage: ERROR, cannot find %@", pathToImage);
	} else {	
		[images setObject:image forKey:key];
	}
}

- (void) fillRect:(NSRect) aRect withColor:(NSString*)col alpha:(float)alpha {
	
	NSImage *image = [images objectForKey:col];
	if (image == nil) {
		image = [images objectForKey:LL_GRAY];
	}
	
	NSRect sourceRect;
	sourceRect.size = [image size];
	sourceRect.origin = NSZeroPoint;
	
	[image drawInRect:aRect fromRect:sourceRect operation:NSCompositeSourceOver fraction:alpha];
}

@end
