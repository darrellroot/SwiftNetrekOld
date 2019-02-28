//
//  PlayerListDataSource.h
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "Data.h"

@interface PlayerListDataSource : BaseClass {
    IBOutlet NSTableView      *playerList;  
    IBOutlet NSPopUpButton    *toField;  // fill this to while we are at it
    NSMutableArray            *players;
    
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex;

- (void) refreshData;

@end
