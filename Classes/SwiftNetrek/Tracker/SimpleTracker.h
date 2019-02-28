//
//  SimpleTracker.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 19/11/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"
#import "Data.h"
#import "TrackUpdate.h"
#import "LLTrigonometry.h"
#import "LLNotificationCenter.h"

// number of history to maintain
#define TRACK_HISTORY 10
// pixels in gamegrid per second
#define WARP1 200

@interface SimpleTracker : SimpleBaseClass {
	bool enabled;
	NSDate* referenceTime;
	LLTrigonometry *geoCalc;
	NSMutableArray *registeredEntities;
	LLNotificationCenter *notificationCenter;
}

+ (SimpleTracker*) defaultTracker;
- (bool) enabled;
- (void) setEnabled:(bool)onOff;
- (void) registerEntity:(Entity *)obj;
- (bool) isRegistered:(Entity *)obj;
- (void) deRegisterOject:(Entity *)obj;
- (void) predictForRegisteredEntities;
- (NSDate*)referenceTime;
- (void) setReferenceTime:(NSDate*)time;
- (NSPoint) positionForHistory:(NSMutableArray*)history;
- (NSPoint) positionAtTime:(NSDate*)time forHistory:(NSMutableArray*)history;

@end
