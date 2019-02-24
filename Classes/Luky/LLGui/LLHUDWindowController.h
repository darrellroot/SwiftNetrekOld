//
//  AppController.h
//  HUDWindow
//
//  Created by Matt Gemmell on 11/03/2006.
//  Copyright 2006 Magic Aubergine. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LLHUDWindow.h"

@interface LLHUDWindowController : NSObject {
    LLHUDWindow *window;
	NSTextField *textField;
}

-(LLHUDWindow*) createWindowWithTextFieldWithSize:(NSSize) windowSize;
-(LLHUDWindow*) createWindowWithTextFieldInFrame:(NSRect) windowFrame;

-(NSTextField*) textField;
-(LLHUDWindow*) window;

@end
