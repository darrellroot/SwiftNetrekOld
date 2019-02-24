//
//  MTVoiceController.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 19/02/2007.
//  Copyright 2007 See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "MTKeyMap.h"
#import "Luky.h"

@interface MTVoiceController : BaseClass <NSSpeechRecognizerDelegate> {
	
	NSSpeechRecognizer *speechRecognizer;
	NSArray *codes;
	NSArray *cmds;
}

- (void)setEnableListening:(bool)onOff;
- (void)speechRecognizer:(NSSpeechRecognizer *)sender didRecognizeCommand:(id)aCmd;

@end
