//
//  PacketTypesDebug.h
//  MacTrek
//
//  Created by Aqua on 20/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "PacketTypes.h"
#import "BaseClass.h"

#define LINE_WIDTH    30
#define DEBUG_PACKETS NO

@interface PacketTypesDebug : BaseClass {
    bool debugPackets;
}

// debug routines for easy reading
- (NSString *) serverPacketString:(int)packet;
- (NSString *) clientPacketString:(int)packet;
- (NSString *) shortPacketString:(int)packet;

// packet printer (default off)
- (void) printPacketInBuffer:(char *) buffer size:(int) size;
- (void) setDebugPackets:(bool)debug;
- (bool) debugPackets;

@end
