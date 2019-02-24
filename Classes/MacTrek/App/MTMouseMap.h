//
//  MTMouseMap.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 23/02/2007.
//  Copyright 2007 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "MTKeyMap.h"

@interface MTMouseMap : NSObject {
	int actionMouseLeft;
	int actionMouseMiddle;
	int actionMouseRight;
	int actionMouseWheel;
}

- (int) actionMouseLeft;
- (int) actionMouseMiddle;
- (int) actionMouseRight;
- (int) actionMouseWheel;

- (void) setActionMouseLeft:(int)action;
- (void) setActionMouseMiddle:(int)action;
- (void) setActionMouseRight:(int)action;
- (void) setActionMouseWheel:(int)action;

@end
