//
//  LLScreenResolution.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 11/03/2007.
//  Copyright 2010 Luky Soft. All rights reserved.
//

#import "LLScreenResolution.h"


@implementation LLScreenResolution

LLScreenResolution* defaultScreenResolution;


+ (LLScreenResolution*) defaultScreenResolution {
    if (defaultScreenResolution == nil) {
        defaultScreenResolution = [[LLScreenResolution alloc] init];
    }
    return defaultScreenResolution;
}

- (NSRect) frameForPrimairyDisplay {
		
	NSRect frame = NSMakeRect(0, 0, CGDisplayPixelsWide(CGMainDisplayID()), CGDisplayPixelsHigh(CGMainDisplayID()));
	return frame;
}

- (size_t) displayBitsPerPixelForMode: (CGDisplayModeRef) mode {
	
	size_t depth = 0;
	
	CFStringRef pixEnc = CGDisplayModeCopyPixelEncoding(mode);
	if(CFStringCompare(pixEnc, CFSTR(IO32BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
		depth = 32;
	else if(CFStringCompare(pixEnc, CFSTR(IO16BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
		depth = 16;
	else if(CFStringCompare(pixEnc, CFSTR(IO8BitIndexedPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
		depth = 8;
	
	return depth;
}

- (size_t) displayBitsPerPixel:(CGDirectDisplayID) displayId {
	
	CGDisplayModeRef mode = CGDisplayCopyDisplayMode(displayId);
	
	return [self displayBitsPerPixelForMode: mode];
}

- (struct screenMode) screenModeOnPrimairyDisplay {
		
	struct screenMode mode;
	
	mode.width = CGDisplayPixelsWide(CGMainDisplayID());
	mode.height = CGDisplayPixelsHigh(CGMainDisplayID());
	mode.bitsPerPixel = [self displayBitsPerPixel: CGMainDisplayID() ];
	
	return mode;
}

- (CGDisplayModeRef) bestMatchForMode: (struct screenMode) screenMode {
	
	bool exactMatch = false;
	
    // Get a copy of the current display mode
	CGDisplayModeRef displayMode = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
	
    // Loop through all display modes to determine the closest match.
    // CGDisplayBestModeForParameters is deprecated on 10.6 so we will emulate it's behavior
    // Try to find a mode with the requested depth and equal or greater dimensions first.
    // If no match is found, try to find a mode with greater depth and same or greater dimensions.
    // If still no match is found, just use the current mode.
    CFArrayRef allModes = CGDisplayCopyAllDisplayModes(kCGDirectMainDisplay, NULL);
    for(int i = 0; i < CFArrayGetCount(allModes); i++)	{
		CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(allModes, i);

		if([self displayBitsPerPixelForMode: mode] != screenMode.bitsPerPixel)
			continue;
		
		if((CGDisplayModeGetWidth(mode) >= screenMode.width) && (CGDisplayModeGetHeight(mode) >= screenMode.height))
		{
			displayMode = mode;
			exactMatch = true;
			break;
		}
	}
	
    // No depth match was found
    if(!exactMatch)
	{
		for(int i = 0; i < CFArrayGetCount(allModes); i++)
		{
			CGDisplayModeRef mode = (CGDisplayModeRef)CFArrayGetValueAtIndex(allModes, i);
			if([self displayBitsPerPixelForMode: mode] >= screenMode.bitsPerPixel)
				continue;
			
			if((CGDisplayModeGetWidth(mode) >= screenMode.width) && (CGDisplayModeGetHeight(mode) >= screenMode.height))
			{
				displayMode = mode;
				break;
			}
		}
	}
	return displayMode;
}

- (void) setDisplay:(CGDirectDisplayID) dspy toMode: (struct screenMode) screenMode {
	
    CGDisplayModeRef mode;
    CGDisplayErr err;
    
    CGDisplayModeRef originalMode = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);    
	if ( originalMode == NULL ) {
		LLLog(@"LLScreenResolution.setDisplay display with id %d is invalid", (int)dspy);
        return;
    }
    
	// look for a matching displ
	LLLog(@"LLScreenResolution.setDisplay setting display 0x%x: looking for %ld x %ld, %ld Bits Per Pixel",
		  (unsigned int)dspy,
		  screenMode.width,
		  screenMode.height,
		  screenMode.bitsPerPixel );

	mode = [self bestMatchForMode:screenMode];
	

	if ((screenMode.width == CGDisplayModeGetWidth(mode)) && 
		(screenMode.height == CGDisplayModeGetHeight(mode)) &&
		(screenMode.bitsPerPixel == [self displayBitsPerPixelForMode:mode])) {
		LLLog(@"LLScreenResolution.setDisplay found an exact match, switching modes" );
	} else {
		LLLog(@"LLScreenResolution.setDisplay found a mode, switching modes" );
	}
	
	err = CGDisplaySetDisplayMode(dspy, mode, NULL);
	if ( err != CGDisplayNoErr ) {
		LLLog(@"LLScreenResolution.setDisplay Oops!  Mode switch failed?!?? (%d)", err );
		
		// try to reset
		err = CGDisplaySetDisplayMode(dspy, originalMode, NULL);
		if ( err != CGDisplayNoErr )
			LLLog(@"LLScreenResolution.setDisplay Oops!  Mode restore failed?!?? (%d)", err );
	}
	
	// check result
	struct screenMode currentMode = [self screenModeOnPrimairyDisplay];
	LLLog(@"LLScreenResolution.setDisplay display has been set to %ld x %ld, %ld Bits Per Pixel",
		  currentMode.width,
		  currentMode.height,
		  currentMode.bitsPerPixel);	
}

- (void) setPrimairyDisplayToMode: (struct screenMode) mode {
	
	[self setDisplay: CGMainDisplayID() toMode:mode];
} 

@end
