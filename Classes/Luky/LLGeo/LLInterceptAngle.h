//
//  LLInterceptAngle.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLTarget.h"
#import "LLObject.h"

// return a large angle if none found
#define INTERCEPT_NOT_POSSIBLE 1000 

@interface LLInterceptAngle : LLObject {

}

- (int) angleForTarget:(LLTarget*) target fromSource:(LLTarget*)source projectileSpeed:(int)speed;

@end
