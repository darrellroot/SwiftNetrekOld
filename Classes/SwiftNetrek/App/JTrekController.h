//
//  JTrekController.h
//  MacTrek
//
//  Created by Aqua on 02/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "ClientController.h"
#import "LLTaskWrapper.h"
#import "BaseClass.h"

// cannot derive from ClientController or will create duplicate universe
@interface JTrekController : BaseClass <LLTaskWrapperController> {
    
    LLTaskWrapper *jtrek; 
    NSTextView *logDestination;
}

- (id)initWithTextView:(NSTextView *) logDestination;
- (void)startJTrekAt:(NSString *)server port:(int)port;
- (void)stopJTrek;

@end
