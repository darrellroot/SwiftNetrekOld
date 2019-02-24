//
//  MTTipOfTheDayController.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 26/05/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"

@interface MTTipOfTheDayController : BaseClass {
	LLHUDWindowController *tipOfTheDayWindowController; 
	NSArray *tips;
	NSDictionary *latestVersion;
}

- (void) showTip;
- (bool) newVersionAvailable;
- (bool) showNewVersionIndicationIfAvailable;

@end
