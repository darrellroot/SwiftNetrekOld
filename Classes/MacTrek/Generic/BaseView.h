//
//  BaseView.h
//  MacTrek
//
//  Created by Aqua on 24/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Luky.h"
#import "Universe.h"
#import "MTMacroHandler.h"


@interface BaseView : LLView {
    LLNotificationCenter *notificationCenter;
    Universe *universe;
	MTMacroHandler *macroHandler;
    NSTrackingRectTag myCursorRect;
}

- (NSPoint) mousePos;
- (void) stopTrackingMouse;
- (void) startTrackingMouse;
// macroHandler needs this
- (void) setFeatureList:(FeatureList *)list;

@end
