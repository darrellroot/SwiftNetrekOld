//
//  MTUDPWindowController.h
//  MacTrek
//
//  Created by Aqua on 26/05/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
// 
// Sends existing events:
//  COMM_SEND_UDP_REQ
//  COMM_FORCE_RESET_TO_TCP 
//
// Sends new events 
//  UC_UDP_SEQUENCE_CHECK (bool)
//  UC_UDP_SEND_MODE (number)
//  UC_UDP_RECEIVE_MODE (number)
//
// Listens to new events:
// 	COMM_STATE_CHANGED
//  COMM_MODE_CHANGED
//  COMM_UDP_STATS_CHANGED 

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "UdpStats.h"
#import "PacketTypes.h"

@interface MTUDPWindowController : BaseClass {
	
    IBOutlet NSSegmentedControl *channelState;
    IBOutlet NSComboBox *receiveModeBox;
    IBOutlet NSButton *resetButton;
    IBOutlet NSComboBox *sendModeBox;
    IBOutlet NSSegmentedControl *sequenceChecking;
    IBOutlet NSTextField *statisticsField;
    IBOutlet NSTextField *statusField;
    IBOutlet NSPanel *udpPanel;
    IBOutlet NSButton *updateAllButton;
	UdpStats *stats;
}
- (IBAction)resetToTcp:(id)sender;
- (IBAction)updateAll:(id)sender;

- (void)channelStateChanged:(NSSegmentedControl*)sender;
- (void)sequenceCheckingChanged:(NSSegmentedControl*)sender;
- (void)sendModeChanged:(NSComboBox*)sender;
- (void)receiveModeChanged:(NSComboBox*)sender;
- (void)refreshUdpStats:(UdpStats*)newStats;
- (void)commModeChanged:(NSNumber*)newMode;
- (void)commStateChanged:(NSNumber*)newState;

@end
