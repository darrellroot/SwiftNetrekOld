//
//  LLStringList.m
//  MacTrek
//
//  Created by Aqua on 01/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLStringList.h"


@implementation LLStringList

- (void) awakeFromNib { // init is not called
    notificationCenter = [LLNotificationCenter defaultCenter];
    NSFont *font = [NSFont fontWithName: @"Helvetica" size: 9.0];
    normalAttribute =[[NSMutableDictionary dictionaryWithObjectsAndKeys:
        [NSColor orangeColor], NSForegroundColorAttributeName,
        font , NSFontAttributeName, 
        nil] retain];
    stringList = [[NSMutableArray alloc] init];
    rowHeigth  = [@"teststring" sizeWithAttributes:normalAttribute].height;
    boxColor = [NSColor brownColor];
    selectedRow = -1;
    hasChanged = NO;
    [self setIdentifer:[NSString stringWithString:@"[LLStringList]"]];
}

- (int) maxNrOfStrings {
    return [self bounds].size.height / rowHeigth;
}

- (void) addString:(NSString *)str {
    [self addString:str withColor:[NSColor whiteColor]];
}

- (void) addString:(NSString *)str withColor:(NSColor *)col {
    
   // LLLog(@"LLStringList.addStringWithColor: [%@]  %@", str, name);
    
    // set up the attributes
    [normalAttribute setValue:col forKey:NSForegroundColorAttributeName];
    NSDictionary *attr = normalAttribute;
    
 /*
    NSDictionary *attr =[[NSDictionary dictionaryWithObjectsAndKeys:
        col, NSForegroundColorAttributeName,
        font , NSFontAttributeName, 
        nil] retain];
   */
    
    NSAttributedString *aStr = [[NSAttributedString alloc] initWithString:str
         attributes: [NSDictionary dictionaryWithDictionary:attr] ];
    
    // store
    [stringList addObject:aStr]; // add last
    if ([stringList count] > [self maxNrOfStrings]) {
        // remove first
        NSAttributedString *tempStr = [stringList objectAtIndex:0];
        [tempStr release];
        //TODO bug here, sometimes EXC_BAD_ACCESS in line below
        [stringList removeObjectAtIndex:0]; 
        
        // the selected row scrolled up
        if (selectedRow >= 0) {
            selectedRow--;
            //LLLog(@"LLStringList.addString selected row is now %d %@", selectedRow, name);
        }
    }
    
    // we changed
    hasChanged = YES;
    //[self setNeedsDisplay:YES];
	
	// free mem
	[aStr release];
}

// my brain works the other way around
- (BOOL) isFlipped {
    return YES;
}

- (void) setIdentifer:(NSString *)newName {
    [name release];
    name = newName;
    [name retain];
}

- (NSString *)name {
    return name;
}

- (void)drawRect:(NSRect)aRect {
    
    
    //aRect = [self bounds]; // always completely redraw
    //LLLog(@"LLStringList.drawRect x=%f, y=%f, w=%f, h=%f", aRect.origin.x, aRect.origin.y, aRect.size.width, aRect.size.height);
    
    // draw frame
    [[NSColor whiteColor] set];
    NSFrameRect(aRect);
    
    // start point
    NSPoint p = [self bounds].origin; 
    p.x += 1;
    
    // draw all the strings   
    for (int i = 0; i < [stringList count]; i++) {
        NSAttributedString *aStr = [stringList objectAtIndex:i];
        
        // draw selection box
        if (i == selectedRow) {
            NSRect box;
            box.size.height = rowHeigth;
            box.size.width = [self bounds].size.width - 2;
            box.origin = p;
            [boxColor set];
            NSFrameRect(box);
            [[boxColor colorWithAlphaComponent:0.3] set];
            NSRectFill(box);
        }
        
        // draw string
        [aStr drawAtPoint:p];
        //LLLog(@"LLStringList.draw string %@ at [%f, %f]", aStr, p.x, p.y);
        
        // specify the lower left corner
        p.y += rowHeigth;
    }
    hasChanged = NO;
}

- (bool) hasChanged {
    return hasChanged;
}

- (NSPoint) mousePos {
    // get mouse point in window
    NSPoint mouseBase = [[self window] mouseLocationOutsideOfEventStream];
    
    // convert to view coordinates
    NSPoint mouseLocation = [self convertPoint:mouseBase fromView:nil];
    
    return mouseLocation;
}

- (int) rowHeigth {
    return rowHeigth;
}

- (NSString*) selectedString {
   return [[stringList objectAtIndex:selectedRow] string]; 
}

- (void) setSelectedRow:(int)row {
    
    if (row > [stringList count]) {
        return;
    }
    
    selectedRow = row;
    
   // LLLog(@"LLStringList.setSelectedRow selected row is now %d %@", selectedRow, name);
    NSString *selectedString = [[stringList objectAtIndex:selectedRow] string];
    
    [self newStringSelected:selectedString]; // for derived classes
    
    hasChanged = YES;  
}

- (void) mouseDown:(NSEvent *)theEvent {
    
    NSPoint mousePosition = [self mousePos];
    
    int row = mousePosition.y / rowHeigth;
    
    [self setSelectedRow:row];
}

- (void) disableSelection {
    selectedRow = -1;
    hasChanged = YES;
}

- (void) removeString:(NSString *)str {
    int id = -1;
    for (int i = 0; i < [stringList count]; i++) {
        NSAttributedString *aStr = [stringList objectAtIndex:i];
        if ([[aStr string] isEqualToString:str]) {
            id = i; // cannot change while traversing
        }
    }
    if (id == -1) {
        LLLog(@"LLStringList.removeString error string [%@] not found %@", str, name);
        return;
    }
    [stringList removeObjectAtIndex:id];
    hasChanged = YES;
    
    if (selectedRow < 0) {
        return; // done
    }
    
    if (selectedRow == id) {
        selectedRow = -1; // deleted seleted row
        return;
    } 
    
    if (selectedRow > id) {
        selectedRow--; // shifted up
    }

}

- (void) emptyAllRows {
    [stringList removeAllObjects];
    hasChanged = YES;
}

- (void) newStringSelected:(NSString*)str { // to be overwritten
    [notificationCenter postNotificationName:@"LL_STRING_LIST_SELECTION" object:self userInfo:str];
}

@end

