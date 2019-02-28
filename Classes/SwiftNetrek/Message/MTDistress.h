//
//  MTDistress.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 01/03/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "Luky.h"
#import "Data.h"

#define DC_UNKNOWN			0
#define DC_TAKE				1
#define DC_OGG				2
#define DC_BOMB				3
#define DC_SPACE_CONTROL	4
#define DC_SAVE_PLANET		5
#define DC_BASE_OGG			6
#define DC_HELP3			7
#define DC_HELP4			8
// doing series
#define DC_ESCORTING		9
#define DC_OGGING			10
#define DC_BOMBING			11
#define DC_CONTROLLING		12
#define DC_ASW				13
#define DC_ASBOMB			14
#define DC_DOING3			15
#define DC_DONIG4			16
// other info series
// ie. player x is totally hosed now
#define DC_FREE_BEER		17	
// ie. player x has no gas
#define DC_NO_GAS			18	
// ie. player x is way hurt but may have gas
#define DC_CRIPPLED			19	
// player x picked up armies
#define DC_PICKUP			20	
// there was a pop somewhere
#define DC_POP				21	
// I am carrying
#define DC_CARRYING			22	
#define DC_OTHER1			23
#define DC_OTHER2			24
// just a generic distress call
#define DC_GENERIC			25	
#define DC_RCM				26

@interface MTDistress : BaseClass {
	Player *sender;
	int  damage;
	int  shields;
	int  armies;
	int  wtemp;
	int  etemp;
	int  fuel_percentage;
	int  short_status;
	bool wtemp_flag;
	bool etemp_flag;
	bool cloak_flag;
	int  distress_type;
	bool macro_flag;
	
	Planet *close_planet;
	Planet *target_planet;
	
	Player *close_player;
	Player *close_friend;
	Player *close_enemy;
	
	Player *target_player;
	Player *target_friend;
	Player *target_enemy;	
	char   *cclist;							    // allow us some day to cc a message up to 5 people
												// sending this to the server allows the server to 
												// do the cc action otherwise it would have to be 
												// the client ... less BW this way
	bool prepend;
	NSString *prepend_append;					// text which we pre or append	
	int  destinationGroup;
	int  destinationIndiv;
}

- (id) initWithSender:(Player*)player buffer:(char *)buffer;
- (id) initWithType:(int)type gamePointForMousePosition:(NSPoint)mouse;
- (id) initWithSender:(Player*) sndr targetPlayer:(Player*) trgtPlyr armies:(int) arms 
			   damage:(int) dmg shields:(int) shlds targetPlanet:(Planet*)trgtPlnt
		   weaponTemp:(int) wtmp;
- (void) setDestinationGroup:(int)grp individual:(int)indiv;
- (int) destinationIndiv;
- (int) destinationGroup;
- (NSString *)defaultMacro;
- (NSString *)defaultMacroForType:(int)type;
- (NSString *)filledMacroString;
- (NSString*) parsedMacroString;
- (NSString*) rcdString;

- (void) parseTests:(NSMutableString *)buffer;
- (void) parseConditionals:(NSMutableString *)buffer;
- (int) evaluateConditionalBlockStartingAt:(int) bpos inBuffer:(NSMutableString *)buffer include: (bool) include;
- (void) parseRemaining:(NSMutableString *)buffer;


@end
