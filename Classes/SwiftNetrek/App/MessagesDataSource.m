//
//  MessagesDataSource.m
//  MacTrek
//
//  Created by Aqua on 02/06/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MessagesDataSource.h"


@implementation MessagesDataSource

int maxMessages = 20; // $$ reduce a bit to avoid heavy load during reload..
NSMutableArray *messages = nil;

- (id) init {
    self = [super init];
    if (self != nil) {
        universe = [Universe defaultInstance];
        messages = [[NSMutableArray alloc] init];
        [self newMessage:@"Client started"];
    }
    return self;
}

- (void) awakeFromNib {
    // this could be quite heavy for the runloop.... (checked = OK)
    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SP_S_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:YES];
    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SPW_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:YES];
    [notificationCenter addObserver:self selector:@selector(newMessageInDictionairy:) name:@"SP_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:YES];
    
    // warnings are sent to a seperate text field now
    //[notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SP_WARNING"];
    
    // used only for debug...
    //[notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SP_MOTD"];
    //[notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SP_MOTD_SERVER_INFO"];

}

- (void) newMessageInDictionairy:(NSDictionary*)package {

    NSString *message = [package objectForKey:@"message"];
//    NSNumber *flags   = [package objectForKey:@"flags"];
//    NSNumber *from    = [package objectForKey:@"from"];
//    NSNumber *to      = [package objectForKey:@"to"]; 

    // i think we should do something with the flags ...
    // handle colours etc.
    // $$ see IncommingMessageHandler in JTrek
    
    [self newMessage:message];
}

// tie this to events that change messages
- (void) newMessage:(NSString *)message {
    
    // test for new
    if (universe == nil) {        
        return;
    }
    
    if (message == nil) {        
        return;
    }
    
    // add it
    LLLog(@"MessagesDataSource.newMessage (%@)", message);
    [messages addObject:message];
    if ([messages count] > maxMessages) {
        [messages removeObjectAtIndex:0];
    }
    
    // show it
    [messagesList reloadData];
    // make the last row visible
    [messagesList scrollRowToVisible:[messages count] - 1];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [messages count];
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {

    NSString *message = [messages objectAtIndex:rowIndex];
    //LLLog(@"MessagesDataSource.valueForRow (%@)", message);
    return message;
}

@end
