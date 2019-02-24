//
//  Feature.h
//  MacTrek
//
//  Created by Aqua on 26/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"

#define FEATURE_SERVER_TYPE  'S'
#define FEATURE_CLIENT_TYPE  'C'

#define FEATURE_ALREADY_SENT  NO
#define FEATURE_SEND_FEATURE  YES

#define FEATURE_UNKNOWN  -1
#define FEATURE_OFF       0
#define FEATURE_ON        1

@interface Feature : SimpleBaseClass {
    
	NSString *name;
	char type;
	int desired_value;
	int arg1;
	int arg2;
	bool send_with_rsa;
	int value;   
}

- (id) initWithName:(NSString *)name type:(char)t desiredValue:(int)val sendWithRSA:(bool) rsa;
- (int)value;
- (NSString*)name;
- (char) type;
- (int) desiredValue;
- (int) arg1;
- (int) arg2;
- (bool) sendWithRSA;

-(void) setValue:(int)val;
-(void) setArg1:(int)a1; 
-(void) setArg2:(int)a2;


@end
