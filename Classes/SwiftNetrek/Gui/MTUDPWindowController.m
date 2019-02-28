//
//  MTUDPWindowController.h
//  MacTrek
//
//  Created by Aqua on 26/05/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//
#import "MTUDPWindowController.h"

@implementation MTUDPWindowController

- (id) init {
	self = [super init];
	if (self != nil) {
		stats = nil;
		
		// connect to changes in communication thread
		[notificationCenter addObserver:self selector:@selector(commStateChanged:) name:@"COMM_STATE_CHANGED"];
		[notificationCenter addObserver:self selector:@selector(commModeChanged:) name:@"COMM_MODE_CHANGED"];
		[notificationCenter addObserver:self selector:@selector(refreshUdpStats:) name:@"COMM_UDP_STATS_CHANGED"];
	}
	return self;
}


- (void)awakeFromNib {
	
	// connect to changes in the gui
    [channelState setTarget:self];
    [channelState setAction:@selector(channelStateChanged:)];
    [sequenceChecking setTarget:self];
    [sequenceChecking setAction:@selector(sequenceCheckingChanged:)];
	[sendModeBox setTarget:self];
	[sendModeBox setAction:@selector(sendModeChanged:)];
	[receiveModeBox setTarget:self];
	[receiveModeBox setAction:@selector(receiveModeChanged:)];
	
	// set defaults
	[sendModeBox selectItemAtIndex:MODE_SIMPLE];
	[receiveModeBox selectItemAtIndex:MODE_SIMPLE];
}

- (NSString*) modeString:(NSNumber*)newValue {
	switch([newValue intValue]) {
		case COMM_TCP:
			return @"COMM_TCP";
			break;
		case COMM_UDP:
			return @"COMM_UDP";
			break;
		default:
			return @"ILLIGAL";
			break;
	}
}

- (NSString*) stateString:(NSNumber*)newValue {
	switch([newValue intValue]) {
		case STAT_CONNECTED:
			return @"STAT_CONNECTED";
			break;
		case STAT_SWITCH_UDP:
			return @"STAT_SWITCH_UDP";
			break;
		case STAT_SWITCH_TCP:
			return @"STAT_SWITCH_TCP";
			break;
		case STAT_VERIFY_UDP:
			return @"STAT_VERIFY_UDP";
			break;
		default:
			return @"ILLIGAL";
			break;
	}
}

- (void)refreshUdpStats:(UdpStats*)newStats {
	
	if (stats != newStats) {
		[stats release];
		stats = newStats;
		[stats retain];
		LLLog(@"MTUDPWindowController.refreshUdpStats received new stats object");
	}
	
	int dropped = [stats udpDropped];
	int total = ([stats udpTotal] > 0 ? :  [stats udpTotal], 1);
	int recent = [stats udpRecentDropped];
	[statisticsField setStringValue:[NSString stringWithFormat:@"UDP trans dropped: %d (%d%% | %d%%)",  
		dropped, (dropped * 100 / total), (recent * 100 / UDP_RECENT_INTR)]];
}

- (void)commModeChanged:(NSNumber*)newMode {
	
	LLLog(@"MTUDPWindowController.commModeChanged %@", [self modeString:newMode]);
	
	switch([newMode intValue]) {
		case COMM_TCP:
			[statusField setStringValue:@"UDP Channel is CLOSED"];
			break;
		case COMM_UDP:
			[statusField setStringValue:@"UDP Channel is OPEN"];
			break;
		default:
			LLLog(@"MTUDPWindowController.commModeChanged illigal mode %d", [newMode intValue]);
			break;
	}
}

- (void)commStateChanged:(NSNumber*)newState {
	
	LLLog(@"MTUDPWindowController.commStateChanged %@", [self stateString:newState]);
	
	switch([newState intValue]) {
		case STAT_CONNECTED:
			[statusField setStringValue:@"Connected, yay us!"];
			break;
		case STAT_SWITCH_UDP:
			[statusField setStringValue:@"Requesting switch to UDP"];
			break;
		case STAT_SWITCH_TCP:
			[statusField setStringValue:@"Requesting switch to TCP"];
			break;
		case STAT_VERIFY_UDP:
			[statusField setStringValue:@"Verifying UDP connection"];
			break;
		default:
			LLLog(@"MTUDPWindowController.commStateChanged illigal state %d", [newState intValue]);
			break;
	}
}

- (void)channelStateChanged:(NSSegmentedControl*)sender {
	
	NSString *selectedLabel = [sender labelForSegment: [sender selectedSegment]];
	
	if ([selectedLabel isEqualToString:@"OPEN"]) {
		// open UDP channel
		[notificationCenter postNotificationName:@"COMM_SEND_UDP_REQ" userInfo:[NSNumber numberWithChar:COMM_UDP]];
		// enable the buttons
		[updateAllButton setEnabled:YES];
		[resetButton setEnabled:YES];
	} else if ([selectedLabel isEqualToString:@"CLOSE"]) {
		// close UDP channel
		[notificationCenter postNotificationName:@"COMM_SEND_UDP_REQ" userInfo:[NSNumber numberWithChar:COMM_TCP]];
		// disanable the buttons
		[updateAllButton setEnabled:NO];
		[resetButton setEnabled:NO];
	} else {
		// oh oh
		LLLog(@"MTUDPWindowController.channelStateChanged illigal setting");
	}

}

- (void)sequenceCheckingChanged:(NSSegmentedControl*)sender {
	
	NSString *selectedLabel = [sender labelForSegment: [sender selectedSegment]];
	
	if ([selectedLabel isEqualToString:@"ON"]) {
		// activate sequence checking
		[notificationCenter postNotificationName:@"UC_UDP_SEQUENCE_CHECK" userInfo:[NSNumber numberWithBool:YES]];
	} else if ([selectedLabel isEqualToString:@"OFF"]) {
		// de-activate sequence checking
		[notificationCenter postNotificationName:@"UC_UDP_SEQUENCE_CHECK" userInfo:[NSNumber numberWithBool:NO]];
	} else {
		// oh oh 
		LLLog(@"MTUDPWindowController.sequenceChecking illigal setting");
	}
	
}

- (void)sendModeChanged:(NSComboBox*)sender {
	
	int choice = [sender indexOfSelectedItem];
	
	if ((choice < MODE_TCP) || (choice > MODE_DOUBLE)) {
		LLLog(@"MTUDPWindowController.sendModeChanged illigal setting");
	} else {
		[notificationCenter postNotificationName:@"UC_UDP_SEND_MODE" userInfo:[NSNumber numberWithChar:(choice & 0xFF)]];
	}

}

- (void)receiveModeChanged:(NSComboBox*)sender {
	
	int choice = [sender indexOfSelectedItem];
	
	if ((choice < MODE_TCP) || (choice > MODE_FAT)) {
		LLLog(@"MTUDPWindowController.sendModeChanged illigal setting");
	} else {
		[notificationCenter postNotificationName:@"UC_UDP_RECEIVE_MODE" userInfo:[NSNumber numberWithChar:(choice & 0xFF)]];
		[notificationCenter postNotificationName:@"COMM_SEND_UDP_REQ" userInfo:[NSNumber numberWithChar:COMM_MODE + (choice & 0xFF) ]];
	}
	
	
}

- (IBAction)resetToTcp:(id)sender {
	LLLog(@"MTUDPWindowController.resetToTcp called");
	[notificationCenter postNotificationName:@"COMM_FORCE_RESET_TO_TCP" userInfo:self];
	// reset modes to TCP
	[receiveModeBox selectItemAtIndex:0]; // top one
	[sendModeBox selectItemAtIndex:0];
	
	[self refreshUdpStats:stats];
}

- (IBAction)updateAll:(id)sender {
	LLLog(@"MTUDPWindowController.updateAll called");
	[notificationCenter postNotificationName:@"COMM_SEND_UDP_REQ" userInfo:[NSNumber numberWithChar:COMM_UPDATE]];
}

@end
