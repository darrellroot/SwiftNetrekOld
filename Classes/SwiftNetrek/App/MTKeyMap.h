//
//  MTKeyMap.h
//  MacTrek
//
//  Created by Aqua on 21/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "MTKeyMapEntry.h"

// the action invoked by the keypress
#define ACTION_UNKNOWN           0
#define ACTION_CLOAK             1
#define ACTION_DET_ENEMY         2
#define ACTION_DET_OWN           3
#define ACTION_FIRE_PLASMA       4
#define ACTION_FIRE_TORPEDO      5
#define ACTION_FIRE_PHASER       6
#define ACTION_SHIELDS           7
#define ACTION_TRACTOR           8
#define ACTION_PRESSOR           9
#define ACTION_WARP_0           10
#define ACTION_WARP_1           11
#define ACTION_WARP_2           12
#define ACTION_WARP_3           13
#define ACTION_WARP_4           14
#define ACTION_WARP_5           15
#define ACTION_WARP_6           16
#define ACTION_WARP_7           17
#define ACTION_WARP_8           18
#define ACTION_WARP_9           19
#define ACTION_WARP_10          20
#define ACTION_WARP_11          21
#define ACTION_WARP_12          22
#define ACTION_WARP_MAX         23
#define ACTION_WARP_HALF_MAX    24
#define ACTION_WARP_INCREASE    25
#define ACTION_WARP_DECREASE    26
#define ACTION_SET_COURSE       27
#define ACTION_LOCK             28
#define ACTION_PRACTICE_BOT     29
#define ACTION_TRANSWARP        30
#define ACTION_BOMB             31
#define ACTION_ORBIT            32
#define ACTION_BEAM_DOWN        33
#define ACTION_BEAM_UP          34
#define ACTION_DISTRESS_CALL    35
#define ACTION_ARMIES_CARRIED_REPORT 36
#define ACTION_MESSAGE          37
#define ACTION_DOCK_PERMISSION  38
#define ACTION_INFO             39
#define ACTION_REFIT            40
#define ACTION_REPAIR           41
#define ACTION_QUIT             42
#define ACTION_HELP             43
#define ACTION_DEBUG            44

#define ACTION_SCREENSHOT       45
#define ACTION_WAR				46
#define ACTION_COUP				47
#define ACTION_ZOOM				48

// unsupported actions for future implementation
// which are possible in COW
#define ACTION_MACRO            50
#define ACTION_MOTD				51
#define ACTION_OPTIONS			52
#define ACTION_LOCAL_VIEW_TYPE	53
#define ACTION_MAP_VIEW_TYPE	54
#define ACTION_MESSAGE_WINDOWS	55
#define ACTION_PLAYER_LIST		57
#define ACTION_PLANET_LIST		58
#define ACTION_STAT_MODE		59
#define ACTION_NAME_MODE		60
#define ACTION_SHORT_CONTROL	62
#define ACTION_UDP_FULL_UPDATE	63
#define ACTION_SHORT_PACKET_ON	64
#define ACTION_NET_STATISTICS	65
#define ACTION_ALTERNATE_PLAYER_LIST	66
#define ACTION_SORT_PLAYER_LIST 67
#define ACTION_PING_STATS		68
#define ACTION_SOUND_CONTROL	69

@interface MTKeyMap : BaseClass {
    NSMutableDictionary *keyMap;
    bool changedSinceLastWrite;
    NSString *pathToKeyMap;
}

- (id) initWithDefaultFile;
- (id) initWithFile:(NSString *) file;
- (void) writeToFile:(NSString *)file;
- (void) readDefaultKeyMap;
- (int) actionForKey:(char) key withModifierFlags:(unsigned int) flags;
- (NSString *) descriptionForAction:(int) action;
- (char) keyForAction:(int) action;
- (unsigned int) flagsForAction:(int) action;
- (void) setKey: (char) key forAction:(int) action;
- (void) setFlags: (unsigned int) flags ForAction:(int) action;
- (int) count;
- (NSArray *)allKeys;
- (void)writeToDefaultFileIfChanged;

@end
