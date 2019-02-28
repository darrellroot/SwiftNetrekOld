//
//  GameController.m
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "GameController.h"
#import "SwiftNetrek-Swift.h"


@implementation GameController

bool forceBarUpdate = NO;

- (void) awakeFromNib {
      
    // watch my shields and stuff
    // but beware that the events are received in the main thread
    
    // when we receive status messages, we update the textfield
    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SP_WARNING"
                             object:nil useLocks:NO useMainRunLoop:YES];
    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"PM_WARNING"
                             object:nil useLocks:NO useMainRunLoop:NO]; // is fired in main loop
    [notificationCenter addObserver:self selector:@selector(newInfoMessage:) name:@"GV_MODE_INFO"
                             object:nil useLocks:NO useMainRunLoop:NO]; // is fired in main loop
	[notificationCenter addObserver:self selector:@selector(queueFull) 
							   name:@"SP_QUEUE" object:nil];
	universe = [Universe defaultInstance];
    
    // set up discrete bars
    [armiesBar setDiscrete:YES];
    [torpsBar setDiscrete:YES];
    //[phasersBar setDiscrete:YES];
	
	// should be the default..
	[shieldBar setAlpha: 1.0];  
    [speedBar setAlpha: 1.0];
    [hullBar setAlpha: 1.0];
    [fuelBar setAlpha: 1.0];
    [torpsBar setAlpha: 1.0];
    [phasersBar setAlpha: 1.0];
    [eTempBar setAlpha: 1.0];
    [wTempBar setAlpha: 1.0];
    [armiesBar setAlpha: 1.0];	
	[shieldBar setShowBackGround: YES];  
    [speedBar setShowBackGround: YES];
    [hullBar setShowBackGround: YES];
    [fuelBar setShowBackGround: YES];
    [torpsBar setShowBackGround: YES];
    [phasersBar setShowBackGround: YES];
    [eTempBar setShowBackGround: YES];
    [wTempBar setShowBackGround: YES];
    [armiesBar setShowBackGround: YES];
    
    // add speech
    //synth = [[NSSpeechSynthesizer alloc] initWithVoice:@"com.apple.speech.synthesis.voice.Zarvox"];
    synth = [[NSSpeechSynthesizer alloc] initWithVoice:@"com.apple.speech.synthesis.voice.Trinoids"]; 
    shouldSpeak = YES;
    
    //synth is an ivar    
    [synth setDelegate:self];
	
	// set up voice control (1.2.0 feature)
	voiceCntrl = [[MTVoiceController alloc] init];
	//[voiceCntrl enableListening:YES];
}

- (void) queueFull {
	[self newMessage:@"This server is full, please select a different server"];
}

- (DRGameView *)gameView {
	return gameView;
}

- (MapView *)mapView {
	return mapView;
}

- (void) setSpeakComputerMessages:(bool)speak {
    shouldSpeak = speak;
}

- (void) setListenToVoiceCommands:(bool)listen {
	[voiceCntrl setEnableListening:listen];
}

- (void) repaint:(float)timeSinceLastPaint {
    // invoked by timer in gui manager
	
	// refresh every now and then
	static int frameCount = 0;
	
	if (frameCount++ > FRAMES_PER_FULL_UPDATE_DASHBOARD) {
		frameCount = 0;
		forceBarUpdate = YES;
	} else {
		forceBarUpdate = NO;
	}
	
	// calculate the framerate
	frameRate = 1 / timeSinceLastPaint;
	if (frameRate < 0) frameRate = 0;
	
    // repaint the dashboard here
    [self updateDashboard:[universe playerThatIsMe]];
    
    // do the messages list if an update occured
    if ([messages hasChanged]) {
        //LLLog(@"GameController.repaint repainting messages view");
        [messages setNeedsDisplay:YES];
    }
    // do the playerList list if an update occured
	// sometimes death is not registerd properly, so update more often
    if ([playerList hasChanged] || forceBarUpdate) {
        //LLLog(@"GameController.repaint repainting playerList view");
        [playerList setNeedsDisplay:YES];
    }
    
    // and the main view    
    [mapView setNeedsDisplay:YES];
    // $$ see if this is faster
    [gameView setNeedsDisplay:YES];
    //[gameView display];
}

- (void) newInfoMessage:(NSString*)message {
    
    if ([[messageTextField stringValue] isEqualToString:message]) {
        return; // no need to update
    }
    [messageTextField setStringValue:message];
}

- (void) newMessage:(NSString*)message {

    [self newInfoMessage:message];
    
    // add speech...
    if (shouldSpeak && (![synth isSpeaking])) {
		LLLog(@"GameController.newMessage startSpeaking: [%@]", message);
		
		if ([message isEqualToString:@"Server sending PING packets at 2 second intervals"]) {
			return; // ignore that
		}
		
		if ([message isEqualToString:@"Our computers limit us to having 8 live torpedos at a time captain!"]) {
			// patch string BUG 2242677
			[synth startSpeakingString:@"Out of torpedos!"];
		} else {
			[synth startSpeakingString:message];		
		}
    }
    
}

- (void) updateBar:(LLBar*) bar andTextValue:(NSTextField*)field 
         withValue:(int)value max:(int)maxValue inverseWarning:(bool)inverse {
    [self updateBar:bar andTextValue:field withValue:value max:maxValue
            tempMax:maxValue inverseWarning:inverse];
}
      
- (void) updateBar:(LLBar*) bar andTextValue:(NSTextField*)field 
         withValue:(int)value max:(int)maxValue tempMax:(int)tempMax inverseWarning:(bool)inverse {
    // NOTE: as this is called from a seperate thread, we need to tell the main
    // thread that it needs to re-display explictly !
    
    if (bar == nil) {
        return;
    }
    
    // update only if required 
    if (([bar max] != maxValue) || forceBarUpdate) {
        //LLLog(@"GameController.updateBar %@ setting max to %d", [bar name], maxValue);
        if (field != nil) { // overrules max
            [field setStringValue:[NSString stringWithFormat:@"%d / %d", value, tempMax]];
        }
        [bar setMax:maxValue * 1.0];
        if (inverse) {
            [bar setCritical:maxValue * 0.5];
            [bar setWarning:maxValue * 0.3];
        } else {
            [bar setCritical:maxValue * 0.3];
            [bar setWarning:maxValue * 0.5];
        }
        [bar setNeedsDisplay:YES];
    }
    if (([bar tempMax] != tempMax) || forceBarUpdate) {
        //LLLog(@"GameController.updateBar %@ setting tempMax to %d", [bar name], tempMax);
        [bar setTempMax:tempMax * 1.0];
        [bar setNeedsDisplay:YES];
        if (field != nil) { // overrules max
            [field setStringValue:[NSString stringWithFormat:@"%d / %d", value, tempMax]];
        }
    }    
    if (([bar value] != value) || forceBarUpdate) {
        //LLLog(@"GameController.updateBar %d setting value to %d", [bar tag], value);
        if (field != nil) {              
            [field setStringValue:[NSString stringWithFormat:@"%d / %d", value, tempMax]];                            
        } 
        [bar setValue:value * 1.0]; 
        [bar setNeedsDisplay:YES];
    }         
}

- (void) updateDashboard:(Player*) me {
    
    if (![me isMe]) { // this is not me...
        return;
    }

    [self updateBar:hullBar   andTextValue:hullValue   
          withValue:[me hull] max:[[me ship] maxHull] inverseWarning:NO];
    [self updateBar:shieldBar andTextValue:shieldValue 
          withValue:[me shield] max:[[me ship] maxShield]
     inverseWarning:NO];
    [self updateBar:fuelBar   andTextValue:fuelValue   
          withValue:[me fuel] max:[[me ship] maxFuel] inverseWarning:NO];
    [self updateBar:eTempBar  andTextValue:eTempValue  
          withValue:[me engineTemp] / 10 max:[[me ship] maxEngineTemp] / 10
          inverseWarning:YES];
    [self updateBar:wTempBar  andTextValue:wTempValue  
          withValue:[me weaponTemp] / 10 max:[[me ship] maxWeaponTemp] / 10  
          inverseWarning:YES];
    [self updateBar:speedBar  andTextValue:speedValue  
          withValue:[me speed] max:[[me ship] maxSpeed] tempMax:[me maxSpeed] inverseWarning:YES];
    // special max armies is depended on the players kills
    [self updateBar:armiesBar andTextValue:nil    
          withValue:[me armies] max:[[me ship] maxArmies] tempMax:[me maxArmies] inverseWarning:NO];
    [self updateBar:torpsBar andTextValue:nil     
          withValue:[me availableTorps] max:[me maxTorps]
          inverseWarning:NO];
	
	// abusing phaser bar to show frame rate!	
	//LLLog(@"GameController.updateDashboard framerate %f max %f", frameRate, FRAME_RATE);
	
	// average a little
	static float averageFrameRate = 0;
	static int sampleCount = 0;
	
	averageFrameRate += frameRate;
	sampleCount++;	
	
	if (forceBarUpdate) { // smooth display
		[self updateBar:phasersBar andTextValue:nil withValue:(averageFrameRate/sampleCount) max:50.0 inverseWarning:NO];
		averageFrameRate = 0;
		sampleCount = 0;
	}
}

- (void) setPainter:(PainterFactory*)newPainter {
    [gameView setPainter:newPainter];
}

- (void) stopGame {
    [gameView stopTrackingMouse];
    [mapView stopTrackingMouse];
    
    // The optimizations may prevent sibling subviews from being displayed in the correct order—which matters only if the subviews 
    // overlap. You should always set flag to YES if there are no overlapping subviews within the NSWindow. The default is NO.
    [[gameView window] useOptimizedDrawing:NO];    
}

- (void) startGame {
    // set focus on main view
    // the view now reacts to mouse movements
    //[gameView dummyMouseAction];
    [gameView startTrackingMouse];
    [mapView startTrackingMouse];
    
    // The optimizations may prevent sibling subviews from being displayed in the correct order—which matters only if the subviews 
    // overlap. You should always set flag to YES if there are no overlapping subviews within the NSWindow. The default is NO.
    [[gameView window] useOptimizedDrawing:YES];
    
}

@end
