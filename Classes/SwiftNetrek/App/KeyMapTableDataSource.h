//
//  KeyMapTableDataSource.h
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "MTKeyMap.h"

@interface KeyMapTableDataSource : BaseClass {

    // must be tied to the tableview in question
    IBOutlet NSTableView *keyMapTableView;
    
    // our keymap
    MTKeyMap *myMap;   
}

- (void) setKeyMap:(MTKeyMap*) keyMap;
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex;
- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)column row:(int)row;
- (MTKeyMap *) keyMap;

@end
