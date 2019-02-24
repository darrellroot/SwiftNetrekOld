//
//  LLHost.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 17/04/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

@interface LLHost : LLObject {
	NSString *name;
}

+ (LLHost *)hostWithName:(NSString *)hostname; 
+ (LLHost *)hostWithAddress:(NSString *)address;
- (NSString *)hostname;
- (NSString *)address; // the first ip number
- (NSArray *)addresses;
- (NSData *)firstAddressData;

@end
