//
//  LLLog.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 24/01/2007.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>

#define LLLog if([[NSUserDefaults standardUserDefaults]boolForKey:@"LLLogDisabled"]!=YES)NSLog