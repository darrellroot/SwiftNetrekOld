//
//  BaseClass.m
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "BaseClass.h"
#import <Cocoa/Cocoa.h>


@implementation BaseClass

- (id) init {
    self = [super init];
    if (self != nil) {
        notificationCenter = [LLNotificationCenter defaultCenter];
        //notificationCenter = NotificationCenter.default
        universe = [Universe defaultInstance];
    }
    return self;
}

@end
