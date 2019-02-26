//
//  LLStringList.h
//  MacTrek
//
//  Created by Aqua on 01/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLNotificationCenter.h"
#import "LLView.h"

@interface LLStringList : LLView {
    LLNotificationCenter *notificationCenter;
    NSMutableDictionary *normalAttribute;
    NSMutableArray *stringList;
    int rowHeigth;
    int selectedRow;
    bool hasChanged;
    NSColor *boxColor;
    NSString *name;
}

- (void) setIdentifer:(NSString *)name;
- (NSString *)name;
- (bool) hasChanged;
- (void) disableSelection;
- (int)  maxNrOfStrings;
- (void) addString:(NSString *)str;
- (void) addString:(NSString *)str withColor:(NSColor *)col;
- (void) newStringSelected:(NSString*)str; // to be overwritten
- (void) removeString:(NSString *)str;
- (int)  rowHeigth;
- (void) setSelectedRow:(int)row;
- (void) emptyAllRows;
- (NSString*) selectedString;

@end

