//
//  SoundEffect.h
//  MacTrek
//
//  Created by Aqua on 03/07/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
//#import "QTKit/QTMovie.h"
//#import "QuickTime/MediaHandlers.h"
//#import <AVKit>
//#import <AVFoundation>
#import "BaseClass.h"

#define SE_DEFAULT_INSTANCES 1

@interface SoundEffect : BaseClass {
    //QTMovie *sound;
	NSMutableArray *soundInstances;
	bool autogrow;
    NSString *name;
}

// low level api
//-(id) initSound:(QTMovie *)newSound withName:(NSString *)newName;
-(QTMovie *)sound;
-(NSString *)name;
//-(void) setSound:(QTMovie *)newSound;
-(void) setName:(NSString *)newName;

// high level api
-(bool) loadSoundWithName:(NSString*)soundName nrOfInstances:(int)nrOfInstances; 
-(bool) loadSoundWithName:(NSString*)soundName;
-(void) playWithVolume:(float)vol;
-(void) playWithVolume:(float)vol balance:(float)bal;
-(void) play;
-(void) stop;


@end
