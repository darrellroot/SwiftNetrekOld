//
//  PainterFactoryForNetrek.m
//  MacTrek
//
//  Created by Aqua on 20/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PainterFactoryForNetrek.h"


@implementation PainterFactoryForNetrek

- (id) init {
    self = [super init];
    if (self != nil) {
        filter = [[LLColorFilter alloc] init];
		iconStaticScaler = 2; // icons are small
    }
    return self;
}

- (NSImage *)loadImage:(NSString*)imageName {
    
    // load from disk
    NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
    NSString *pathToImage = [NSString stringWithFormat:@"%@/ImagesPainter1%@", pathToResources, imageName];
    
    NSImage *rawImage = [[NSImage alloc] initWithContentsOfFile:pathToImage];
    
    // make black background transparent
    
    NSImage *filterdImage = nil;
    /*
    filterdImage = [filter replaceColor:[NSColor blackColor] 
                                       withColor:[NSColor clearColor] 
                                         inImage:rawImage 
                                      ignoreAlha:YES]; */
    if (filterdImage == nil) {
        // something went wrong take, raw input
        return rawImage;
    }
    
    [rawImage release];
    
    return filterdImage;
}

- (NSImage *) cacheImage:(NSString*)imageName {
    NSImage *image = [self loadImage:imageName];
    [image setFlipped:YES];
    [image lockFocus];
    [image unlockFocus];
    return image;
}

- (void) cacheImages {
    
    // load them
    imgExplodeStarBase = [self cacheImage:@"/Misc/starbaseExplode.png"]; // use transparent version 
    imgShipCloak       = [self cacheImage:@"/Misc/cloak.bmp"]; // not yet used
    imgExplodePlayer   = [self cacheImage:@"/Misc/shipExplode.png"]; // use transparent version 
    imgShipsOri        = [self cacheImage:@"/Ships/oriship.png"]; // use transparent version 
    imgShipsFed        = [self cacheImage:@"/Ships/fedship.png"]; // use transparent version 
    imgShipsKli        = [self cacheImage:@"/Ships/kliship.png"]; // use transparent version 
    imgShipsRom        = [self cacheImage:@"/Ships/romship.png"]; // use transparent version 
    imgShipsInd        = [self cacheImage:@"/Ships/indship.png"]; // use transparent version 
    imgExplodeTorp     = [self cacheImage:@"/Weapons/torpExplode.png"]; // use transparent version 
    imgPlasma          = [self cacheImage:@"/Weapons/plasma.png"]; // use transparent version 
    imgTorp            = [self cacheImage:@"/Weapons/torp.png"]; // use transparent version 
    imgExplodePlasma   = [self cacheImage:@"/Weapons/plasmaExplode.png"]; // use transparent version 
    imgFuel            = [self cacheImage:@"/Planets/fuel.bmp"]; 
    imgPlanetRock1     = [self cacheImage:@"/Planets/rock1.bmp"]; 
    imgPlanetRock2     = [self cacheImage:@"/Planets/rock2.bmp"];
    imgPlanetHomeOri   = [self cacheImage:@"/Planets/orion.bmp"]; 
    imgPlanetHomeKli   = [self cacheImage:@"/Planets/klingus.bmp"]; 
    imgPlanetHomeRom   = [self cacheImage:@"/Planets/romulus.bmp"]; 
    imgPlanetUnknown   = [self cacheImage:@"/Planets/unknown.bmp"];
    imgArmy            = [self cacheImage:@"/Planets/army.bmp"]; 
    imgPLanetHomeFed   = [self cacheImage:@"/Planets/earth.bmp"]; 
    imgPlanetAgri1     = [self cacheImage:@"/Planets/agri1.bmp"]; 
    imgPlanetAgri2     = [self cacheImage:@"/Planets/agri2.bmp"]; 
    imgRepair          = [self cacheImage:@"/Planets/wrench.bmp"]; 
}

- (int)    maxFuseForMovingPlayer {
    return 1;
}

- (int)    maxFuseForExplodingPlayer {
    int frameDim = [imgExplodePlayer size].width; 
    
    return PFN_SLOW_MOTION_FACTOR_EXPLODE * [imgExplodePlayer size].height / frameDim;
} 

- (void)   drawPlayer:(Player*) player inRect:(NSRect) Rect {
      
    // special
    if ([player status] == PLAYER_EXPLODE) {
        
        NSImage *imgShips;
        if ([[player ship] type] == SHIP_SB) {
            imgShips = imgExplodeStarBase;
        } else {
            imgShips = imgExplodePlayer;
        }
        
        // frames are stored horz
        NSRect shipRect = NSMakeRect( 0, 0, [imgShips size].width, [imgShips size].width);
        // move to the proper frame
        shipRect.origin.y += ([player fuse] / PFN_SLOW_MOTION_FACTOR_EXPLODE) * [imgShips size].width ;
        // draw
        [imgShips drawInRect:Rect fromRect:shipRect operation: NSCompositeSourceOver fraction:1.0];   
        return;
    }
	else {		
		//bool fullyCloaked = ([player flags] & PLAYER_CLOAK);
		bool fullyCloaked = ([player cloakPhase] == (PLAYER_CLOAK_PHASES - 1));
		if ([player isMe] && fullyCloaked) { 
			// i am cloaked
			//LLLog(@"PainterFactoryForNetrek.drawPlayer CLOAK PHASE %d", [player cloakPhase]);
			[imgShipCloak drawInRect:Rect fromRect:NSMakeRect( 0, 0, [imgShipCloak size].width, [imgShipCloak size].width) 
						   operation:NSCompositeSourceOver fraction:1.0];			
		} else {			
			[self drawShipType:[[player ship] type] forTeamId:[[player team] teamId] withCloakPhase:[player cloakPhase] inRect:Rect]; 
		}
	}

}

- (void) drawShipType:(int)type forTeamId:(int) teamId withCloakPhase:(int)cloakPhase inRect:(NSRect)Rect {
    
    // first get the banner of ship images
    NSImage *imgShips;
    switch (teamId) {
    case TEAM_FED:
        imgShips = imgShipsFed;
        break;
    case TEAM_KLI:
        imgShips = imgShipsKli;
        break;
    case TEAM_ROM:
        imgShips = imgShipsRom;
        break;
    case TEAM_ORI:
        imgShips = imgShipsOri;
        break;
    default:
        imgShips = imgShipsInd;
        break;
    }
    
    // get the rigth image 
    // assume the ships are in squares and heigth = width
    NSRect shipRect = NSMakeRect( 0, 0, [imgShips size].height ,[imgShips size].height); 
    // move the rect to the proper ship e.g a dd is type 1 and moves the rect 1 width to the right
    shipRect.origin.x += (type * shipRect.size.width);
    
    // calculate the alpha for cloak
    float alpha = 1.0;
    if (cloakPhase > 0) {
        // find out aplha value PF_MIN_ALPHA_VALUE (0.1) means fully cloaked
        // 1.0 means fully uncloaked
        alpha -= (((1.0 - PF_MIN_ALPHA_VALUE) * cloakPhase) / PLAYER_CLOAK_PHASES);
    }

	// normal draw
    if (shipRect.origin.x < [imgShips size].width) {
		[imgShips drawInRect:Rect fromRect:shipRect operation: NSCompositeSourceOver fraction:alpha];   
	} else {
		// i want to draw a ship that is not in the image, fall back to super class
		Player *p;		
		p = [[[Player alloc] init] autorelease];		
		[p setTeam:[universe teamWithId:teamId]];
		[super drawPlayer:p inRect:Rect];
	}    
}

- (int)    maxFuseForMovingTorp {
    int torpDim = [imgTorp size].width / 6; 
    
    return PFN_SLOW_MOTION_FACTOR_MOVE * [imgTorp size].height / torpDim;     
}

- (int)    maxFuseForExplodingTorp {
    int torpDim = [imgExplodeTorp size].width / 6; 
    
    return PFN_SLOW_MOTION_FACTOR_EXPLODE * [imgExplodeTorp size].height / torpDim;     
}

- (void)   drawTorp:(Torp*) torp       inRect:(NSRect) Rect {
    
    NSImage *frames;
    int     fusesPerFrame;
    
    if ([torp status] == TORP_EXPLODE) {
        frames = imgExplodeTorp;
        fusesPerFrame = PFN_SLOW_MOTION_FACTOR_EXPLODE;
    } else {
        frames = imgTorp;
        fusesPerFrame = PFN_SLOW_MOTION_FACTOR_MOVE;
    }
    
    // get the rigth image 
    // assume the torps are in image [my|fed|indiv|kli|ori|rom] (6)
    int torpDim = [frames size].width / 6;   
    NSRect torpRect = NSMakeRect( 0, 0, torpDim, torpDim); 
    
    // move the rect to the proper team
    if (![[torp owner] isMe]) {
        switch ([[[torp owner] team] teamId]) {
            case TEAM_FED:
                torpRect.origin.x += 1 * torpDim;
                break;
            case TEAM_KLI:
                torpRect.origin.x += 3 * torpDim;
                break;
            case TEAM_ROM:
                torpRect.origin.x += 5 * torpDim;
                break;
            case TEAM_ORI:
                torpRect.origin.x += 4 * torpDim;
                break;
            default:
                torpRect.origin.x += 2 * torpDim;
                break;
        }
    }
    
    // move to the proper frame
    torpRect.origin.y += ([torp fuse] / fusesPerFrame) * torpDim ;
    
    [frames drawInRect:Rect fromRect:torpRect operation: NSCompositeSourceOver fraction:1.0];   
}

- (int)    maxFuseForMovingPlasma {
    int plasmaDim = [imgPlasma size].width / 6; 
    
    return PFN_SLOW_MOTION_FACTOR_MOVE * [imgPlasma size].height / plasmaDim;     
}

- (int)    maxFuseForExplodingPlasma {
    int plasmaDim = [imgExplodePlasma size].width / 6; 
    
    return PFN_SLOW_MOTION_FACTOR_EXPLODE * [imgExplodePlasma size].height / plasmaDim;     
}

- (void)   drawPlasma:(Plasma*) plasma       inRect:(NSRect) Rect {
    
    NSImage *frames;
    int     fusesPerFrame;
    
    if ([plasma status] == PLASMA_EXPLODE) {
        frames = imgExplodePlasma;
        fusesPerFrame = PFN_SLOW_MOTION_FACTOR_EXPLODE;
    } else {
        frames = imgPlasma;
        fusesPerFrame = PFN_SLOW_MOTION_FACTOR_MOVE;
    }
    
    // get the rigth image 
    // assume the plasmas are in image [my|fed|indiv|kli|ori|rom] (6)
    int plasmaDim = [frames size].width / 6;   
    NSRect plasmaRect = NSMakeRect( 0, 0, plasmaDim, plasmaDim); 
    
    // move the rect to the proper team
    if (![[plasma owner] isMe]) {
        switch ([[[plasma owner] team] teamId]) {
            case TEAM_FED:
                plasmaRect.origin.x += 1 * plasmaDim;
                break;
            case TEAM_KLI:
                plasmaRect.origin.x += 3 * plasmaDim;
                break;
            case TEAM_ROM:
                plasmaRect.origin.x += 5 * plasmaDim;
                break;
            case TEAM_ORI:
                plasmaRect.origin.x += 4 * plasmaDim;
                break;
            default:
                plasmaRect.origin.x += 2 * plasmaDim;
                break;
        }
    }

    // move to the proper frame
    plasmaRect.origin.y += ([plasma fuse]  / fusesPerFrame) * plasmaDim;
      
    [frames drawInRect:Rect fromRect:plasmaRect operation: NSCompositeSourceOver fraction:1.0];   
}

- (int)    maxFuseForPlanet {
    
    // only unknown planets have a image
    int frameDim = [imgPlanetUnknown size].width; 
    int frames = [imgPlanetUnknown size].height / frameDim;
    
    return PFN_SLOW_MOTION_FACTOR_PLANET * frames;
}

- (void)   drawPlanet:(Planet*) planet inRect:(NSRect) Rect { 

    NSImage *frames;
    NSRect frameRect;
    
    // do we know this planet?    
    int mask = [[[universe playerThatIsMe] team] bitMask];
    if (([planet info] & mask) == 0) {
        // nope
        frames = imgPlanetUnknown;
        frameRect = NSMakeRect( 0, 0, [imgPlanetUnknown size].width, [imgPlanetUnknown size].width);
        frameRect.origin.y += ([planet fuse] / PFN_SLOW_MOTION_FACTOR_PLANET) * [imgPlanetUnknown size].width;
        //LLLog(@"PainterFactoryForNetrek.drawPlanet %@ frame %d", [planet name], ([planet fuse] / PFN_SLOW_MOTION_FACTOR_PLANET));
    } else {
        // type is HOME|ARI|ROCK
        if ([planet flags] & PLANET_AGRI) {
            // pick one of the two images
            // more or less at random
            if (([planet planetId] % 2) == 0) {
                frames = imgPlanetAgri1;
            } else {
                frames = imgPlanetAgri2;
            }
        } else {
            // it's bare rock
            if (([planet planetId] % 2) == 0) {
                frames = imgPlanetRock1;
            } else {
                frames = imgPlanetRock2;
            }
        }
        
        // also check if it is a homeplanet, which would overrule the previous
        if        ([[planet name] isEqualToString:@"Earth"]) {
            frames = imgPLanetHomeFed;
        } else if ([[planet name] isEqualToString:@"Klingus"]){
            frames = imgPlanetHomeKli;
        } else if ([[planet name] isEqualToString:@"Romulus"]){
            frames = imgPlanetHomeRom;
        } else if ([[planet name] isEqualToString:@"Orion"]){
            frames = imgPlanetHomeOri;
        }
            
        // set the framerect
        frameRect = NSMakeRect( 0, 0, [frames size].height, [frames size].height);
        
        // pick the color depending on the team
        switch ([[planet owner] teamId]) {
            case TEAM_FED:
                frameRect.origin.x += 0 * frameRect.size.width;
                break;
            case TEAM_KLI:
                frameRect.origin.x += 2 * frameRect.size.width;
                break;
            case TEAM_ROM:
                frameRect.origin.x += 4 * frameRect.size.width;
                break;
            case TEAM_ORI:
                frameRect.origin.x += 3 * frameRect.size.width;
                break;
            case TEAM_IND:
                frameRect.origin.x += 1 * frameRect.size.width;
                break;
            default:
                LLLog(@"PainterFactoryForNetrek.drawPlanet %@ has no team?", [planet name]);
                frameRect.origin.x += 1 * frameRect.size.width;
                break;
        }
    }
    
    // draw it
    [frames drawInRect:Rect fromRect:frameRect operation: NSCompositeSourceOver fraction:1.0];    

    // check special icons   
    if ([planet flags] & PLANET_REPAIR) {
        // draw a wrench on top
        NSRect targetRect = Rect;
        // get the aspect ratio
        float delta = [imgRepair size].height / frameRect.size.height; // eg repair is 1/4 the planet
        delta *= iconStaticScaler; // i find the icons very small
        targetRect.size.height *= delta;
        delta = [imgRepair size].width / frameRect.size.width; // eg repair is half the planet
        delta *= iconStaticScaler; // i find the icons very small
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
        delta *= iconStaticScaler; // i find the icons very small
        targetRect.size.height *= delta;
        delta = [imgFuel size].width / frameRect.size.width; // eg repair is half the planet
        delta *= iconStaticScaler; // i find the icons very small
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
        delta *= iconStaticScaler; // i find the icons very small
        targetRect.size.height *= delta;
        delta = [imgArmy size].width / frameRect.size.width; // eg repair is half the planet
        delta *= iconStaticScaler; // i find the icons very small
        targetRect.size.width *= delta;
        
        // rect next to planet
        targetRect.origin.x += Rect.size.width;
        // and centre
        targetRect.origin.y += (Rect.size.height - targetRect.size.height) / 2;
        // draw
        [imgArmy drawInRect:targetRect fromRect:NSMakeRect(0, 0, [imgArmy size].width, [imgArmy size].height) operation: NSCompositeSourceOver fraction:1.0];
    }

}

@end
