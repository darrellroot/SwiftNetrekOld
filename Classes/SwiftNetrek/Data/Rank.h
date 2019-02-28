//
//  Rank.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"

@interface Rank : SimpleBaseClass {
	float hours; 
	float ratings;
	float defense;
	NSString *name;
    NSString *abbrev;
}

-(id)initWithHours:(float)hrs ratings:(float)rate defense:(float)def name:(NSString*)rankName  abbrev:(NSString*)rankAbb ;

-(NSString *)name;
-(NSString *)abbrev;

@end
