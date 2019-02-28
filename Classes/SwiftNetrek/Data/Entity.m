//
//  Entity.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Entity.h"
#import "SimpleTracker.h"

SimpleTracker *tracker;

@implementation Entity

- (id) init {
    self = [super init];
    if (self != nil) {
        dir = 0;
        speed = 0;
        position.x = -1000;
        position.y = -1000;
        showInfo = NO;
		tracked = NO;
        fuse = 0;
        step = 1;
        maxfuse = 100;
		history = [[NSMutableArray alloc] init];
		tracker = [SimpleTracker defaultTracker];
		ident = @"unknown";
    }
    return self;
}

- (NSString*) ident {
    return ident;
}

- (NSString*) labelKey {
    return labelKey;
}

- (NSImage*)  label {
    return label;
}

- (NSImage*)  labelForKey:(NSString *)key {
    if ([key isEqualToString:labelKey]) {
        return label;
    }
    else {
        return nil;
    }
}

- (bool) setLabel:(NSImage*)newLabel forKey:(NSString *)newKey {
    // check if we know this one
    if ([newKey isEqualToString:labelKey]) {
        return YES;
    } 
    [labelKey release];
    [label release];
    label = newLabel;
    labelKey = newKey;
    [label retain];
    [labelKey retain];
    return NO;
}

- (void) setNetrekFormatCourse:(char)newDir {
    // netrek uses a byte 0-255 to represent a course
    // we use a float, 0-360
    dir = newDir * 360 / 255;
    if (dir < 0) {
        dir += 360;
    } 
}

- (void) setRequestedCourse:(int)newDir {
    requestedDir = newDir;
}

- (void) setRequestedSpeed:(int)fast {
    requestedSpeed = fast;
}

- (void) setDirInDeg:(float)newDir {
    dir = newDir;
}

- (void) setCourse:(int)newDir {
    dir = newDir;
    //[self trackUpdate];
}

- (void) setSpeed:(int)fast {
    speed = fast;
    //[self trackUpdate];
}

- (void) setPosition:(NSPoint)pos {
    position = pos;
    //[self trackUpdate];  depricated as of 1.2.0
}

- (void) setSyncedPosition:(NSPoint)pos {
    syncedPosition = pos;
}

// depricated as of 1.2.0
- (void) trackUpdate {	
	
	if ([tracker enabled]) {
		// create a tracking position
		// this can be done more efficient by reusing existing positions
		TrackUpdate *p = [[TrackUpdate alloc] initWithPosition: position 
														course: [self dirInRad] 
														 speed: speed];
		[p setIdent:[self ident]];
		[history insertObject: p atIndex:0];
		if ([history count] > TRACK_HISTORY) {
			p = [history lastObject];
			[history removeObject:p];
			[p release];
		}		
	}

}

- (void) setShowInfo:(bool)show {
    showInfo = show;
}

- (NSPoint) predictedPosition {

	if ([tracker enabled] && tracked) {
		//return [tracker positionForHistory:history];
		return syncedPosition;
	} else {
		return position;
	}    
}

- (NSPoint) position {
    return position;
}

- (char) netrekFormatCourse {
    return (dir * 255 / 360);
}

- (int) requestedCourse {
    return requestedDir;
}

- (int) requestedSpeed {
    return requestedSpeed;
}

- (void) setTracked:(bool)tr{
	tracked = tr;
}

- (int) course {
    return dir;
}

- (int) predictedCourse { // extend later
    return dir;
}

- (float) dirInDeg {
	return dir;
}

- (float) dirInRad {
    // int dir = 0..360 deg
    // radians are 0..2xpi
    return (dir * pi) / 180;    
}

- (int) speed {
    return speed;
}

- (bool)showInfo {
    return showInfo;
}

- (int)  fuse {
    return fuse;
}

- (int)  maxfuse {
    return maxfuse;
}

-(void) setMaxFuse:(int)newLevel {
    maxfuse = newLevel;
}

-(void) setFuseStep:(int)newLevel {
    step = newLevel;
}

-(void) setFuse:(int)newLevel {
    fuse = newLevel;
}

- (void) increaseFuse {
    fuse += step;
}

- (void) decreaseFuse {
    fuse -= step;
}

- (void) resetFuse {
    fuse = 0;
}

@end
