//
//  FullScreenBackgroundWindow.m
//  MacTrek
//
//  Created by Aqua on 16/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLFullScreenBackgroundWindow.h"

//#define DEBUG 

@implementation LLFullScreenBackgroundWindow

//In Interface Builder we set CustomWindow to be the class for our window, so our own initializer is called here.
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle 
                  backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
   
    // default we can become key
    // Custom windows that use the NSBorderlessWindowMask can't become key by default.  Therefore, controls in such windows
    // won't ever be enabled by default.  Thus, we override this method to change that.
    canBecomeKeyWindow = YES;
    
    NSWindow *result;
    
	//Call NSWindow's version of this function, but pass in the all-important value of NSBorderlessWindowMask
	//for the styleMask so that the window doesn't have a title bar
	result = [super initWithContentRect:contentRect 
                              styleMask:NSBorderlessWindowMask 
                                backing:NSBackingStoreBuffered 
                                  defer:NO];
    
    //Set the background color to clear so that (along with the setOpaque call below) we can see through the parts
    //of the window that we're not drawing into
    //[result setBackgroundColor: [NSColor clearColor]];
    // create a black background
    [result setBackgroundColor: [NSColor clearColor]];
    
    //This next line pulls the window up to the front on top of other system windows.  This is how the Clock app behaves;
    //generally you wouldn't do this for windows unless you really wanted them to float above everything.
    //[result setLevel: NSScreenSaverWindowLevel];
    //[result setLevel:NSMainMenuWindowLevel];
    
    // make sure we track the mouse
    [result setAcceptsMouseMovedEvents:YES];
    [result setIgnoresMouseEvents:NO];
    
    //Let's start with no transparency for all drawing into the window
    [result setAlphaValue:1.0];
    
    //but let's turn off opaqueness so that we can see through the parts of the window that we're not drawing into
    //[result setOpaque:NO];
    [result setOpaque:YES];
    
    //and while we're at it, make sure the window has no shadow
    [result setHasShadow:NO];
    
    //the menu was hidden anyway but remove it
    [NSMenu setMenuBarVisible:NO];
    
    // store the pointer
    //self = result;    
    
	return result;
}

- (void) awakeFromNib {
    
    //set the screenframe          
#ifndef DEBUG
    //-----------------------------------------------------------
    // Disable this to debug normal size
    //-----------------------------------------------------------
	NSRect frame1 = [[LLScreenResolution defaultScreenResolution] frameForPrimairyDisplay];	
	NSRect frame2 = [[NSScreen mainScreen] frame];
	[self setFrame:frame1 display:YES];
	LLLog(@"LLFullScreenBackgroundWindow.awakeFromNib %x %x %x %x", frame2.origin.x, 
		  frame2.origin.y, frame2.size.width, frame2.size.height);
    //-----------------------------------------------------------
#endif
	
}

- (BOOL) canBecomeKeyWindow
{
	return canBecomeKeyWindow;
}

- (void) setCanBecomeKeyWindow:(bool)can {
    canBecomeKeyWindow = can;
}

@end
