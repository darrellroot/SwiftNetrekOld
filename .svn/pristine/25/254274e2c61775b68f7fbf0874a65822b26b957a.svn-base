//
//  RobotsController.h
//  MacTrek
//
//  Created by Aqua on 02/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "LLTaskWrapper.h"
#import "BaseClass.h"

@interface RobotsController : BaseClass <LLTaskWrapperController> {
    
    NSMutableArray *robots; // holds LLTaskWrappers
    bool restart;
    NSTextView *logDestination;
    
    NSString *pathToRobot;
    NSArray  *fedNames;
    NSArray  *kliNames;
}

- (id)initWithTextView:(NSTextView *) logDestination;
- (void)startRobots:(int)numOfRobots;
- (void)stopRobots;

@end
