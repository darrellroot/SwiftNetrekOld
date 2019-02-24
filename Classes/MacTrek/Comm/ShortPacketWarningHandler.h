//
//  ShortPacketWarningHandler.h
//  MacTrek
//
//  Created by Aqua on 26/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Universe.h"
#import "LLNotificationCenter.h"
#import "BaseClass.h"
#import "MTMacroHandler.h"

#define SPW_TEXTE					 0
#define SPW_PHASER_HIT_TEXT		 1
#define SPW_BOMB_INEFFECTIVE		 2
#define SPW_BOMB_TEXT				 3
#define SPW_BEAMUP_TEXT			 4
#define SPW_BEAMUP2_TEXT			 5
#define SPW_BEAMUPSTARBASE_TEXT	 6
#define SPW_BEAMDOWNSTARBASE_TEXT	 7
#define SPW_BEAMDOWNPLANET_TEXT	 8
#define SPW_SBREPORT				 9
#define SPW_ONEARG_TEXT			 10
#define SPW_BEAM_D_PLANET_TEXT	 11
#define SPW_ARGUMENTS				 12
#define SPW_BEAM_U_TEXT			 13
#define SPW_LOCKPLANET_TEXT		 14
#define SPW_LOCKPLAYER_TEXT		 15
#define SPW_SBRANK_TEXT			 16
#define SPW_SBDOCKREFUSE_TEXT		 17
#define SPW_SBDOCKDENIED_TEXT		 18
#define SPW_SBLOCKSTRANGER		 19
#define SPW_SBLOCKMYTEAM			 20
// Daemon messages
#define SPW_DMKILL				 21
#define SPW_KILLARGS				 22
#define SPW_DMKILLP				 23
#define SPW_DMBOMB				 24
#define SPW_DMDEST				 25
#define SPW_DMTAKE				 26
#define SPW_DGHOSTKILL			 27
// INL	messages
#define SPW_INLDMKILLP			 28
// Because of shiptypes
#define SPW_INLDMKILL				 29	
#define SPW_INLDRESUME			 30
#define SPW_INLDTEXTE				 31
// Variable warning stuff
// static text that the server needs to send to the client first
#define SPW_STEXTE				 32	
// like CP_S_MESSAGE
#define SPW_SHORT_WARNING			 33	
#define SPW_STEXTE_STRING			 34
#define SPW_KILLARGS2				 35
#define SPW_DINVALID				 255

@interface ShortPacketWarningHandler : BaseClass {
    
    NSArray  *deamonMessages;
    NSArray  *warningMessages;
    NSMutableArray *serverSentStrings;
	MTMacroHandler *macroHandler;
}

- (NSString*) handleSWarning: (char*)buffer;

@end
