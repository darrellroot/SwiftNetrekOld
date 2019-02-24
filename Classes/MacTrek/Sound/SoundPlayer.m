//
//  SoundPlayer.m
//  MacTrek
//
//  Created by Aqua on 03/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "SoundPlayer.h"

@implementation SoundPlayer

- (id) init {
    self = [super init];
    if (self != nil) {
        //soundEffects = [[NSMutableArray alloc] init];
        soundEffects = [[NSMutableDictionary alloc] init];
        universe = [Universe defaultInstance];
        volumeFX = 0.5;
        volumeMusic = 0.5;
        
       //[self subscribeToNotifications]; // the gui manager will sub/unsub us
        
        // start caching in the background
		//[NSThread detachNewThreadSelector:@selector(loadSoundsInSeperateThread:) toTarget:self withObject:nil];
        [self performSelector:@selector(loadSounds) withObject:nil afterDelay:0.01];
        //[self loadSounds]; // $$seperate thread works not ok? QTMovie class must be initialized on the main thread.
		
		[notificationCenter addObserver:self selector:@selector(stopIntroSound) name:@"GM_GAME_ENTERED"];
    }
    return self;
}

- (void) stopSound:(NSString*) snd {
	SoundEffect *sound = [soundEffects objectForKey:snd];
    if (sound != nil) {
		LLLog(@"Soundplayer.stopSound %@", snd);
        [sound stop];  
    } else {
        LLLog(@"Soundplayer.stopSound no sound for %@", snd);
    }
}

- (void) stopIntroSound {
	[self stopSound:@"INTRO_SOUND"];
}

- (void) loadSoundsInSeperateThread:(id)sender {
    
    // create a private pool for this thread
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    LLLog(@"SoundPlayer.loadSoundsInSeperateThread: start running");
    [self loadSounds];
    LLLog(@"SoundPlayer.loadSoundsInSeperateThread: complete");
      
    // release the pool
    [pool release];
}

- (void) awakeFromNib {
    
    // hmm not called?

}

- (void) setVolumeFx:(float)vol {
    volumeFX = vol;
}

- (void) setVolumeMusic:(float)vol {
    volumeMusic = vol;
}

- (void) subscribeToNotifications {
   
    [notificationCenter addObserver:self selector:@selector(handleAlertChanged:) name:@"PL_ALERT_STATUS_CHANGED"]; 
    [notificationCenter addObserver:self selector:@selector(handleCloakChanged:) name:@"PL_CLOAKING"];                   
    [notificationCenter addObserver:self selector:@selector(handleCloakChanged:) name:@"PL_UNCLOAKING"];
    [notificationCenter addObserver:self selector:@selector(handleMyPhaser:) name:@"PL_MY_PHASER_FIRING"];
    [notificationCenter addObserver:self selector:@selector(handleOtherPhaser:) name:@"PL_OTHER_PHASER_FIRING"];
    [notificationCenter addObserver:self selector:@selector(handleMyTorpFired:) name:@"PL_TORP_FIRED_BY_ME"];
    [notificationCenter addObserver:self selector:@selector(handleOtherTorpFired:) name:@"PL_TORP_FIRED_BY_OTHER"];
    [notificationCenter addObserver:self selector:@selector(handleTorpExploded:) name:@"PL_TORP_EXPLODED"];
    [notificationCenter addObserver:self selector:@selector(handleMyPlasmaFired:) name:@"PL_PLASMA_FIRED_BY_ME"];
    [notificationCenter addObserver:self selector:@selector(handleOtherPlasmaFired:) name:@"PL_PLASMA_FIRED_BY_OTHER"];
    [notificationCenter addObserver:self selector:@selector(handlePlasmaExploded:) name:@"PL_PLASMA_EXPLODED"]; 
    [notificationCenter addObserver:self selector:@selector(handlePlayerExploded:) name:@"PL_EXPLODE_PLAYER"];
    [notificationCenter addObserver:self selector:@selector(handleSelfDestruct) name:@"SPW_SELF_DESTRUCT_INITIATED"];
    [notificationCenter addObserver:self selector:@selector(handleShieldsPlayer:) name:@"PL_SHIELD_UP_PLAYER"];
    [notificationCenter addObserver:self selector:@selector(handleShieldsPlayer:) name:@"PL_SHIELD_DOWN_PLAYER"];  
    [notificationCenter addObserver:self selector:@selector(handleSpeedChangeRequest:) name:@"COMM_SEND_SPEED_REQ"];   
    [notificationCenter addObserver:self selector:@selector(handleMessageSent) name:@"COMM_SEND_MESSAGE"];    
}

- (void) unSubscibeToNotifications {
    [notificationCenter removeObserver:self name:nil]; // remove myself from all notifications
}

- (void) loadSounds {
    
    SoundEffect *sound;
    
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/cloak.au"];
    [soundEffects setObject:sound forKey:@"CLOAK_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/engine.au"];
    [soundEffects setObject:sound forKey:@"ENGINE_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/enter_ship.au"];
    [soundEffects setObject:sound forKey:@"ENTER_SHIP_SOUND"]; // triggerd by GuiManager
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/explosion.au"];
    [soundEffects setObject:sound forKey:@"EXPLOSION_SOUND"];  
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/explosion_other.au"];
    [soundEffects setObject:sound forKey:@"EXPLOSION_OTHER_SOUND"];  
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/fire_plasma.au"];
    [soundEffects setObject:sound forKey:@"FIRE_PLASMA_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/fire_plasma.au" nrOfInstances:8];         // use same sound
    [soundEffects setObject:sound forKey:@"FIRE_PLASMA_OTHER_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/fire_torp.au" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"FIRE_TORP_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/fire_torp_other.au" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"FIRE_TORP_OTHER_SOUND"];
    sound = [[SoundEffect alloc] init];   
    [sound loadSoundWithName:@"SoundEffects/intro.au"];                      
    [soundEffects setObject:sound forKey:@"INTRO_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/message.au"]; 
    [soundEffects setObject:sound forKey:@"MESSAGE_SOUND"];    
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/fire_phaser.au"];
    [soundEffects setObject:sound forKey:@"PHASER_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/fire_phaser_other.au" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"PHASER_OTHER_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/plasma_hit.au" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"PLASMA_HIT_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/red_alert.au"];
    [soundEffects setObject:sound forKey:@"RED_ALERT_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/self_destruct.au"];                  
    [soundEffects setObject:sound forKey:@"SELF_DESTRUCT_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/shield_down.au"];   
    [soundEffects setObject:sound forKey:@"SHIELD_DOWN_SOUND"]; 
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/shield_up.au"];                      
    [soundEffects setObject:sound forKey:@"SHIELD_UP_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/torp_hit.au" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"TORP_HIT_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/uncloak.au"];
    [soundEffects setObject:sound forKey:@"UNCLOAK_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/warning.au"];      // not needed, red alert
    [soundEffects setObject:sound forKey:@"WARNING_SOUND"];    // replaced it
    
    // we are done
    LLLog(@"SoundPlayer.loadSound done");
    [notificationCenter postNotificationName:@"SP_SOUNDS_CACHED"];
}

- (void) handleSpeedChangeRequest:(NSNumber*)reqSpeed {
    
    int speed = [[universe playerThatIsMe] speed];
    
    if ((speed == 0) && (reqSpeed > 0)) {   // fire up the engines scotty
        
        // works, but what a horrible sound effect!
        //[self playSoundEffect:@"ENGINE_SOUND"];
    }
}

- (void) handleAlertChanged:(NSNumber*)intAlert {
    
    int newAlertStatus = [intAlert intValue];
    
    if (newAlertStatus == PLAYER_RED) {
        [self playSoundEffect:@"RED_ALERT_SOUND"];
    }
}

- (void) handleCloakChanged:(NSNumber*)boolCloakOn {
    
    bool cloakOn = [boolCloakOn boolValue];
    
    if (cloakOn) {
        [self playSoundEffect:@"CLOAK_SOUND"];
    } else {
        [self playSoundEffect:@"UNCLOAK_SOUND"];
    }  
}   

- (void) playSoundEffect:(NSString*) snd {
    SoundEffect *sound = [soundEffects objectForKey:snd];
    if (sound != nil) {
        [sound playWithVolume:volumeFX];
    } else {
        LLLog(@"Soundplayer.playSoundEffect no sound for %@", snd);
    }
}

- (void) handleMessageSent {
    [self playSoundEffect:@"MESSAGE_SOUND"];
}

- (void) handleSelfDestruct {
    [self playSoundEffect:@"SELF_DESTRUCT_SOUND"];
}

- (void) handleMyPhaser:(Phaser*)Phaser {
    [self playSoundEffect:@"PHASER_SOUND"];
}

- (void) handleShieldsPlayer:(Player*)player {
    
    if (![player isMe]) {               
        return; // you'll get crazy       
    }
       
    if ([player flags] & PLAYER_SHIELD) {
        [self playSoundEffect:@"SHIELD_UP_SOUND"]; 
    } else {
        [self playSoundEffect:@"SHIELD_DOWN_SOUND"]; 
    }

}

- (void) handlePlayerExploded:(Player*)player {
    if ([player isMe]) {
        [self playSoundEffect:@"EXPLOSION_SOUND"];        
    } else {        
        [self playSoundEffect:@"EXPLOSION_OTHER_SOUND"];        
    }
}

- (void) handleOtherPhaser:(Phaser*)phaser {
    SoundEffect *sound = [soundEffects objectForKey:@"PHASER_OTHER_SOUND"];
    
    [self playSoundEffect:sound relativeToEntity:[phaser owner]];
}

- (void) handleMyTorpFired:(Torp*)torp {
    [self playSoundEffect:@"FIRE_TORP_SOUND"];
}

- (void) handleOtherTorpFired:(Torp*)torp {
    SoundEffect *sound = [soundEffects objectForKey:@"FIRE_TORP_OTHER_SOUND"];
    
    [self playSoundEffect:sound relativeToEntity:[torp owner]];    
}

- (void) handleTorpExploded:(Torp*)torp {
    SoundEffect *sound = [soundEffects objectForKey:@"TORP_HIT_SOUND"];
    
    [self playSoundEffect:sound relativeToEntity:torp];
}

- (void) handleMyPlasmaFired:(Plasma*)plasma {
    [self playSoundEffect:@"FIRE_PLASMA_SOUND"];    
}

- (void) handleOtherPlasmaFired:(Plasma*)plasma {
    SoundEffect *sound = [soundEffects objectForKey:@"FIRE_PLASMA_OTHER_SOUND"];
    
    [self playSoundEffect:sound relativeToEntity:[plasma owner]];    
}

- (void) handlePlasmaExploded:(Plasma*)plasma {
    SoundEffect *sound = [soundEffects objectForKey:@"PLASMA_HIT_SOUND"];
    
    [self playSoundEffect:sound relativeToEntity:plasma];
}

- (void) playSoundEffect:(SoundEffect*)sound relativeToEntity:(Entity*)obj {
    float distance = [universe distanceToEntity:obj from:[universe playerThatIsMe]];
    float angle    = [universe angleDegBetweenEntity:obj from:[universe playerThatIsMe]];
    
    [self playSoundEffect:sound atAngle:angle atDistance:distance]; 
}

- (void) playSoundEffect:(SoundEffect*)sound atAngle:(float)angle atDistance:(float)distance {
    
    if (sound == nil) {
        LLLog(@"Sounplayer.playSoundEffect no sound..");
        return;
    }
    
    if (distance > SP_MAX_RANGE) { // prevent negative volume
        //LLLog(@"Sounplayer.playSoundEffect refuse to play, too far away");
        return;
    }
 
    // angle is 0..360, balance is -1 +1
    float balance = sin(angle);

    // decrease volume with distance at SP_MAX_RANGE = 0 at 0 it is max    
    float volume = volumeFX - ((volumeFX * distance) / SP_MAX_RANGE); 
    [sound playWithVolume:volume balance:balance];  
}

@end
