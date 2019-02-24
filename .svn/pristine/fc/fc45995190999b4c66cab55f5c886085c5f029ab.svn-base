//
//  LLStringTable.h
//  MacTrek
//
//  Created by Aqua on 01/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "Luky.h"
#import "LLView.h"

@interface LLStringTable : LLView {
    NSMutableArray *columns;
    bool hasChanged;
    LLNotificationCenter *notificationCenter;
}

- (bool) hasChanged;
- (void) disableSelection;
- (int)  maxNrOfRows; 
- (void) setNrOfColumns:(int)newNrOfColumns;
- (void) addString:(NSString *)str toColumn:(int)column;
- (void) addString:(NSString *)str withColor:(NSColor *)col toColumn:(int)column;
- (void) removeString:(NSString *)str fromColumn:(int)column;
- (void) emptyAllColumns;
- (void) newStringSelected:(NSString*)str; // to be overitten

@end
