//
//  SettingsController.m
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "SettingsController.h"


@implementation SettingsController

struct screenMode originalMode;

- (id) init {
	self = [super init];
	if (self != nil) {
		displaySetter = [LLScreenResolution defaultScreenResolution];
		
		// store this
		originalMode = [displaySetter screenModeOnPrimairyDisplay];
		
		
		// set initial screen size		
		id val = [[LLPersistantSettings defaultSettings] valueForKey:@"RESOLUTION"];
		if (val != nil) {
			NSString *resolutionValue = (NSString *)val;
			[resolution selectItemWithTitle:resolutionValue];
			[self setResolutionByString:resolutionValue];
			[mainWindow performSelector:@selector(zoom:) withObject:self afterDelay:2.0];
		}
	}
	return self;
}

- (void) awakeFromNib {

	
    [notificationCenter addObserver:self selector:@selector(saveSettings) name:@"MC_LEAVING_SETTINGS"];
    [self setPreviousValues];
	
	// actionKeyMap uses default KeyMap
	MTKeyMap *actionKeyMap = [[MTKeyMap alloc] init];
	[actionKeyMap readDefaultKeyMap];
	[actionKeyMapDataSource setKeyMap:actionKeyMap];
	
	// distressMap uses default KeyMap
	MTDistressKeyMap *distressKeyMap = [[MTDistressKeyMap alloc] init];
	[distressKeyMap readDefaultKeyMap];
	[distressKeyMapDataSource setKeyMap:distressKeyMap];	
	
	// act directly when the resolution is changed	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(resolutionChanged:) 
												 name:NSMenuDidChangeItemNotification 
											   object:[resolution menu]]; 
	 
	// shutdown
	[notificationCenter addObserver:self selector:@selector(shutdown) name:@"MC_MACTREK_SHUTDOWN"];
	
	// pass on the properties	
	// initial version
	[self saveSettingsToFile:NO];
}

- (void) shutdown {
	// reset screen
	LLLog(@"SettingsController.shutdown setting to (%dx%d), %d bpp", originalMode.height, originalMode.width, originalMode.bitsPerPixel);
	[displaySetter setPrimairyDisplayToMode:originalMode];
}

- (void) resolutionChanged:(NSNotification *)notification {
	
	NSMenu *source = [notification object];
	
	NSMenuItem *item = [source itemAtIndex:[[[notification userInfo] valueForKey:@"NSMenuItemIndex"] intValue]];
	NSMenuItem *selectedItem = [resolution selectedItem];
	
	if (item != selectedItem) {
		LLLog(@"SettingsController.resolutionChanged: ignoring %@, menu [%@]", [notification name], [item title]);
		return;	
	}
	
	LLLog(@"SettingsController.resolutionChanged: %@, menu [%@]", [notification name], [item title]);	

	// seems only to work at startup ? 
	// oh well
	//[self setResolutionByString:[item title]];
	
	// at least save it 
	[self saveSettingsToFile:YES];	
}

- (void) setResolutionByString:(NSString*) resolutionString {
	
	struct screenMode newMode;
	struct screenMode oldMode;
	
	if (resolutionString == nil) {
		return;
	}
	
	if (![resolutionString isKindOfClass:[NSString class]]) {
		return;
    }
	
	LLLog(@"SettingsController.setResolutionByString request for %@", resolutionString); 

	if ([resolutionString isEqualToString:@"Native"]) {
		LLLog(@"SettingsController.setResolutionByString sticking to native resolution"); 
	    return;
	}
	
	// its something like width x height
	NSArray *elements = [resolutionString componentsSeparatedByString:@"x"];
	newMode.width   = [[elements objectAtIndex:0] intValue];
	newMode.height  = [[elements objectAtIndex:1] intValue];
	newMode.bitsPerPixel = 32; // fixed
	
	oldMode = [displaySetter screenModeOnPrimairyDisplay];

	if ((newMode.height != oldMode.height) ||
		(newMode.width != oldMode.width) ||
		(newMode.bitsPerPixel != oldMode.bitsPerPixel)) {
		LLLog(@"SettingsController.setResolutionByString setting to (%dx%d), %d bpp", newMode.width, newMode.height, newMode.bitsPerPixel);
		[displaySetter setPrimairyDisplayToMode:newMode];	
		// pass the knowledge to the window
		struct screenMode realMode = [displaySetter screenModeOnPrimairyDisplay];
		NSRect frame = NSMakeRect(0, 0, realMode.width, realMode.height);
		//[mainWindow setFrame:frame display:YES];
		LLLog(@"SettingsController.setResolutionByString FRAME (%fx%f)", frame.size.width, frame.size.height); 
		[mainWindow setFrame:frame display:NO];
		// $$$ very strange, must wait and 1 second is not enough !!!
		[mainWindow zoom:self];
		//[[[NSApplication sharedApplication] mainWindow] performSelector:@selector(zoom:) withObject:self afterDelay:10.0];
		[mainWindow performSelector:@selector(zoom:) withObject:self afterDelay:2.0];
		//[mainWindow performSelector:@selector(performZoom:) withObject:self afterDelay:15.0];
	}
}

- (MTKeyMap*) actionKeyMap {
	return [actionKeyMapDataSource keyMap];
}

- (MTKeyMap*) distressKeyMap {
	return [distressKeyMapDataSource keyMap];
}

- (void) setPreviousValues {
    LLPersistantSettings *settings = [LLPersistantSettings defaultSettings];
	
    NSNumber *val;
    
    val = [settings valueForKey:@"MUSIC_LEVEL"];
    if (val != nil) {
        [musicLevel setFloatValue:[val floatValue]];
    }
    val = [settings valueForKey:@"FX_LEVEL"];
    if (val != nil) {
        [fxLevel setFloatValue:[val floatValue]];
    }
	val = [settings valueForKey:@"VOICE_CMDS"];
    if (val != nil) {
        if ([val boolValue]) {
			[voiceCmds setState:NSOnState];   
        } else {
            [voiceCmds setState:NSOffState];
        }        
    }
    val = [settings valueForKey:@"VOICE_OVER"];
    if (val != nil) {
        if ([val boolValue]) {
           [voiceOver setState:NSOnState];   
        } else {
            [voiceOver setState:NSOffState];
        }        
    }
	val = [settings valueForKey:@"ACCELERATE"];
    if (val != nil) {
        if ([val boolValue]) {
			[accelerateButton setState:NSOnState];   
        } else {
            [accelerateButton setState:NSOffState];
        }        
    }
    val = [settings valueForKey:@"THEME"];
    if (val != nil) {
        [graphicsModel setSelectedSegment:[val intValue]];
    }
	val = [settings valueForKey:@"TRACKING"];
    if (val != nil) {
        if ([val boolValue]) {
			[trackingEnabledButton setState:NSOnState];   
        } else {
            [trackingEnabledButton setState:NSOffState];
        }        
    }
	// set the mouse settings too FR 1666849
	val = [settings valueForKey:@"LEFT_MOUSE"];
    if (val != nil) {
        [leftMouse selectItemWithTitle:[self stringForAction:[val intValue]]];
    }
	val = [settings valueForKey:@"MIDDLE_MOUSE"];
    if (val != nil) {
        [middleMouse selectItemWithTitle:[self stringForAction:[val intValue]]];
    }
	val = [settings valueForKey:@"RIGHT_MOUSE"];
    if (val != nil) {
        [rightMouse selectItemWithTitle:[self stringForAction:[val intValue]]];
    }
	val = [settings valueForKey:@"WHEEL_MOUSE"];
    if (val != nil) {
        [wheelMouse selectItemWithTitle:[self stringForAction:[val intValue]]];
    }
	// can select resolution now
	val = [settings valueForKey:@"RESOLUTION"];
    if (val != nil) {
		NSString *resolutionValue = (NSString *)val;
        [resolution selectItemWithTitle:resolutionValue];
		[self setResolutionByString:resolutionValue];
    }
		
	// set internal tracker state
	[[SimpleTracker defaultTracker] setEnabled:[self trackingEnabled]];
	
	// log to console is special (should have done all like this)
	bool state = [[NSUserDefaults standardUserDefaults]boolForKey:@"LLLogDisabled"];
	if(state == NO) { // log not disabled
		[logToConsole setState:NSOnState];
	} else {
		[logToConsole setState:NSOffState];
	}
	
	val = [settings valueForKey:@"USE_RCD"];
    if (val != nil) {
        if ([val boolValue]) {
			[useRCD setState:NSOnState];   
        } else {
            [useRCD setState:NSOffState];
        }        
    }
	
	val = [settings valueForKey:@"USERNAME"];	
    if (val != nil) {
		[playerName setStringValue:(NSString *)val];
    }
	
	val = [settings valueForKey:@"PASSWORD"];
    if (val != nil) {
		[playerPassword setStringValue:(NSString *)val];
    }
	
	val = [settings valueForKey:@"TIP_OF_THE_DAY"];
    if (val != nil) {
        if ([val boolValue]) {
			[tipsButton setState:NSOnState];   
        } else {
            [tipsButton setState:NSOffState];
        }     
	}
	
}

- (void) saveSettings {
	[self saveSettingsToFile:YES];
}

- (void) saveSettingsToFile:(bool)toFile {
    
	LLLog(@"SettingsController.saveSettingsToFile called");
    LLPersistantSettings *settings = [LLPersistantSettings defaultSettings];
    
    [settings setLazyValue:[NSNumber numberWithFloat:[self musicLevel]] forKey:@"MUSIC_LEVEL"];
    [settings setLazyValue:[NSNumber numberWithFloat:[self fxLevel]] forKey:@"FX_LEVEL"];
	[settings setLazyValue:[NSNumber numberWithBool:[self voiceCommands]] forKey:@"VOICE_CMDS"];
    [settings setLazyValue:[NSNumber numberWithBool:[self voiceEnabled]] forKey:@"VOICE_OVER"];
	[settings setLazyValue:[NSNumber numberWithBool:[self accelerate]] forKey:@"ACCELERATE"];
    [settings setLazyValue:[NSNumber numberWithInt:[self graphicsModel]] forKey:@"THEME"];   
	[settings setLazyValue:[NSNumber numberWithBool:[self trackingEnabled]] forKey:@"TRACKING"];
	
	// get the mouse settings too FR 1666849
	MTMouseMap *mouseMap = [self mouseMap];
	[settings setLazyValue:[NSNumber numberWithInt:[mouseMap actionMouseLeft]] forKey:@"LEFT_MOUSE"];
	[settings setLazyValue:[NSNumber numberWithInt:[mouseMap actionMouseMiddle]] forKey:@"MIDDLE_MOUSE"];
	[settings setLazyValue:[NSNumber numberWithInt:[mouseMap actionMouseRight]] forKey:@"RIGHT_MOUSE"];
	[settings setLazyValue:[NSNumber numberWithInt:[mouseMap actionMouseWheel]] forKey:@"WHEEL_MOUSE"];
	
	// add the resolution
	[settings setLazyValue:[[resolution selectedItem] title]  forKey:@"RESOLUTION"];	
	[settings setLazyValue:[NSNumber numberWithBool:[self useRCD]] forKey:@"USE_RCD"];
	[settings setLazyValue:[playerName stringValue] forKey:@"USERNAME"];
	[settings setLazyValue:[playerName stringValue] forKey:@"PASSWORD"];	
	[settings setLazyValue:[NSNumber numberWithBool:[self tipsEnabled]] forKey:@"TIP_OF_THE_DAY"];
	
	if (toFile) {
		[settings update];
	}
	
	// an excellent place to tell the tracker what the status is
	[[SimpleTracker defaultTracker] setEnabled:[self trackingEnabled]];
	
	// and the keymaps of course
	// BUG 1674341
	[[self actionKeyMap] writeToDefaultFileIfChanged];
	[[self distressKeyMap] writeToDefaultFileIfChanged];
	
	// log to console is special.. log is off means disabled is true
	bool state = ([logToConsole state] != NSOnState);
	[[NSUserDefaults standardUserDefaults] setBool:state forKey:@"LLLogDisabled"];
	
	// pass on the properties	
	[settings setProperties];
	[properties setValue:[self actionKeyMap] forKey:@"ACTION_KEYMAP"];
	[properties setValue:[self distressKeyMap] forKey:@"DISTRESS_KEYMAP"];	
	[properties setValue:[self mouseMap] forKey:@"MOUSE_MAP"];
	
	[notificationCenter postNotificationName:@"SC_NEW_SETTINGS" userInfo:self];
}


- (bool)  trackingEnabled {
	return ([trackingEnabledButton state] == NSOnState);
}

- (float)  musicLevel {
    return [musicLevel floatValue];
}

- (float)  fxLevel {
    return [fxLevel floatValue];
}

- (bool) soundEnabled {
    if (([musicLevel intValue] > 0) ||  ([fxLevel intValue] > 0)) {
        return YES;
    } else {
        return NO;
    }
}

- (bool) accelerate {
    return ([accelerateButton state] == NSOnState);
}

- (bool)  tipsEnabled {
	return ([tipsButton state] == NSOnState);
}

- (bool) voiceCommands {
    return ([voiceCmds state] == NSOnState);
}

- (bool) voiceEnabled {
    return ([voiceOver state] == NSOnState);
}

- (int)  graphicsModel {
    return [graphicsModel selectedSegment];
}

- (NSString *) stringForAction:(int) action {
	
	switch (action) {
	case ACTION_SET_COURSE:
		return @"Course";
		break;
	case ACTION_FIRE_PHASER:
		return @"Phaser";
		break;
	case ACTION_FIRE_TORPEDO:
		return @"Torpedo";
		break;
	case ACTION_ZOOM:
		return @"Zoom";
		break;
	default:
		LLLog(@"SettingsController.stringForAction action %d unknown", action);
		return nil;
		break;
	}
}

- (bool) useRCD {
	return ([useRCD state] == NSOnState);
}

- (int) actionForButton:(NSPopUpButton *) button {
	if ([[[button selectedItem] title] isEqualToString:@"Course"] ) {
		return ACTION_SET_COURSE;
	} else if ([[[button selectedItem] title] isEqualToString:@"Torpedo"] ) {
		return ACTION_FIRE_TORPEDO;
	} else if ([[[button selectedItem] title] isEqualToString:@"Phaser"] ) {
		return ACTION_FIRE_PHASER;
	} else if ([[[button selectedItem] title] isEqualToString:@"Zoom"] ) {
		return ACTION_ZOOM;
	} else {
		LLLog(@"SettingsController.actionForButton item %@ unknown", [[button selectedItem] title]);
		// @@@ dirty hack BUG 1674341
		// this gets called by accident if the back button is pressed in the settings pane
		// (probably more often) easy place to save the settings though
		// $$$ side effect cannot fire torps with mouse .... (strange)
		//[[self keyMap] writeToDefaultFileIfChanged];
		return -1;
	}
}

- (MTMouseMap *)mouseMap {
	
	MTMouseMap *mouseMap = [[[MTMouseMap alloc] init] autorelease];
	
	[mouseMap setActionMouseLeft:[self actionForButton:leftMouse]];
	[mouseMap setActionMouseRight:[self actionForButton:rightMouse]];
	[mouseMap setActionMouseMiddle:[self actionForButton:middleMouse]];
	[mouseMap setActionMouseWheel:[self actionForButton:wheelMouse]];
	
	return mouseMap;	
}

@end
