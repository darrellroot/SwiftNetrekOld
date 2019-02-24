//
//  LLView.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 14/11/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLView.h"

NSMutableDictionary* globalProperties;

@implementation LLView

// override ALL init methods !!
- (id) init {
	self = [super init];
	if (self != nil) {
		properties = [LLObject properties];
	}
	return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		properties = [LLObject properties];
	}
	return self;
}

// especially this one
- (id) initWithFrame:(NSRect)frameRect {
	self = [super initWithFrame:frameRect];
	if (self != nil) {
		properties = [LLObject properties];
	}
	return self;
}


@end
