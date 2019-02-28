//
//  PainterFactoryForTac.m
//  MacTrek
//
//  Created by Aqua on 23/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PainterFactoryForTac.h"


@implementation PainterFactoryForTac

- (NSImage *)loadImage:(NSString*)imageName {
    
    // try new image first
    NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
    NSString *pathToImage = [NSString stringWithFormat:@"%@/ImagesPainter3%@", pathToResources, imageName];
    
    NSImage *rawImage = [[NSImage alloc] initWithContentsOfFile:pathToImage];
    
    if (rawImage == nil) {
        //LLLog(@"PainterFactoryForTac.loadImage %@ failed, reverting to super", pathToImage);
        // something went wrong try super image
        return [super loadImage:imageName];
    }
	
    return rawImage;
}

- (void) cacheImages {
    [super cacheImages];
	
	extraImages = [[NSMutableDictionary alloc] init];
	
	// okay the fedships are allocated, but we want
	// additionally the old gifs.		
	[extraImages setObject:[self cacheImage:@"/Ships/fed/SC.gif"] forKey:@"Fed-SC"];
	[extraImages setObject:[self cacheImage:@"/Ships/fed/DD.gif"] forKey:@"Fed-DD"];
	[extraImages setObject:[self cacheImage:@"/Ships/fed/CA.gif"] forKey:@"Fed-CA"];
	[extraImages setObject:[self cacheImage:@"/Ships/fed/BB.gif"] forKey:@"Fed-BB"];
	[extraImages setObject:[self cacheImage:@"/Ships/fed/AS.gif"] forKey:@"Fed-AS"];
	[extraImages setObject:[self cacheImage:@"/Ships/fed/SB.gif"] forKey:@"Fed-SB"];
	
	[extraImages setObject:[self cacheImage:@"/Ships/kli/SC.gif"] forKey:@"Kli-SC"];
	[extraImages setObject:[self cacheImage:@"/Ships/kli/DD.gif"] forKey:@"Kli-DD"];
	[extraImages setObject:[self cacheImage:@"/Ships/kli/CA.gif"] forKey:@"Kli-CA"];
	[extraImages setObject:[self cacheImage:@"/Ships/kli/BB.gif"] forKey:@"Kli-BB"];
	[extraImages setObject:[self cacheImage:@"/Ships/kli/AS.gif"] forKey:@"Kli-AS"];
	[extraImages setObject:[self cacheImage:@"/Ships/kli/SB.gif"] forKey:@"Kli-SB"];
	
	[extraImages setObject:[self cacheImage:@"/Ships/rom/SC.gif"] forKey:@"Rom-SC"];
	[extraImages setObject:[self cacheImage:@"/Ships/rom/DD.gif"] forKey:@"Rom-DD"];
	[extraImages setObject:[self cacheImage:@"/Ships/rom/CA.gif"] forKey:@"Rom-CA"];
	[extraImages setObject:[self cacheImage:@"/Ships/rom/BB.gif"] forKey:@"Rom-BB"];
	[extraImages setObject:[self cacheImage:@"/Ships/rom/AS.gif"] forKey:@"Rom-AS"];
	[extraImages setObject:[self cacheImage:@"/Ships/rom/SB.gif"] forKey:@"Rom-SB"];
	
	[extraImages setObject:[self cacheImage:@"/Ships/ori/SC.gif"] forKey:@"Ori-SC"];
	[extraImages setObject:[self cacheImage:@"/Ships/ori/DD.gif"] forKey:@"Ori-DD"];
	[extraImages setObject:[self cacheImage:@"/Ships/ori/CA.gif"] forKey:@"Ori-CA"];
	[extraImages setObject:[self cacheImage:@"/Ships/ori/BB.gif"] forKey:@"Ori-BB"];
	[extraImages setObject:[self cacheImage:@"/Ships/ori/AS.gif"] forKey:@"Ori-AS"];
	[extraImages setObject:[self cacheImage:@"/Ships/ori/SB.gif"] forKey:@"Ori-SB"];
	
	[extraImages setObject:[self cacheImage:@"/Ships/ind/SC.gif"] forKey:@"Ind-SC"];
	[extraImages setObject:[self cacheImage:@"/Ships/ind/DD.gif"] forKey:@"Ind-DD"];
	[extraImages setObject:[self cacheImage:@"/Ships/ind/CA.gif"] forKey:@"Ind-CA"];
	[extraImages setObject:[self cacheImage:@"/Ships/ind/BB.gif"] forKey:@"Ind-BB"];
	[extraImages setObject:[self cacheImage:@"/Ships/ind/AS.gif"] forKey:@"Ind-AS"];
	[extraImages setObject:[self cacheImage:@"/Ships/ind/SC.gif"] forKey:@"Ind-SB"];
	
	// and the planets
	[extraImages setObject:[self cacheImage:@"/Planets/fed/agri.gif"] forKey:@"Fed-agri"];
	[extraImages setObject:[self cacheImage:@"/Planets/fed/bare.gif"] forKey:@"Fed-bare"];
	
	[extraImages setObject:[self cacheImage:@"/Planets/kli/agri.gif"] forKey:@"Kli-agri"];
	[extraImages setObject:[self cacheImage:@"/Planets/kli/bare.gif"] forKey:@"Kli-bare"];
	
	[extraImages setObject:[self cacheImage:@"/Planets/rom/agri.gif"] forKey:@"Rom-agri"];
	[extraImages setObject:[self cacheImage:@"/Planets/rom/bare.gif"] forKey:@"Rom-bare"];
	
	[extraImages setObject:[self cacheImage:@"/Planets/ori/agri.gif"] forKey:@"Ori-agri"];
	[extraImages setObject:[self cacheImage:@"/Planets/ori/bare.gif"] forKey:@"Ori-bare"];
	
	[extraImages setObject:[self cacheImage:@"/Planets/ind/agri.gif"] forKey:@"Ind-agri"];
	[extraImages setObject:[self cacheImage:@"/Planets/ind/bare.gif"] forKey:@"Ind-bare"];

	
}

- (void)   drawPlanet:(Planet*) planet inRect:(NSRect) Rect { 
	
    NSImage *imgPlanet = nil;
    NSRect frameRect;
    
    // do we know this planet?    
    int mask = [[[universe playerThatIsMe] team] bitMask];
    if (([planet info] & mask) == 0) {
        // nope
		
		[super drawPlanet:planet inRect:Rect];
		return;
    } 
	
	NSMutableString *key = [[[NSMutableString alloc] init] autorelease];
	
	// start with the team
	[key appendString:[[planet owner] abbreviation]];
	
	// type is HOME|ARI|ROCK
	if ([planet flags] & PLANET_AGRI) {
		// then teh type
		[key appendString:@"-agri"];
	} else {
		// it's bare rock
		[key appendString:@"-bare"];
	}
	
	// get
	imgPlanet = [extraImages objectForKey:key];
	
	if (imgPlanet == nil) {
		LLLog(@"PainterFactoryForTac.drawPlanet unknown planet %@", key);
		[super drawPlanet:planet inRect:Rect];
		return;
	}        
	
	// assume the plaents are in squares and heigth = width top-down
	// but we need the top most (and cocoa is flipped!)
	float side = [imgPlanet size].width;
	frameRect = NSMakeRect( 0, ([imgPlanet size].height - side), side , side); 
      
    // draw it
    [imgPlanet drawInRect:Rect fromRect:frameRect operation: NSCompositeSourceOver fraction:1.0];    
		
	// ----
	// folows a copy of Netrek, i should put this is seperate methods and use the overloading
	// but for now it's a manual keeping the same
	//-----
		
    // check special icons   
    if ([planet flags] & PLANET_REPAIR) {
        // draw a wrench on top
        NSRect targetRect = Rect;
        // get the aspect ratio
        float delta = [imgRepair size].height / frameRect.size.height; // eg repair is 1/4 the planet
        //delta *= 2; // i find the icons very small
        targetRect.size.height *= delta;
        delta = [imgRepair size].width / frameRect.size.width; // eg repair is half the planet
        //delta *= 2; // i find the icons very small
        targetRect.size.width *= delta;
        
        // center rect above planet
        targetRect.origin.y -= targetRect.size.height;
        // and centre
        targetRect.origin.x += (Rect.size.width - targetRect.size.width) / 2;
        // draw
        [imgRepair drawInRect:targetRect fromRect:NSMakeRect(0, 0, [imgRepair size].width, [imgRepair size].height) operation: NSCompositeSourceOver fraction:1.0];
    }
	
    if ([planet flags] & PLANET_FUEL) {
        // draw a fuel to the left
        NSRect targetRect = Rect;
        // get the aspect ratio
        float delta = [imgFuel size].height / frameRect.size.height; // eg repair is 1/4 the planet
        //delta *= 2; // i find the icons very small
        targetRect.size.height *= delta;
        delta = [imgFuel size].width / frameRect.size.width; // eg repair is half the planet
        //delta *= 2; // i find the icons very small
        targetRect.size.width *= delta;
        
        // rect next to planet
        targetRect.origin.x -= targetRect.size.width;
        // and centre
        targetRect.origin.y += (Rect.size.height - targetRect.size.height) / 2;
        // draw
        [imgFuel drawInRect:targetRect fromRect:NSMakeRect(0, 0, [imgFuel size].width, [imgFuel size].height) operation: NSCompositeSourceOver fraction:1.0];
    }
    
    if ([planet armies] > 4) {
        // draw a armies to the left
        NSRect targetRect = Rect;
        // get the aspect ratio
        float delta = [imgArmy size].height / frameRect.size.height; // eg repair is 1/4 the planet
        //delta *= 2; // i find the icons very small
        targetRect.size.height *= delta;
        delta = [imgArmy size].width / frameRect.size.width; // eg repair is half the planet
        //delta *= 2; // i find the icons very small
        targetRect.size.width *= delta;
        
        // rect next to planet
        targetRect.origin.x += Rect.size.width;
        // and centre
        targetRect.origin.y += (Rect.size.height - targetRect.size.height) / 2;
        // draw
        [imgArmy drawInRect:targetRect fromRect:NSMakeRect(0, 0, [imgArmy size].width, [imgArmy size].height) operation: NSCompositeSourceOver fraction:1.0];
    }
	
}

- (void)   drawBackgroundImageInRect:(NSRect) Rect {
	
	// do nothing
	// must clear image
	// at least clear
    [[NSColor blackColor] set];
    NSRectFill(Rect);
}

- (void) drawLabelBackgroundForRect:(NSRect)aRect {
	
	// do nothing
}


@end
