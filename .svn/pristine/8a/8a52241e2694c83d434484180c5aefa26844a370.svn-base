//
//  AppController.m
//  HUDWindow
//
//  Created by Matt Gemmell on 11/03/2006.
//  Copyright 2006 Magic Aubergine. All rights reserved.
//

#import "LLHUDWindowController.h"

@implementation LLHUDWindowController

-(LLHUDWindow*) createWindowWithTextFieldWithSize:(NSSize) windowSize {
	
	NSSize screenSize = [[NSScreen mainScreen] frame].size;
	
	// left side full screen
	NSRect windowFrame = NSMakeRect(0, screenSize.height - windowSize.height, windowSize.width, windowSize.height);
	
	return [self createWindowWithTextFieldInFrame:windowFrame];
}

-(LLHUDWindow*) createWindowWithTextFieldInFrame:(NSRect) windowFrame {
		    
    // Create a HUDWindow.
	[window release];
	// Note: the styleMask is ignored; NSBorderlessWindowMask is always used.
    window = [[LLHUDWindow alloc] initWithContentRect:windowFrame 
											styleMask:NSBorderlessWindowMask 
											  backing:NSBackingStoreBuffered 
												defer:NO];
    
    // Add some text to the window.
    float textHeight = 20.0;
    [textField release];  // its retained, by the window
	textField = [[NSTextField alloc] initWithFrame:NSMakeRect(textHeight / 2.0, 0.0, windowFrame.size.width, windowFrame.size.height - textHeight)];
	
    [[window contentView] addSubview:textField];
    [textField setEditable:NO];
    [textField setTextColor:[NSColor whiteColor]];
    [textField setDrawsBackground:NO];
    [textField setBordered:NO];
    
    // Set the window's title and display it.
    [window setTitle:@"Default title"];
    //[window orderFront:self]; // initially hide ourselfs
	
	return window;	
}

-(NSTextField*) textField {
	return textField;
}

-(LLHUDWindow*) window {
	return window;
}

@end
