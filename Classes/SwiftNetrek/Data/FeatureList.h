//
//  FeatureList.h
//  MacTrek
//
//  Created by Aqua on 26/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"
#import "Feature.h"

#define FEATURE_LIST_FEATURE_PACKETS	 0
#define FEATURE_LIST_NEW_MACRO			 1
#define FEATURE_LIST_SMART_MACRO		 2
#define FEATURE_LIST_WHY_DEAD			 3
#define FEATURE_LIST_SB_HOURS			 4
#define FEATURE_LIST_CLOAK_MAXWARP		 5
#define FEATURE_LIST_SELF_8FLAGS		 6
#define FEATURE_LIST_SELF_8FLAGS2		 7
#define FEATURE_LIST_GEN_DISTRESS		 8
#define FEATURE_LIST_MULTILINE_ENABLED	 9
#define FEATURE_LIST_SHIP_CAP			 10
#define FEATURE_LIST_BEEPLITE			 11
#define FEATURE_LIST_CONTINUOUS_MOUSE	 12
#define FEATURE_LIST_CONTINUOUS_STEER	 13

@interface FeatureList : SimpleBaseClass {

    NSMutableArray *features;
}

- (int) valueForFeature:(int)feature;
- (void) checkFeature:(NSString*)name withType:(char)type withArg1:(int)arg1 withArg2:(int)arg2 withValue:(int)value;


@end
