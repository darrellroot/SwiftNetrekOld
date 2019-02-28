//
//  SimpleTracker.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 19/11/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "SimpleTracker.h"


@implementation SimpleTracker

SimpleTracker *defaultTracker = nil;

- (id) init {
	self = [super init];
	if (self != nil) {
		geoCalc = [LLTrigonometry defaultInstance];
		registeredEntities = [[NSMutableArray alloc] init];
		notificationCenter = [LLNotificationCenter defaultCenter];
		[notificationCenter addObserver:self selector:@selector(predictForRegisteredEntities) name:@"SERVER_READER_READ_SYNC"
								 object:nil useLocks:NO useMainRunLoop:NO];
	}
	return self;
}

+ (SimpleTracker*) defaultTracker {
    if (defaultTracker == nil) {
        defaultTracker = [[SimpleTracker alloc] init];
    }
    return defaultTracker;
}

- (bool) isRegistered:(Entity *)obj {
	return [registeredEntities containsObject:obj];
}

- (void) registerEntity:(Entity *)obj {
	if (![self isRegistered:obj]) {
		[registeredEntities addObject:obj];
		[obj setTracked:YES];
	} else {
		LLLog(@"SimpleTracker.registerEntity double entry");
	}
}

- (void) deRegisterOject:(Entity *)obj {
	if ([self isRegistered:obj]) {
		[registeredEntities removeObject:obj];
		[obj setTracked:NO];
	} else {
		LLLog(@"SimpleTracker.deRegisterOject unknown entry");
	}
}

- (void) predictForRegisteredEntities {
	
	// actually is not a predict,
	// but a synchronize against the positions that
	// we received
	//LLLog(@"SimpleTracker.predictForRegisteredEntities syncing");
	
	unsigned int i, count = [registeredEntities count];
	for (i = 0; i < count; i++) {
		Entity* obj = [registeredEntities objectAtIndex:i];
		[obj setSyncedPosition:[obj position]];
	}
}

- (void) setEnabled:(bool)onOff {
	enabled = onOff;
}

- (bool) enabled {
	return enabled;
}

- (NSPoint) positionAtTime:(NSDate*)time forHistory:(NSMutableArray*)history {
	
/* 
	----------------------------------------------------
	attempt 1 
	
	direct extrapolation... no very good. Speed is wonky
	---------------------------------------------------- */
  
	// try last used position
	TrackUpdate *track = [history objectAtIndex:0];
	// get position
	NSPoint lastPosition = [track position];
	
	// sanity check
	if ([track speed] == 0) {
		// i know exactly where he is
		return [track position];
	}
	
	// linear extrapolation
    double elapsedSeconds = [time timeIntervalSinceDate:[track timeStamp]];

	// extrapolate
    lastPosition.x += (double) ([track speed] * WARP1 * elapsedSeconds) * cos([track course]);
	lastPosition.y += (double) ([track speed] * WARP1 * elapsedSeconds) * sin([track course]);
 /*
    float dx = (lastPosition.x - [track position].x);
	float dy = (lastPosition.y - [track position].y);
 
	if (((dx > 0.0) || (dy > 0.0)) && ([track ident] != nil)) {
		LLLog(@"%@ O(%f, %f) P(%f, %f) D(%f, %f)", [track ident],
			  [track position].x, [track position].y, 
			  lastPosition.x, lastPosition.y, 
			  dx, dy);
	}
	*/
    
	
	/*
	 ----------------------------------------------------
	 attempt 2	 
	 
	 hmm worse... couse seems better though
	 ----------------------------------------------------

	
	if ([history count] < 2) {
		//LLLog(@"SimpleTracker.positionAtTime not enough data %d for %@",[history count], [[history objectAtIndex:0] ident]);
		return [[history objectAtIndex:0] position];
	}
	
	// try last used position
	TrackUpdate *track1 = [history objectAtIndex:0];
	TrackUpdate *track2 = [history objectAtIndex:1];
	// get position
	NSPoint pos1 = [track1 position];
	NSPoint pos2 = [track2 position];
	
	// get distance
	float distance = [geoCalc floatHypotOfBase:(pos2.x - pos1.x) heigth:(pos2.y - pos1.y)];
	// interval
	double interval = [track1 timeStamp] - [track2 timeStamp];
	// speed
	double speed = distance / (interval * 200);
	
	// course (90 deg turned grid)
	float course = ([geoCalc angleDegBetween:pos2 andPoint:pos1] + 90);
	
    // linear extrapolation
    double elapsedSeconds = [time timeIntervalSinceDate:[track1 timeStamp]];
	
	// extrapolate
	NSPoint lastPosition = pos1;
	
    lastPosition.x += (double) (speed * WARP1 * elapsedSeconds) * cos(course);
	lastPosition.y += (double) (speed * WARP1 * elapsedSeconds) * sin(course);
	/*
    float dx = (lastPosition.x - pos1.x);
	float dy = (lastPosition.y - pos1.y);
	
	if (((dx > 0.0) || (dy > 0.0)) && ([track1 ident] != nil)) {
		LLLog(@"%@ O(%f, %f) P(%f, %f) D(%f, %f) S%f(%d) C%f(%d)", [track1 ident],
			  pos1.x, pos1.y, 
			  lastPosition.x, lastPosition.y, 
			  dx, dy, speed, [track1 speed], course, [track1 course]);
		
	}
	*/
	 /*
	 ----------------------------------------------------
	 attempt 3	 
	 ----------------------------------------------------
	  */
	 
	return lastPosition;

}
	
- (NSPoint) positionForHistory:(NSMutableArray*)history {
		
		return [self positionAtTime:referenceTime forHistory:history];
}

- (NSDate*)referenceTime {
	return referenceTime;
}

- (void) setReferenceTime:(NSDate*)time {
	[referenceTime release];
	referenceTime = time;
	[referenceTime retain];
}

@end
