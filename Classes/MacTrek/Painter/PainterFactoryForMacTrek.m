//
//  PainterFactoryForMacTrek.m
//  MacTrek
//
//  Created by Aqua on 23/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PainterFactoryForMacTrek.h"


@implementation PainterFactoryForMacTrek

- (id) init {
	self = [super init];
	if (self != nil) {
		iconStaticScaler = 1; // keep icons small
	}
	return self;
}

- (NSImage *)loadImage:(NSString*)imageName {
    
    // try new image first
    NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
    NSString *pathToImage = [NSString stringWithFormat:@"%@/ImagesPainter2%@", pathToResources, imageName];
    
    NSImage *rawImage = [[NSImage alloc] initWithContentsOfFile:pathToImage];
    
    if (rawImage == nil) {
        //LLLog(@"PainterFactoryForMacTrek.loadImage %@ failed, reverting to super", pathToImage);
        // something went wrong try super image
        return [super loadImage:imageName];
    }
       
    return rawImage;
}

- (void) cacheImages {
    [super cacheImages];
	
	// we have some different types of files 
	[imgBackground release];    
	imgBackground = [self cacheImage:@"/background.png"];
	[imgFuel release];
	imgFuel       = [self cacheImage:@"/Planets/fuel.png"]; 
    [imgArmy release];
	imgArmy       = [self cacheImage:@"/Planets/army.png"]; 
    [imgRepair release];
	imgRepair     = [self cacheImage:@"/Planets/wrench.png"]; 
	[imgShipCloak release];
	imgShipCloak  = [self cacheImage:@"/Misc/cloak.png"];
	
}

- (void)   drawBackgroundImageInRect:(NSRect) Rect {
	
    NSRect sourceRect = NSMakeRect(0, 0, 0, 0);
    sourceRect.size = [imgBackground size];
    
    [imgBackground drawInRect:Rect fromRect:sourceRect  operation:NSCompositeSourceOver fraction:1.0];
	 
}

- (NSSize) backGroundImageSize {
    return [imgBackground size];
}


- (void) drawLabelBackgroundForRect:(NSRect)aRect {
	
	[shapes roundedLabel:aRect withColor:[NSColor grayColor]];
}

@end
