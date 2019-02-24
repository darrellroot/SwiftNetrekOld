//
//  MessagesListView.m
//  MacTrek
//
//  Created by Aqua on 01/08/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MessagesListView.h"
#import "MessageConstants.h"

@implementation MessagesListView

- (void) awakeFromNib {
    [super awakeFromNib];
    
    universe = [Universe defaultInstance];

    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SP_S_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:YES];
    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"PM_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:NO]; // is already in main loop
    [notificationCenter addObserver:self selector:@selector(newMessage:) name:@"SPW_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:YES];
    [notificationCenter addObserver:self selector:@selector(newMessageInDictionairy:) name:@"SP_MESSAGE" 
                             object:nil useLocks:NO useMainRunLoop:YES];    
    
    // user clicked on player list, disable our selection
    [notificationCenter addObserver:self selector:@selector(disableSelection) name:@"PV_PLAYER_SELECTION"];
    // user manually choose a destination, disable our selection
    // $$$ [notificationCenter addObserver:self selector:@selector(disableSelection) name:@""];
	
	// when a new game is started we must clean up
	[notificationCenter addObserver:self selector:@selector(emptyAllRows) name:@"LM_LOGIN_COMPLETE"];	
}

// tie this to events that change messages
- (void) newMessage:(NSString *)message {
    
    if ((message == nil) ||
        ([message length] <= 0)) {        
        return;
    }
    
    // add it
    LLLog(@"MessagesListView.newMessage (%@)", message);
    [self addString:message];
	// report the addition
	[notificationCenter postNotificationName:@"MV_NEW_MESSAGE" object:self userInfo:message];
}

- (void) newMessageInDictionairy:(NSDictionary*)package {
    
    NSString *message = [package objectForKey:@"message"];
    int flags   = [[package objectForKey:@"flags"] intValue];
    int from    = [[package objectForKey:@"from"] intValue];
    //int to      = [[package objectForKey:@"to"] intValue]; 
    
    if ((message == nil) ||
        ([message length] <= 0)) {
        LLLog(@"MessagesListView.newMessageInDictionairy empty message"); 
        return;
    }
    
    // find out the colour     
    NSColor *color = [NSColor grayColor];
    if (from >= 0 && from < UNIVERSE_MAX_PLAYERS) {
        color = [[[universe playerWithId:from] team] colorForTeam];
    }
        
    // A new type distress/macro call came in. parse it appropriately
    if (flags == (TEAM | DISTR | VALID)) {
        
        LLLog(@"MessagesListView.newMessageInDictionairy distress not parsed.. (%@)", message);
        return;
        /*
        Distress distress = new Distress(data, message, from);
        message = macro_handler.parseMacro(distress);
        if(message.length() < 0) {
            return;
        }

        flags ^= DISTR;
         */
    } 
    
    [self addString:message withColor:color];
	// report the addition
	[notificationCenter postNotificationName:@"MV_NEW_MESSAGE" object:self userInfo:message];
}

- (void) newStringSelected:(NSString*)str { 
    [notificationCenter postNotificationName:@"MV_MESSAGE_SELECTION" object:self userInfo:str];
}

@end
