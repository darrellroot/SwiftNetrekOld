//
//  PainterFactoryForNetrek.h
//  MacTrek
//
//  Created by Aqua on 20/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "PainterFactory.h"
#import "LLColorFilter.h"

// 1 is real time, 2 is delay by factor 2 etc.
#define PFN_SLOW_MOTION_FACTOR_EXPLODE 8
#define PFN_SLOW_MOTION_FACTOR_MOVE 1
#define PFN_SLOW_MOTION_FACTOR_PLANET 1

@interface PainterFactoryForNetrek : PainterFactory {

    NSImage *imgExplodeStarBase;
    NSImage *imgShipCloak;
    NSImage *imgExplodePlayer;
    NSImage *imgShipsOri;
    NSImage *imgShipsFed;
    NSImage *imgShipsKli;
    NSImage *imgShipsRom;
    NSImage *imgShipsInd;
    NSImage *imgExplodeTorp;
    NSImage *imgPlasma;
    NSImage *imgTorp;
    NSImage *imgExplodePlasma;
    NSImage *imgFuel;
    NSImage *imgPlanetRock1;
    NSImage *imgPlanetRock2;
    NSImage *imgPlanetHomeOri;
    NSImage *imgPlanetHomeKli;
    NSImage *imgPlanetHomeRom;
    NSImage *imgPlanetUnknown;
    NSImage *imgArmy;
    NSImage *imgPLanetHomeFed;
    NSImage *imgPlanetAgri1;
    NSImage *imgPlanetAgri2;
    NSImage *imgRepair;
    
    LLColorFilter *filter;
    int      iconStaticScaler;
}

- (NSImage *)loadImage:(NSString*)imageName;
- (NSImage *) cacheImage:(NSString*)imageName;
- (void) drawShipType:(int)type forTeamId:(int) teamId withCloakPhase:(int)cloakPhase inRect:(NSRect)Rect;

@end
