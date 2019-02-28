//
//  MapView.m
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//
/*
#import "MapView.h"


@implementation MapView

NSRect gameBounds;

- (void) awakeFromNib {
    [super awakeFromNib];
    
    // use larger steps to zoom
    step *= 2; // twice
    
    [self setScaleFullView];
    // should disable torps etc
    
    // find out what are the gameBounds
    gameBounds.origin.x = 0;
    gameBounds.origin.y = 0;
    gameBounds.size.width = UNIVERSE_PIXEL_SIZE;
    gameBounds.size.height = UNIVERSE_PIXEL_SIZE;

    centerPoint = NSMakePoint(UNIVERSE_PIXEL_SIZE/2, UNIVERSE_PIXEL_SIZE/2);
    
    // use the default painter here, we could use the same theme....
    // $$ are we sure?
    painter = [[PainterFactoryForTac alloc] init];
	[painter awakeFromNib];
    
    // use simpler drawing (eg omit weapons)
    [painter setSimplifyDrawing:YES];

}


- (NSPoint) gamePointRepresentingCentreOfView {
	//LLLog(@"MapView.gamePointRepresentingCentreOfView entered");
    return centerPoint;
}

- (void) keyDown:(NSEvent *)theEvent {
    LLLog(@"MapView.keyDown entered");
    [super keyDown:theEvent];
}

// draw the view 
// without locking the read thread !!
- (void)drawRect:(NSRect)aRect {
    [painter drawRect:aRect ofViewBounds:[self bounds] whichRepresentsGameBounds:gameBounds withScale:scale];
}

- (void) mouseDown:(NSEvent *)theEvent {
	
	// command click moves center point BUG 1636263
	// (wouldn't it be cool if you could drag?)
	if ( [theEvent modifierFlags] & NSCommandKeyMask ) {
		// where you click becomes the center
		centerPoint = [painter gamePointFromViewPoint:[self mousePos] 
                                             viewRect:[self bounds]
                                gamePosInCentreOfView:[self gamePointRepresentingCentreOfView] 
                                            withScale:scale]; 
		
		// set up the gamebounds based on my position
		gameBounds = [painter gameRectAround:[self gamePointRepresentingCentreOfView]
									 forView:[self bounds]
								   withScale:scale]; 
	}
	else {
		// fire torp
		[super mouseDown:theEvent];
	}
   
}

- (void) scrollWheel:(NSEvent *)theEvent {

    [super scrollWheel:theEvent];
    // set up the gamebounds based on my position AND SCALE
    gameBounds = [painter gameRectAround:[self gamePointRepresentingCentreOfView]
                                 forView:[self bounds]
                               withScale:scale]; 
}


- (void) otherMouseDown:(NSEvent *)theEvent {
    // no phaser
}

@end
 
*/
