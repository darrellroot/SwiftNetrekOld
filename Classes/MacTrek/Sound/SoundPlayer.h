//
//  SoundPlayer.h
//  MacTrek
//
//  Created by Aqua on 03/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "MacTrek-Swift.h"
#import "BaseClass.h"
#import "Data.h"
#import "SoundEffect.h"
#import "LLThreadWorker.h"

#define SP_MAX_RANGE 10000
#define SP_NORMAL_VOLUME 1.0 
@class SoundEffect;

@interface SoundPlayer : BaseClass {
    NSMutableDictionary *soundEffects;
    float volumeFX;
    float volumeMusic;

}

// called by init
- (void) subscribeToNotifications;
- (void) loadSounds;

// settings
- (void) unSubscibeToNotifications;
- (void) setVolumeFx:(float)vol;
- (void) setVolumeMusic:(float)vol;

// other
- (void) playSoundEffect:(NSString*) snd;
- (void) playSoundEffect:(SoundEffect*)sound relativeToEntity:(Entity*)obj;
- (void) playSoundEffect:(SoundEffect*)sound atAngle:(float)angle atDistance:(float)distance;

// handleFunctions
- (void) handleSpeedChangeRequest:(NSNumber*)reqSpeed;
- (void) handleAlertChanged:(NSNumber*)intAlert; 
- (void) handleCloakChanged:(NSNumber*)boolCloakOn;                   
- (void) handleMyPhaser:(Phaser*)phaser;
- (void) handleOtherPhaser:(Phaser*)phaser;
- (void) handleMyTorpFired:(Torp*)torp;
- (void) handleOtherTorpFired:(Torp*)torp;
- (void) handleTorpExploded:(Torp*)torp;
- (void) handleMyPlasmaFired:(Plasma*)plasma;
- (void) handleOtherPlasmaFired:(Plasma*)plasma;
- (void) handlePlasmaExploded:(Plasma*)plasma;

@end
