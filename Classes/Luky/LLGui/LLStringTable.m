//
//  LLStringTable.m
//  MacTrek
//
//  Created by Aqua on 01/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLStringTable.h"

// this is quite a hack to fit LLStringLists in a view
// Views are not ment as helper objects

@implementation LLStringTable

- (void) awakeFromNib { // init is not called
    notificationCenter = [LLNotificationCenter defaultCenter];
    columns = [[NSMutableArray alloc] init];
    // need at least 1
    LLStringList *list = [[LLStringList alloc] init];
    [list setFrame:[self frame]];
    [list setBounds:[self bounds]];
    [list awakeFromNib];
    [columns addObject:list];
    
    hasChanged = NO;
}

- (bool) hasChanged {
    return hasChanged;
}

- (void) disableSelection {
    hasChanged = YES;
}

// my brain works the other way around
- (BOOL) isFlipped {
    return YES;
}

- (void)drawRect:(NSRect)aRect {
    
    aRect = [self bounds]; // always completely redraw
    //LLLog(@"LLStringTable.drawRect x=%f, y=%f, w=%f, h=%f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
    
    int nrOfColumns = [columns count];
    int columnWidth = [self bounds].size.width / [columns count];
    
    aRect.size.width = columnWidth;
    
    for (int i = 0; i < nrOfColumns; i++) {
        LLStringList *list = [columns objectAtIndex:i];
        [list setBounds:aRect]; // we have abused LLStringList so tell the bounds if we resized
        [list drawRect:aRect];
        aRect.origin.x += columnWidth;
    }    
    hasChanged = NO;
}

- (NSPoint) mousePos {
    // get mouse point in window
    NSPoint mouseBase = [[self window] mouseLocationOutsideOfEventStream];
    
    // convert to view coordinates
    NSPoint mouseLocation = [self convertPoint:mouseBase fromView:nil];
    
    return mouseLocation;
}

- (void) mouseDown:(NSEvent *)theEvent {
    
    NSPoint mousePosition = [self mousePos];
    
    int columnWidth = [self bounds].size.width / [columns count];
    int selectedColumn = mousePosition.x / columnWidth;
 //   LLLog(@"LLStringTable.mouseDown selected column is now %d", selectedColumn);
    
    int nrOfColumns = [columns count];
    for (int i = 0; i < nrOfColumns; i++) {
        LLStringList *list = [columns objectAtIndex:i];
        if (i == selectedColumn) {
            int row = mousePosition.y / [list rowHeigth];            
            [list setSelectedRow:row];
            [self newStringSelected:[list selectedString]];
        } else {
            [list disableSelection];
        }

    }      
       
    hasChanged = YES;
}

- (void) newStringSelected:(NSString*)str { // to be overwritten
    [notificationCenter postNotificationName:@"LL_STRING_TABLE_SELECTION" object:self userInfo:str];
}

- (void) emptyAllColumns {
    int nrOfColumns = [columns count];
    for (int i = 0; i < nrOfColumns; i++) {
        LLStringList *list = [columns objectAtIndex:i];
        [list emptyAllRows];
    }
}

- (int)  maxNrOfRows {
    LLStringList *col0 = [columns objectAtIndex:0]; // always there
    return [col0 maxNrOfStrings];
}

- (void) setNrOfColumns:(int)newNrOfColumns {
    if (newNrOfColumns < 1) {
        return;
    } 
    
    // set up the bounds of the columns
    NSRect listBounds = [self bounds];
    listBounds.size.width /= newNrOfColumns;
    
    // delete
    for (int i = newNrOfColumns; i < [columns count]; i++) {
        [columns removeLastObject];
//        LLLog(@"LLStringTable.setNrOfColumns removing column");
    }
    
    // add
    for (int j = [columns count]; j < newNrOfColumns; j++) {
        LLStringList *list = [[LLStringList alloc] init];
        [list setIdentifer:[NSString stringWithFormat:@"[column %d]", j]];
        [columns addObject:list];
 //       LLLog(@"LLStringTable.setNrOfColumns adding column %d", j);
    }   
    
    // set bounds of ALL
    for (int k = 0; k < [columns count]; k++) {
        LLStringList *list = [columns objectAtIndex:k];
        //LLLog(@"LLStringTable.setNrOfColumns (%d) x=%f, y=%f, w=%f, h=%f", k, listBounds.origin.x, listBounds.origin.y, listBounds.size.width, listBounds.size.height);
        [list setFrame:listBounds];
        [list setBounds:listBounds];
        [list awakeFromNib];
        listBounds.origin.x += listBounds.size.width;
    }
    hasChanged = YES;
}

- (void) removeString:(NSString *)str fromColumn:(int)column {
    if (column >= [columns count]) {
        LLLog(@"LLStringTable.removeString column %d does not exist", column);
        return; // column does not exist
    }
    LLStringList *list = [columns objectAtIndex:column];
    [list removeString:str];
    hasChanged = YES;    
}

- (void) addString:(NSString *)str toColumn:(int)column {
    if (column >= [columns count]) {
        LLLog(@"LLStringTable.addString column %d does not exist", column);
        return; // column does not exist
    }
//    LLLog(@"LLStringTable.addString [%@] to column %d", str, column);
    LLStringList *list = [columns objectAtIndex:column];
    [list addString:str];
    hasChanged = YES;
}

- (void) addString:(NSString *)str withColor:(NSColor *)col toColumn:(int)column {
    if (column >= [columns count]) {
        LLLog(@"LLStringTable.addStringWithColor column %d does not exist", column);
        return; // column does not exist
    }
    LLStringList *list = [columns objectAtIndex:column];
 //   LLLog(@"LLStringTable.addStringWithColor [%@] to column %d", str, column);
    [list addString:str withColor:col];
    hasChanged = YES;
}

@end
