//
//  LLGradientRect.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 20/09/2006.
//  Copyright 2006 __MyCompanyName__. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

#define LL_BLUE   @"blue"
#define LL_GREEN  @"green"
#define LL_YELLOW @"yellow"
#define LL_RED    @"red"
#define LL_GRAY   @"gray"

@interface LLGradientRect : LLObject {
	
	NSMutableDictionary *images;
}

- (void) addImage:(NSString*)name forKey:(NSString *) key;
- (void) fillRect:(NSRect) aRect withColor:(NSString*)col alpha:(float)alpha;

@end
