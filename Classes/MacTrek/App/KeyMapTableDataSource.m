//
//  KeyMapTableDataSource.m
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "KeyMapTableDataSource.h"


@implementation KeyMapTableDataSource

- (id) init {
    self = [super init];
    if (self != nil) {
        // allocate the default map
        myMap = [[MTKeyMap alloc] init];
        // initial query is in seperate thread
       //[NSThread detachNewThreadSelector:@selector(readDefaultKeyMap) toTarget:myMap withObject:nil];
       [myMap readDefaultKeyMap]; // except when debugging
	   [keyMapTableView performSelector: @selector(reloadData) withObject:nil afterDelay: 1.0];

    }
    return self;
}

- (void) setKeyMap:(MTKeyMap*) keyMap {
    if (keyMap != nil) {
		[myMap release];
        myMap = keyMap;
		[keyMapTableView performSelector: @selector(reloadData) withObject:nil afterDelay: 1.0];		
    }
}

- (void) awakeFromNib {
	// hmmm seems not to be called at all ?
	// -> yes! but if changed, delete and reinstantiate the SettingsController in the
	// NIB since the object is archived
	[keyMapTableView reloadData];
	[keyMapTableView noteNumberOfRowsChanged];
	LLLog(@"KeyMapTableDataSource.awakeFromNib");
}

- (MTKeyMap *) keyMap {
    return myMap;
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {

    if (keyMapTableView == aTableView) {
		//LLLog(@"KeyMapTableDataSource.numberOfRowsInTableView %d", [myMap count]);
        return [myMap count];
    }
    return 0;
}

// copy from manual
int intSort(id num1, id num2, void *context) {
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
    if (v1 < v2)
        return NSOrderedAscending;
    else if (v1 > v2)
        return NSOrderedDescending;
    else
        return NSOrderedSame;
}

int keyMapEntrySort(id num1, id num2, void *context) {
	
	if (context == NULL) {
		LLLog(@"KeyMapTableDataSource.keyMapEntrySort error, cannot sort without a context");
		return -1;
	}
	
	MTKeyMap *myMap = context;
	
    int v1 = [num1 intValue];
    int v2 = [num2 intValue];
	
	NSString *d1 = [myMap descriptionForAction:v1];
	NSString *d2 = [myMap descriptionForAction:v2];
	
    return [d1 compare:d2];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {
   //LLLog(@"KeyMapTableDataSource.objectValueForTableColumn row %d", rowIndex);
	
    if (keyMapTableView == aTableView) {
        NSArray *actionKeys = [myMap allKeys];
		// sort the array (much nicer)
		NSArray *sortedKeys = [actionKeys sortedArrayUsingFunction:keyMapEntrySort context:myMap];
		/*
		// dump the array to check the sort
		unsigned int i, count = [actionKeys count];
		for (i = 0; i < count; i++) {
			LLLog(@"KeyMapTableDataSource.objectValueForTableColumn key %d, value %d", i, [[sortedKeys objectAtIndex:i] intValue]);
		}
		*/
        int action = [[sortedKeys objectAtIndex:rowIndex] intValue];
		
	    //LLLog(@"KeyMapTableDataSource.objectValueForTableColumn row %d action key %d key %c description %@", rowIndex, action, [myMap keyForAction:action], [myMap descriptionForAction:action]);
				
        if ([[aTableColumn identifier] isEqualTo: @"description"]) {
            return [myMap descriptionForAction:action];
        } else if ([[aTableColumn identifier] isEqualTo: @"key"]) {
            return [NSString stringWithFormat:@"%c", [myMap keyForAction:action]];
        } else {
            return @"ERROR"; // unknown column
        }
    }
    return @"ERROR";
}

// delegate functions
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
    if ([[aTableColumn identifier] isEqualToString:@"description"]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object
   forTableColumn:(NSTableColumn *)column row:(int)row {
    
    // only the key column is editable
    if (tableView == keyMapTableView) {           
        NSArray *actionKeys = [myMap allKeys];
		// sort the array (much nicer)
		/*
		unsigned int i, count = [actionKeys count];
		for (i = 0; i < count; i++) {
			int j = [[actionKeys objectAtIndex:i] intValue];

			LLLog(@"KeyMapTableDataSource.setObjectValue before action index %d, key %d key %c description %@",i, j, [myMap keyForAction:j], [myMap descriptionForAction:j]);
		}*/
		
		NSArray *sortedKeys = [actionKeys sortedArrayUsingFunction:keyMapEntrySort context:myMap];
		/*
		for (i = 0; i < count; i++) {
			int j = [[sortedKeys objectAtIndex:i] intValue];
			LLLog(@"KeyMapTableDataSource.setObjectValue after action index %d, key %d key %c description %@",i, j, [myMap keyForAction:j], [myMap descriptionForAction:j]);
		}
		*/
        int action = [[sortedKeys objectAtIndex:row] intValue];				
		LLLog(@"KeyMapTableDataSource.setObjectValue row %d action key %d key %c description %@", row, action, [myMap keyForAction:action], [myMap descriptionForAction:action]);
		
		        // only accept a single character
        // use of a formatter would be better
        if ([object length] == 1) {
            NSString *newkey = object;
            char c = [newkey characterAtIndex:0];
            [myMap setKey:c forAction:action];
        }
    }
}


@end
