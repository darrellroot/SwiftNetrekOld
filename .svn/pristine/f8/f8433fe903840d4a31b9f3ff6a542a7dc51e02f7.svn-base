//
//  LLScreenShotController.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 9/6/06.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLTaskWrapper.h"
#import "LLObject.h"

@interface LLScreenShotController : LLObject <LLTaskWrapperController> {
    
    LLTaskWrapper *process; 
	int counter;
	bool isRunning;
}

// returns YES if successfull
- (bool)snap;

@end
