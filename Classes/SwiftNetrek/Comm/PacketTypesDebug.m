//
//  PacketTypesDebug.m
//  MacTrek
//
//  Created by Aqua on 20/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PacketTypesDebug.h"


@implementation PacketTypesDebug

- (id) init {
    self = [super init];
    if (self != nil) {
        debugPackets = DEBUG_PACKETS;
    }
    return self;
}

- (void) setDebugPackets:(bool)debug {
    debugPackets = debug;
}

- (bool) debugPackets {
    return debugPackets;
}

- (NSString *) serverPacketString:(int)packet {
    switch (packet) {
        case SP_MESSAGE:
            return @"SP_MESSAGE";
            break;
        case SP_PLAYER_INFO:
            return @"SP_PLAYER_INFO";
            break;
        case SP_KILLS:
            return @"SP_KILLS";
            break;
        case SP_PLAYER:
            return @"SP_PLAYER";
            break;
        case SP_TORP_INFO:
            return @"SP_TORP_INFO";
            break;
        case SP_TORP:
            return @"SP_TORP";
            break;
        case SP_PHASER:
            return @"SP_PHASER";
            break;
        case SP_PLASMA_INFO:
            return @"SP_PLASMA_INFO";
            break;
        case SP_PLASMA:
            return @"SP_PLASMA";
            break;
        case SP_WARNING:
            return @"SP_WARNING";
            break;
        case SP_MOTD:
            return @"SP_MOTD";
            break;
        case SP_YOU:
            return @"SP_YOU";
            break;
        case SP_QUEUE:
            return @"SP_QUEUE";
            break;
        case SP_STATUS:
            return @"SP_STATUS";
            break;
        case SP_PLANET:
            return @"SP_PLANET";
            break;
        case SP_PICKOK:
            return @"SP_PICKOK";
            break;
        case SP_LOGIN:
            return @"SP_LOGIN";
            break;
        case SP_FLAGS:
            return @"SP_FLAGS";
            break;
        case SP_MASK:
            return @"SP_MASK";
            break;
        case SP_PSTATUS:
            return @"SP_PSTATUS";
            break;
        case SP_BADVERSION:
            return @"SP_BADVERSION";
            break;
        case SP_HOSTILE:
            return @"SP_HOSTILE";
            break;
        case SP_STATS:
            return @"SP_STATS";
            break;
        case SP_PL_LOGIN:
            return @"SP_PL_LOGIN";
            break;
        case SP_RESERVED:
            return @"SP_RESERVED";
            break;
        case SP_PLANET_LOC:
            return @"SP_PLANET_LOC";
            break;
        case SP_SCAN:
            return @"SP_SCAN";
            break;
        case SP_UDP_REPLY:
            return @"SP_UDP_REPLY";
            break;
        case SP_SEQUENCE:
            return @"SP_SEQUENCE";
            break;
        case SP_SC_SEQUENCE:
            return @"SP_SC_SEQUENCE";
            break;
        case SP_RSA_KEY:
            return @"SP_RSA_KEY";
            break;
        case SP_MOTD_PIC:
            return @"SP_MOTD_PIC";
            break;
            //
        case SP_SHIP_CAP:
            return @"SP_SHIP_CAP";
            break;
        case SP_S_REPLY:
            return @"SP_S_REPLY";
            break;
        case SP_S_MESSAGE:
            return @"SP_S_MESSAGE";
            break;
        case SP_S_WARNING:
            return @"SP_S_WARNING";
            break;
        case SP_S_YOU:
            return @"SP_S_YOU";
            break;
        case SP_S_YOU_SS:
            return @"SP_S_YOU_SS";
            break;
        case SP_S_PLAYER:
            return @"SP_S_PLAYER";
            break;
        case SP_PING:
            return @"SP_PING";
            break;
        case SP_S_TORP:
            return @"SP_S_TORP";
            break;
        case SP_S_TORP_INFO:
            return @"SP_S_TORP_INFO";
            break;
        case SP_S_8_TORP:
            return @"SP_S_8_TORP";
            break;
        case SP_S_PLANET:
            return @"SP_S_PLANET";
            break;                               
        case SP_S_SEQUENCE:
            return @"SP_S_SEQUENCE";
            break;
        case SP_S_PHASER:
            return @"SP_S_PHASER";
            break;
        case SP_S_KILLS:
            return @"SP_S_KILLS";
            break;
        case SP_S_STATS:
            return @"SP_S_STATS";
            break;
        case SP_FEATURE:
            return @"SP_FEATURE";
            break;
        case SP_BITMAP:
            return @"SP_BITMAP";
            break;
        default:
            return @"UNKNOWN";
            break;
    }
}

- (NSString *) clientPacketString:(int)packet {
    switch (packet) {
        case CP_MESSAGE:
            return @"CP_MESSAGE";
            break;
        case CP_SPEED:
            return @"CP_SPEED";
            break;
        case CP_DIRECTION:
            return @"CP_DIRECTION";
            break;
        case CP_PHASER:
            return @"CP_PHASER";
            break;
        case CP_PLASMA:
            return @"CP_PLASMA";
            break;
        case CP_TORP:
            return @"CP_TORP";
            break;
        case CP_QUIT:
            return @"CP_QUIT";
            break;
        case CP_LOGIN:
            return @"CP_LOGIN";
            break;
        case CP_OUTFIT:
            return @"CP_OUTFIT";
            break;
        case CP_WAR:
            return @"CP_WAR";
            break;
        case CP_PRACTR:
            return @"CP_PRACTR";
            break;
        case CP_SHIELD:
            return @"CP_SHIELD";
            break;
        case CP_REPAIR:
            return @"CP_REPAIR";
            break;
        case CP_ORBIT:
            return @"CP_ORBIT";
            break;
        case CP_PLANLOCK:
            return @"CP_PLANLOCK";
            break;
        case CP_PLAYLOCK:
            return @"CP_PLAYLOCK";
            break;
        case CP_BOMB:
            return @"CP_BOMB";
            break;
        case CP_BEAM:
            return @"CP_BEAM";
            break;
        case CP_CLOAK:
            return @"CP_CLOAK";
            break;
        case CP_DET_TORPS:
            return @"CP_DET_TORPS";
            break;
        case CP_DET_MYTORP:
            return @"CP_DET_MYTORP";
            break;
        case CP_COPILOT:
            return @"CP_COPILOT";
            break;
        case CP_REFIT:
            return @"CP_REFIT";
            break;
        case CP_TRACTOR:
            return @"CP_TRACTOR";
            break;
        case CP_REPRESS:
            return @"CP_REPRESS";
            break;
        case CP_COUP:
            return @"CP_COUP";
            break;
        case CP_SOCKET:
            return @"CP_SOCKET";
            break;
        case CP_OPTIONS:
            return @"CP_OPTIONS";
            break;
        case CP_BYE:
            return @"CP_BYE";
            break;
        case CP_DOCKPERM:
            return @"CP_DOCKPERM";
            break;
        case CP_UPDATES:
            return @"CP_UPDATES";
            break;
        case CP_RESETSTATS:
            return @"CP_RESETSTATS";
            break;
        case CP_RESERVED:
            return @"CP_RESERVED";
            break;
        case CP_SCAN:
            return @"CP_SCAN";
            break;
        case CP_UDP_REQ:
            return @"CP_UDP_REQ";
            break;
        case CP_SEQUENCE:
            return @"CP_SEQUENCE";
            break;
        case CP_RSA_KEY:
            return @"CP_RSA_KEY";
            break;
        case CP_PING_RESPONSE:
            return @"CP_PING_RESPONSE";
            break;
        case CP_S_REQ:
            return @"CP_S_REQ";
            break;
        case CP_S_THRS:
            return @"CP_S_THRS";
            break;
        case CP_S_MESSAGE:
            return @"CP_S_MESSAGE";
            break;
        case CP_S_RESERVED:
            return @"CP_S_RESERVED";
            break;
        case CP_S_DUMMY:
            return @"CP_S_DUMMY";
            break;
        case CP_FEATURE:
            return @"CP_FEATURE";
            break;
        default:
            return @"UNKNOWN";
            break;
    }
}

- (NSString *) shortPacketString:(int)packet {
    switch (packet) {
        case SPK_VOFF:
            return @"SPK_VOFF";
            break;
        case SPK_VON:
            return @"SPK_VON";
            break;
        case SPK_MOFF:
            return @"SPK_MOFF";
            break;
        case SPK_MON:
            return @"SPK_MON";
            break;
        case SPK_M_KILLS:
            return @"SPK_M_KILLS";
            break;
        case SPK_M_NOKILLS:
            return @"SPK_M_NOKILLS";
            break;
        case SPK_THRESHOLD:
            return @"SPK_THRESHOLD";
            break;
        case SPK_M_WARN:
            return @"SPK_M_WARN";
            break;
        case SPK_M_NOWARN:
            return @"SPK_M_NOWARN";
            break;
        case SPK_SALL:
            return @"SPK_SALL";
            break;
        default:
            return @"UNKNOWN";
            break;
    }
}

- (void) printPacketInBuffer:(char *) buffer size:(int) size {
    
    // check if we need to do this
    if (!debugPackets) {
        return;
    }
    
    // print seperator
    NSMutableString *seperator  = [NSMutableString stringWithString:@"-------------"];
    for (int i = 0; i < LINE_WIDTH; i++) {
        [seperator appendString:@"---"];
    }
    LLLog(seperator);
    
    while (size > LINE_WIDTH) {
        // print a line
        NSMutableString *line  = [NSMutableString stringWithString:@"Packet Hex  : "];
        NSMutableString *ascii = [NSMutableString stringWithString:@"Packet Ascii: "];
        for (int i = 0; i < LINE_WIDTH; i++) {
            // add a character to the line
            [line appendString: [NSString stringWithFormat: @"%2.2x ", 0xFF & buffer[i]]];
            if ((buffer[i] != 0) && (buffer[i] != '\n') && (buffer[i] != '\r')) {
				if (buffer[i] != '%') {
					[ascii appendString:[NSString stringWithFormat: @" %1c ", buffer[i]]];
				} else {
					 [ascii appendString:                           @" %% "];
				}               
            } else {
                [ascii appendString:                                @"   "];
            }            
        }
        LLLog(line);
        LLLog(ascii);
        
        buffer += LINE_WIDTH;
        size -= LINE_WIDTH;
    }
    
    NSMutableString *line  = [NSMutableString stringWithString:@"Packet Hex  : "];
    NSMutableString *ascii = [NSMutableString stringWithString:@"Packet Ascii: "];
    // print partial last line
    for (int i = 0; i < size; i++) {
        // add a character to the line
        [line appendString: [NSString stringWithFormat: @"%2.2x ", 0xFF & buffer[i]]];
		if ((buffer[i] != 0) && (buffer[i] != '\n') && (buffer[i] != '\r')) {
			if (buffer[i] != '%') {
				[ascii appendString:[NSString stringWithFormat: @" %1c ", buffer[i]]];
			} else {
				[ascii appendString:                           @" %% "];
			}               
		} else {
			[ascii appendString:                                @"   "];
		}
    }
    LLLog(line);
    LLLog(ascii);
    LLLog(seperator);
}

@end
