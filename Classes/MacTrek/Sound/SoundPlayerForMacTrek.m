//
//  SoundPlayerForMacTrek.m
//  MacTrek
//
//  Created by Aqua on 23/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "SoundPlayerForMacTrek.h"


@implementation SoundPlayerForMacTrek

- (void) subscribeToNotifications {
    
    [super subscribeToNotifications];
    
    [notificationCenter addObserver:self selector:@selector(handleTransporter) name:@"SPW_BEAMUP2_TEXT"];
    [notificationCenter addObserver:self selector:@selector(handleTransporter) name:@"SPW_BEAM_D_PLANET_TEXT"];
    [notificationCenter addObserver:self selector:@selector(handleTransporter) name:@"SPW_BEAM_U_TEXT"]; 
    //[notificationCenter addObserver:self selector:@selector(handleDeath) name:@"PL_I_DIED"];
    [notificationCenter addObserver:self selector:@selector(handleDeath) name:@"CC_GO_OUTFIT"];
}

- (void) loadSounds {
    
    SoundEffect *sound;
    
    // old sounds
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects/self_destruct.au"];                  
    [soundEffects setObject:sound forKey:@"SELF_DESTRUCT_SOUND"];
       
    // new sounds 
	sound = [[SoundEffect alloc] init];   
    [sound loadSoundWithName:@"SoundEffects2/intro.wav"];                      
    [soundEffects setObject:sound forKey:@"INTRO_SOUND"];
	sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/torp_hit.wav" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"TORP_HIT_SOUND"]; 
	sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/plasma_hit.wav" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"PLASMA_HIT_SOUND"];
	sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/explosion.wav"];
    [soundEffects setObject:sound forKey:@"EXPLOSION_SOUND"];   
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/cloak.wav"];
    [soundEffects setObject:sound forKey:@"CLOAK_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/enter_ship.wav"];
    [soundEffects setObject:sound forKey:@"ENTER_SHIP_SOUND"]; 
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/explosion_other.wav" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"EXPLOSION_OTHER_SOUND"]; 
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/message.wav"]; 
    [soundEffects setObject:sound forKey:@"MESSAGE_SOUND"];    
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/fire_phaser.wav"];
    [soundEffects setObject:sound forKey:@"PHASER_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/fire_phaser_other.wav" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"PHASER_OTHER_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/fire_plasma.wav"];
    [soundEffects setObject:sound forKey:@"FIRE_PLASMA_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/fire_plasma.wav" nrOfInstances:8];                   // use same sound
    [soundEffects setObject:sound forKey:@"FIRE_PLASMA_OTHER_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/fire_torp.wav" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"FIRE_TORP_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/fire_torp_other.wav" nrOfInstances:8];
    [soundEffects setObject:sound forKey:@"FIRE_TORP_OTHER_SOUND"];    
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/red_alert.wav"];
    [soundEffects setObject:sound forKey:@"RED_ALERT_SOUND"];    
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/shield_down.wav"];   
    [soundEffects setObject:sound forKey:@"SHIELD_DOWN_SOUND"]; 
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/shield_up.wav"];                      
    [soundEffects setObject:sound forKey:@"SHIELD_UP_SOUND"];
    sound = [[SoundEffect alloc] init];
    [sound loadSoundWithName:@"SoundEffects2/uncloak.wav"];
    [soundEffects setObject:sound forKey:@"UNCLOAK_SOUND"];
    sound = [[SoundEffect alloc] init]; 
    [sound loadSoundWithName:@"SoundEffects2/transporter.wav"];
    [soundEffects setObject:sound forKey:@"TRANSPORTER_SOUND"];    
    sound = [[SoundEffect alloc] init]; 
    [sound loadSoundWithName:@"SoundEffects2/good-day-to-die.au"];
    [soundEffects setObject:sound forKey:@"I_DIED_SOUND"];  
    // we are done
    LLLog(@"SoundPlayerForMacTrek.loadSound done");
    [notificationCenter postNotificationName:@"SP_SOUNDS_CACHED"];
}

- (void) handleTransporter {
    [self playSoundEffect:@"TRANSPORTER_SOUND"];
}

- (void) handleDeath {
    [self playSoundEffect:@"I_DIED_SOUND"];
}

@end
