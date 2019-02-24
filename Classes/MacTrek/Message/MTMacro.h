//
//  MTMacro.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 26/02/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "Luky.h"

#define MACRO_ME	 0
#define MACRO_PLAYER 1
#define MACRO_TEAM	 2
#define MACRO_FRIEND 3
#define MACRO_ENEMY	 4

#define MACRO_NBTM     0
#define MACRO_NEWM     1
#define MACRO_NEWMSPEC 2
#define MACRO_NEWMOUSE 3

@interface MTMacro : BaseClass {
	
	int type;
	char key;
	char who;
	NSString *macro;
}

- (id) initWithName:(NSString*)name macro:(NSString*)newMacro;
- (NSString*) keyAsString;
- (int) type;
- (char) key;
- (char) who;
- (NSString*) whoLongFormat;
- (NSString *)macroString;

@end
