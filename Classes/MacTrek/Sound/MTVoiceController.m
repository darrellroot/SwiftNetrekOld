//
//  MTVoiceController.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 19/02/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "MTVoiceController.h"


@implementation MTVoiceController

- (id)init {
    self = [super init];
	
    if (self) {
        cmds = [NSArray arrayWithObjects: 
			
			@"torpedo", 
			@"plasma", 
			@"phaser",
			@"course", 
			@"shields",
			@"bomb",
			@"repair",
			@"lock",
			@"tractor",
			@"press",
			@"max",
			@"stop", 
			@"cloak",
			
			nil];
		[cmds retain];
		
		codes = [NSArray arrayWithObjects: 
			
			[NSNumber numberWithInt:ACTION_FIRE_TORPEDO], 
			[NSNumber numberWithInt:ACTION_FIRE_PLASMA], 
			[NSNumber numberWithInt:ACTION_FIRE_PHASER],
			[NSNumber numberWithInt:ACTION_SET_COURSE], 
			[NSNumber numberWithInt:ACTION_SHIELDS],
			[NSNumber numberWithInt:ACTION_BOMB],
			[NSNumber numberWithInt:ACTION_REPAIR],
			[NSNumber numberWithInt:ACTION_LOCK],
			[NSNumber numberWithInt:ACTION_TRACTOR],
			[NSNumber numberWithInt:ACTION_PRESSOR],
			[NSNumber numberWithInt:ACTION_WARP_MAX],
			[NSNumber numberWithInt:ACTION_WARP_0], 
			[NSNumber numberWithInt:ACTION_CLOAK],
			
			nil];
		[codes retain];
		
    }
    return self;
}


// [ 1691205 ] 1.2.0RC1 sometimes hangs during launch
// moved from init to awakeFromNib (call it a hunch)
- (void) awakeFromNib {
	
	speechRecognizer = [[NSSpeechRecognizer alloc] init]; 
	[speechRecognizer setCommands:cmds];
	[speechRecognizer setDelegate:self];
}

- (void)setEnableListening:(bool)onOff {
    if (onOff) { // listen
		LLLog(@"MTVoiceController.setEnableListening enabled");
		[speechRecognizer startListening];
    } else {
		LLLog(@"MTVoiceController.setEnableListening NOT enabled");
		[speechRecognizer stopListening];
    }	
	[[NSSound soundNamed:@"Whit"] play];
}

- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd {
	
	NSString *command = (NSString *)aCmd;
	int index = [cmds indexOfObjectIdenticalTo:command];
	NSNumber *act = [codes objectAtIndex:index];
	
	if (index == NSNotFound) {
		LLLog(@"MTVoiceController.speechRecognizer command %@ not programmed", (NSString *)aCmd);
	} else {
		LLLog(@"MTVoiceController.speechRecognizer command %@ found at %d, action %@", (NSString *)aCmd, index, [act stringValue]);
		[notificationCenter postNotificationName:@"VC_VOICE_COMMAND" userInfo:act];
		[[NSSound soundNamed:@"Whit"] play];     
    }
}

@end
