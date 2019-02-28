//-------------------------------------------
// File:  MetaServerParser.h
// Class: MetaServerParser
// 
// Created by Chris Lukassen 
// Copyright (c) 2006 Luky Soft
//-------------------------------------------

#import <Cocoa/Cocoa.h>
#import "LLNetwork.h"
#import "MetaServerEntry.h"
#import "BaseClass.h"

@interface MetaServerParser : BaseClass {
  
} 
 
- (NSMutableArray *) readFromMetaServer:(NSString *) server atPort:(int)port;
- (NSMutableArray *) parseInputFromStream:(LLSocketStream *) stream;
 
@end
