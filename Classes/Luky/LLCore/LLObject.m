//
//  LLObject.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 14/11/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLObject.h"

NSMutableDictionary* globalProperties;

@implementation LLObject

- (id) init {
	self = [super init];
	if (self != nil) {
		properties = [LLObject properties];
	}
	return self;
}

+ (NSMutableDictionary*) properties {
    if (globalProperties == nil) {
        globalProperties = [[NSMutableDictionary alloc] init];
    }
    return globalProperties;
}

@end
