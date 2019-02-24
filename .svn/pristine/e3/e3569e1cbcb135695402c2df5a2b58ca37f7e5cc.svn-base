//
//  PainterFactory.h
//  MacTrek
//
//  Created by Aqua on 19/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Data.h"
#import "Phaser.h"
#import "BaseClass.h"
#import "Luky.h"
#import "Math.h"
#include <unistd.h>
#include <stdlib.h>
#include "SimpleTracker.h"
#import "LLBar.h"


#define PF_DEFAULT_BACKGROUND_IMAGE_SIZE NSMakeSize(100, 100)
#define PF_ALERT_BORDER_WIDTH 2
#define PF_TRIANGLE_WIDTH   600.0
#define PF_TRIANGLE_HEIGHT  400.0
#define PF_MIN_ALPHA_VALUE  0.05

@interface PainterFactory : BaseClass {
    bool debugLabels;
    bool simple; // used for an overview map, omits torps, shields etc.    
    NSPoint backGroundStartPoint;
    LLTrigonometry *trigonometry;
    LLShapes *shapes;
    int alert;
    NSBezierPath *line;
    NSBezierPath *dashedLine; 
    NSMutableDictionary *normalStateAttribute;
    NSRect galaxy;
	bool accelerate;
	LLBar *bar;
}

// internal
- (void) setSimplifyDrawing:(bool)simpleDraw;
- (void) setDebugLabels:(bool)debug;
- (bool) debugLabels;
- (void) cacheImagesInSeperateThread:(id)sender;
- (void) setAccelerate:(bool)accel;

// helper
- (NSPoint) centreOfRect:(NSRect)aRect;

// conversions
- (NSPoint) viewPointFromGamePoint:(NSPoint)point viewRect:(NSRect)bounds 
             gamePosInCentreOfView:(NSPoint)centrePos withScale:(int)scale;
- (NSPoint) gamePointFromViewPoint:(NSPoint)point viewRect:(NSRect)bounds 
             gamePosInCentreOfView:(NSPoint)centrePos withScale:(int)scale;
- (NSSize)  gameSizeFromViewSize:(NSSize)rect withScale:(int)scale;
- (NSSize)  viewSizeFromGameSize:(NSSize)rect withScale:(int)scale;

// information
- (NSRect) gameRectAround:(NSPoint)gamePoint forView:(NSRect)bounds withScale:(int)scale;

// draw routines
- (void) drawRect:(NSRect)drawingBounds ofViewBounds:(NSRect)viewBounds whichRepresentsGameBounds:(NSRect)gameBounds 
        withScale:(int)scale;
- (void) drawAlertBorder:(NSRect) bounds forMe:(Player *)me;
- (void) drawBackgroundInRect:(NSRect) drawingBounds ofViewBounds:(NSRect)viewBounds forMe:(Player*) me withScale:(int)scale;
- (void) drawGalaxyEdgesInRect:(NSRect) drawingBounds forGameRect:(NSRect)gameBounds ofViewBounds:(NSRect)viewBounds withScale:(int)scale;
- (void) drawPlanetsInRect:(NSRect)drawingBounds forGameRect:(NSRect)gameBounds ofViewBounds:(NSRect)viewBounds withScale:(int)scale;
- (void) drawPlayersInRect:(NSRect)drawingBounds forGameRect:(NSRect)gameBounds ofViewBounds:(NSRect)viewBounds  withScale:(int)scale;
- (void) drawTorpsInRect:(NSRect)drawingBounds forGameRect:(NSRect)gameBounds ofViewBounds:(NSRect)viewBounds  withScale:(int)scale ;
- (void) drawPlasmasInRect:(NSRect)drawingBounds forGameRect:(NSRect)gameBounds ofViewBounds:(NSRect)viewBounds  withScale:(int)scale;
- (void)drawLockInRect:(NSRect)drawingBounds forGameRect:(NSRect)gameBounds ofViewBounds:(NSRect)viewBounds withScale:(int)scale ;
- (void) rotateAndDrawPlayer:(Player*) player inRect:(NSRect) Rect;

// should be overwritten by subclasses
- (void)   drawPlayer:(Player*) player inRect:(NSRect) Rect;
- (void)   drawShieldWithStrenght: (float)shieldPercentage inRect:(NSRect) Rect andAlpha:(float)alpha;
- (void)   drawHullWithStrenght: (float)percentage inRect:(NSRect) Rect andAlpha:(float)alpha;
- (void)   drawLabelForPlanet:(Planet*)planets belowRect:(NSRect)planetViewBounds;
- (void)   drawLabelForPlayer:(Player*)player belowRect:(NSRect)playerViewBounds;
- (void)   drawPlanet:(Planet*) planet inRect:(NSRect) Rect;
// @method drawTorp
// @abstract draws all torpedo's in the actual bounds.
// @param drawingBounds draw only in this area
// @param gameBounds which represents these game bounds
// @param viewBounds these are the total view's  bounds
// @param scale the scale used to draw
- (void)   drawTorp:(Torp*) torp       inRect:(NSRect) Rect;
- (void)   drawPlasma:(Plasma*) plasma inRect:(NSRect) Rect;
- (void)   drawBackgroundImageInRect:(NSRect) Rect;
// @method maxFuseForMovingTorp
// @abstract returns the number of frames to display for a moving torp  
- (int)    maxFuseForMovingTorp;   
- (int)    maxFuseForExplodingTorp;
- (int)    maxFuseForMovingPlasma;   
- (int)    maxFuseForExplodingPlasma;
- (int)    maxFuseForMovingPlayer;   
- (int)    maxFuseForExplodingPlayer;
- (int)    maxFuseForPlanet;

//  could be overwritten to match the size of the subclasses artwork
//
- (float) alphaForPlayer:(Player *)player;
- (NSString *)labelForPlanet:(Planet*)planet;
- (NSString*) labelForPlayer:(Player*)player;
- (NSString*) label2ForPlayer:(Player*)player;
- (NSString*) label3ForPlayer:(Player*)player;
- (void) drawLabelBackgroundForRect:(NSRect)aRect;
- (void) drawLabel:(NSString*)label inRect:(NSRect)aRect withColor:(NSColor*)col;
- (void) drawLabel:(NSString*)label atPoint:(NSPoint)aPoint withColor:(NSColor*)col;
- (void) drawShipType:(int)type forTeamId:(int) teamId withCloakPhase:(int)cloakPhase inRect:(NSRect)Rect;
- (void) drawCircleWithCompletion: (float)shieldPercentage inRect:(NSRect) Rect thickness:(float)thick andAlpha:(float)alpha;
- (void) drawFuelGaugeOfPlayer:(Player*) player rightOfRect:(NSRect)aRect;
- (void) drawDetCircleAround:(NSPoint)centre withScale:(int) scale;
// and the stamping algorithm (will use defaults otherwise)
- (NSSize) backGroundImageSize;
// could be overwritten if you want different colors
- (NSColor*) colorForTeam:(Team*)team;
// overrule in subclass to cache the images
- (void) cacheImages;
// interesting zoom sizes
- (int) maxScale;
- (int) minScale;
// handy
- (void) prepareForDraw;
- (void) postpareForDraw;


@end
