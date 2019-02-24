//
//  BaseClass.h
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"

@class BaseClass;

#import "Universe.h"

@interface BaseClass : SimpleBaseClass {
    LLNotificationCenter *notificationCenter;
    Universe *universe;
}

@end
