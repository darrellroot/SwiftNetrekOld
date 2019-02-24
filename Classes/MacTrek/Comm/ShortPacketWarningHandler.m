//
//  ShortPacketWarningHandler.m
//  MacTrek
//
//  Created by Aqua on 26/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "ShortPacketWarningHandler.h"
#import "LLNotificationCenter.h"
#import "MessageConstants.h"
#import "RCMmessage.h"


@implementation ShortPacketWarningHandler

// re-entrant vars
// don't like them too much but hey
int arg3;
int arg4;
int karg3;
int karg4;
int karg5;

- (id) init {
    self = [super init];
    if (self != nil) {
        deamonMessages = [NSArray arrayWithObjects:
                @"Game is paused.  CONTINUE to continue.",
                @"Game is no-longer paused!",
                @"Game is paused. Captains CONTINUE to continue.",
                @"Game will continue in 10 seconds",
                @"Teams chosen.  Game will start in 1 minute.",
                @"----------- Game will start in 1 minute -------------",
                nil];
        [deamonMessages retain];
        warningMessages = [NSArray arrayWithObjects:
            @"Tractor beams haven't been invented yet.",
            @"Weapons's Officer:  Cannot tractor while cloaked, sir!",
            @"Weapon's Officer:  Vessel is out of range of our tractor beam.",
            @"You must have one kill to throw a coup",
            @"You must orbit your home planet to throw a coup",
            @"You already own a planet!!!",
            @"You must orbit your home planet to throw a coup",
            @"Too many armies on planet to throw a coup",
            @"Planet not yet ready for a coup",
            @"I cannot allow that.  Pick another team",
            @"Please confirm change of teams.  Select the new team again.",
            @"That is an illegal ship type.  Try again.",
            @"That ship hasn't been designed yet.  Try again.",
            @"Your new starbase is still under construction",
            @"Your team is not capable of defending such an expensive ship!",
            @"Your team's stuggling economy cannot support such an expenditure!",
            @"Your side already has a starbase!",
            @"Plasmas haven't been invented yet.",
            @"Weapon's Officer:  Captain, this ship is not armed with plasma torpedoes!",
            @"Plasma torpedo launch tube has exceeded the maximum safe temperature!",
            @"Our fire control system limits us to 1 live torpedo at a time captain!",
            @"Our fire control system limits us to 1 live torpedo at a time captain!",
            @"We don't have enough fuel to fire a plasma torpedo!",
            @"We cannot fire while our vessel is undergoing repairs.",
            @"We are unable to fire while in cloak, captain!",
            @"Torpedo launch tubes have exceeded maximum safe temperature!",
            @"Our computers limit us to having 8 live torpedos at a time captain!",
            @"We don't have enough fuel to fire photon torpedos!",
            @"We cannot fire while our vessel is in repair mode.",
            @"We are unable to fire while in cloak, captain!",
            @"We only have forward mounted cannons.",
            @"Weapons Officer:  This ship is not armed with phasers, captain!",
            @"Phasers have not recharged",         // 32
            @"Not enough fuel for phaser",         // 33
            @"Can't fire while repairing",         // 34
            @"Weapons overheated",                 // 35
            @"Cannot fire while cloaked",          // 36
            @"Phaser missed!!!",                   // 37
            @"You destroyed the plasma torpedo!",  // 38
            @"Must be orbiting to bomb",           // 39
            @"Can't bomb your own armies.  Have you been reading Catch-22 again?",
            @"Must declare war first (no Pearl Harbor syndrome allowed here).",
            @"Bomb out of T-mode?  Please verify your order to bomb.",
            @"Hoser!",                             // 43
            @"Must be orbiting or docked to beam up.",
            @"Those aren't our men.",              // 45
            @"Comm Officer: We're not authorized to beam foriegn troops on board!",
            @"Must be orbiting or docked to beam down.",
            @"Comm Officer: Starbase refuses permission to beam our troops over.",
            @"Pausing ten seconds to re-program battle computers.",
            @"You must orbit your HOME planet to apply for command reassignment!",
            @"You must orbit your home planet to apply for command reassignment!",
            @"Can only refit to starbase on your home planet.",
            @"You must dock YOUR starbase to apply for command reassignment!",
            @"Must orbit home planet or dock your starbase to apply for command reassignment!",
            @"Central Command refuses to accept a ship in this condition!",
            @"You must beam your armies down before moving to your new ship",
            @"That ship hasn't been designed yet.",
            @"Your side already has a starbase!",  // 58
            @"Your team is not capable of defending such an expensive ship",
            @"Your new starbase is still under construction",
            @"Your team's stuggling economy cannot support such an expenditure!",
            @"You are being transported to your new vessel .... @",
            @"Engineering:  Energize. ",
            @"Wait, you forgot your toothbrush!",  // 64
            @"Nothing like turning in a used ship for a new one.",
            @"First officer:  Oh no, not you again... we're doomed!",
            @"First officer:  Uh, I'd better run diagnostics on the escape pods.",
            @"Shipyard controller:  This time, *please* be more careful, okay?",
            @"Weapons officer:  Not again!  This is absurd...",
            @"Weapons officer:  ... the whole ship's computer is down?",
            @"Weapons officer:  Just to twiddle a few bits of the ship's memory?",
            @"Weapons officer:  Bah! [ bangs fist on inoperative console ]",
            @"First Officer:  Easy, big guy... it's just one of those mysterious",
            @"First Officer:  laws of the universe, like 'MacTrek rules'.",
            @"First Officer:  laws of the universe, like 'Klingon bitmaps are ugly'.",
            @"First Officer:  laws of the universe, like 'all admirals have scummed'.",
            @"First Officer:  laws of the universe, like 'Mucus Pig exists'.",
            @"First Officer:  laws of the universe, like 'guests advance 5x faster'.",
            @"Helmsman: Captain, the maximum safe speed for docking or orbiting is warp 2!",
            @"Central Command regulations prohibits you from orbiting foreign planets",
            @"Helmsman:  Sensors read no valid targets in range to dock or orbit sir!",
            @"No more room on board for armies",   // 82
            @"You notice everyone on the bridge is staring at you.",
            @"Can't send in practice robot with other players in the game.",
            @"Self Destruct has been canceled",    // 85
            @"Be quiet",                           // 86
            @"You are censured.  Message was not sent.",
            @"You are ignoring that player.  Message was not sent.",
            @"That player is censured.  Message was not sent.",
            @"Self destruct initiated",            // 90
            @"Scanners haven't been invented yet", // 91
            @"WARNING: BROKEN mode is enabled",    // 92
            @"Server can't do that UDP mode",      // 93
            @"Server will send with TCP only",     // 94
            @"Server will send with simple UDP",   // 95
            @"Request for fat UDP DENIED (set to simple)",
            @"Request for double UDP DENIED (set to simple)",
            @"Update request DENIED (chill out!)", // 98
            @"Player lock lost while player dead.",
            @"Can only lock on own team.",         // 100
            @"You can only warp to your own team's planets!",
            @"Planet lock lost on change of ownership.",
            @" Weapons officer: Finally! systems are back online!",
            nil ];
        [warningMessages retain];
        serverSentStrings = [[NSMutableArray alloc] init];
		macroHandler = [[MTMacroHandler alloc] init];
    }
    return self;
}

- (id) initWithUniverse:(Universe*)myUniverse {
    self = [self init];
    if (self != nil) {
        universe = myUniverse;
    }
    return self;
}

- (NSString *) handleSWarning: (char*)buffer {
    int which_message = buffer[1] & 0xFF;
    int arg1 = buffer[2] & 0xFF;
    int arg2 = buffer[3] & 0xFF;
    int temp = 0;
    
    RCMmessage *rcm;
    NSString *message;
    Player *player;
    Planet *planet;
    
    switch (which_message) {
        case SPW_TEXTE:
            temp = (arg1 | arg2 << 8);
            if (temp >= 0 && temp < [warningMessages count]) {
                message = [warningMessages objectAtIndex:temp];
                [notificationCenter postNotificationName:@"SPW_TEXTE" object:self userInfo:message];
                
                // check for warnings that have an audio alarm
                if (temp == 90) { // self destruct
                    [notificationCenter postNotificationName:@"SPW_SELF_DESTRUCT_INITIATED"];
                }
                
            }
            break; 
		case SPW_PHASER_HIT_TEXT :
			player = [universe playerWithId: (arg1 & 0x3F)];
            
			if((arg1 & 0x40) != 0) {
				arg2 |= 0x100;
			}
            if((arg1 & 0x80) != 0) {
                arg2 |= 0x200;
            }
                
            message = [NSString stringWithFormat: @"Phaser burst hit %@ for %d points.", [player longName], arg2]; 
            [notificationCenter postNotificationName:@"SPW_PHASER_HIT_TEXT" object:self userInfo:message];
			//view.dmessage.newMessage(message, (INDIV | VALID | PHASER), 255, 0);
            // $$ view should subscribe to this one
			break;
		case SPW_BOMB_INEFFECTIVE :
			message = [NSString stringWithFormat: @"Weapons Officer: Bombing is ineffective for %d armies.", arg1];
			[notificationCenter postNotificationName:@"SPW_BOMB_INEFFECTIVE" object:self userInfo:message];
			break;
		case SPW_BOMB_TEXT :
			planet = [universe planetWithId: arg1];
			message = [NSString stringWithFormat: @"Bombing %d.  Sensors read %d armies left.", [planet name], arg2];
			[notificationCenter postNotificationName:@"SPW_BOMB_TEXT" object:self userInfo:message];
			break;
		case SPW_BEAMUP_TEXT :
			planet = [universe planetWithId: arg1];
			message = [NSString stringWithFormat: @"%@: Too few armies to beam up.", [planet name]];
			[notificationCenter postNotificationName:@"SPW_BEAMUP_TEXT" object:self userInfo:message];
			break;
		case SPW_BEAMUP2_TEXT :
			message = [NSString stringWithFormat: @"Beaming up.  (%d/%d)",  arg1, arg2];
			[notificationCenter postNotificationName:@"SPW_BEAMUP2_TEXT" object:self userInfo:message];
			break;
		case SPW_BEAMUPSTARBASE_TEXT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Starbase %d: Too few armies to beam up.", [player longName]];
			[notificationCenter postNotificationName:@"SPW_BEAMUPSTARBASE_TEXT" object:self userInfo:message];
			break;
		case SPW_BEAMDOWNSTARBASE_TEXT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"No more armies to beam down to Starbase %@", [player longName]];
			[notificationCenter postNotificationName:@"SPW_BEAMDOWNSTARBASE_TEXT" object:self userInfo:message];
			break;
		case SPW_BEAMDOWNPLANET_TEXT :
			planet = [universe planetWithId: arg1];
			message = [NSString stringWithFormat: @"No more armies to beam down to %@.", [planet name]];
			[notificationCenter postNotificationName:@"SPW_BEAMDOWNPLANET_TEXT" object:self userInfo:message];
			break;
		case SPW_SBREPORT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Transporter Room:  Starbase %@ reports all troop bunkers are full!", [player longName]];
			[notificationCenter postNotificationName:@"SPW_SBREPORT" object:self userInfo:message];
			break;
		case SPW_ONEARG_TEXT :
			switch(arg1) {
			case 0 :
				message = [NSString stringWithFormat: @"Engineering:  Energizing transporters in %d seconds", arg2];
				break;
			case 1 :
				message = [NSString stringWithFormat: @"Stand By ... Self Destruct in %d seconds", arg2];
				break;
			case 2 :
				message = [NSString stringWithFormat: @"Helmsman:  Docking manuever completed Captain.  All moorings secured at port %d", arg2];
				break;
			case 3 :
				message = [NSString stringWithFormat: @"Not constructed yet. %d  minutes required for completion", arg2];
				break;
			default :
				message = nil;
			}
			[notificationCenter postNotificationName:@"SPW_ONEARG_TEXT" object:self userInfo:message];
			break;
		case SPW_ARGUMENTS :
			arg3 = arg1;
			arg4 = arg2;
			break;
		case SPW_BEAM_D_PLANET_TEXT :
			planet = [universe planetWithId: arg1];
			message = [NSString stringWithFormat: @"Beaming down.  (%d/%d) %@ has %d armies left.", arg3, arg4, [planet name], arg2];
			[notificationCenter postNotificationName:@"SPW_BEAM_D_PLANET_TEXT" object:self userInfo:message];
			break;
		case SPW_BEAM_U_TEXT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Transfering ground units.  (%d/%d) Starbase %@ has %d armies left.", arg3, arg4, [player longName], arg2];
			[notificationCenter postNotificationName:@"SPW_BEAM_U_TEXT" object:self userInfo:message];
			break;
		case SPW_LOCKPLANET_TEXT :
			planet = [universe planetWithId: arg1];
			message = [NSString stringWithFormat: @"Locking onto ", [planet name]];
			[notificationCenter postNotificationName:@"SPW_LOCKPLANET_TEXT" object:self userInfo:message];
			break;
		case SPW_LOCKPLAYER_TEXT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Locking onto ", [player longName]];
			[notificationCenter postNotificationName:@"SPW_LOCKPLAYER_TEXT" object:self userInfo:message];
			break;
		case SPW_SBRANK_TEXT :
			message = [NSString stringWithFormat: @"You need a rank of %@  or higher to command a starbase!", [[universe rankWithId: arg1] name] ];
			[notificationCenter postNotificationName:@"SPW_SBRANK_TEXT" object:self userInfo:message];
			break;
		case SPW_SBDOCKREFUSE_TEXT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Starbase %@  refusing us docking permission captain.", [player longName]];
			[notificationCenter postNotificationName:@"SPW_SBDOCKREFUSE_TEXT" object:self userInfo:message];
			break;
		case SPW_SBDOCKDENIED_TEXT :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Starbase %@  Permission to dock denied, all ports currently occupied.", [player longName]];				
			[notificationCenter postNotificationName:@"SPW_SBDOCKDENIED_TEXT" object:self userInfo:message];
			break;
		case SPW_SBLOCKSTRANGER :
			player = [universe playerWithId: arg1];
			message = [NSString stringWithFormat: @"Locking onto ", [player longName]];
			[notificationCenter postNotificationName:@"SPW_SBLOCKSTRANGER" object:self userInfo:message];
			break;
		case SPW_SBLOCKMYTEAM :
			player = [universe playerWithId: arg1];
            if ([player flags] & PLAYER_DOCK) {
                message = [NSString stringWithFormat: @"Locking onto %@ (docking is enabled)", [player longName]];
            } else {
                message = [NSString stringWithFormat: @"Locking onto %@ (docking is disabled)", [player longName]];
            }
			[notificationCenter postNotificationName:@"SPW_SBLOCKMYTEAM" object:self userInfo:message];
			break;
		case SPW_DMKILL:
		case SPW_INLDMKILL:
        { // require block since we declare stack vars
        	int damage = (karg3 | (karg4 & 127) << 8);
			int armies = ((arg1 >> 6) | (arg2 & 192) >> 4);
			if((karg4 & 128) != 0) {
				armies |= 16;
			}

            rcm = [[RCMmessage alloc] init];
            [rcm setFlags: ALL | VALID | KILL];
            [rcm setTo: 0];
            [rcm setType:1];
            [rcm setSender: [universe playerWithId:arg1 & 0x3F]];
            [rcm setTargetPlayer: [universe playerWithId:arg2 & 0x3F]];
            [rcm setArmies:armies];
            [rcm setShields: damage % 100];
            [rcm setDamage: damage /100];
            [rcm setTargetPlanet: nil];
            [rcm setWeaponTemp:karg5];
            [notificationCenter postNotificationName:@"SPW_RCM_DMKILL" object:self userInfo:rcm];
            message = nil;
        }
			break;
		case SPW_KILLARGS :
			karg3 = arg1;
			karg4 = arg2;
			break;
		case SPW_KILLARGS2 :
			karg5 = arg1;
            // 7 is the max number of hardcoded reasons to die in RCMhandler
            // $$ create a RCM handler
			if(karg5 < 0 || karg5 >= 7) {
				karg5 = 6; // take the last one
			}
			break;
		case SPW_DMKILLP : 
		case SPW_INLDMKILLP :
			player = [universe playerWithId: arg1];
			planet = [universe planetWithId: arg2];
            
            rcm = [[RCMmessage alloc] init];
            [rcm setFlags: ALL | VALID | KILL];
            [rcm setTo: 0];
            [rcm setType:2];
            [rcm setSender: player];
            [rcm setTargetPlayer: player];
            [rcm setArmies:0];
            [rcm setDamage: 0];
            [rcm setShields: 0];
            [rcm setTargetPlanet:planet];
            [rcm setWeaponTemp:karg5];
            [notificationCenter postNotificationName:@"SPW_RCM_DMKILLP" object:self userInfo:rcm];
            message = nil;
			break;
		case SPW_DMBOMB : 
			player = [universe playerWithId: arg1];
			planet = [universe planetWithId: arg2];
                        
            rcm = [[RCMmessage alloc] init];
            [rcm setFlags: TEAM | VALID | BOMB];
            [rcm setTo: [[planet owner] bitMask]];
            [rcm setType:3];
            [rcm setSender: player];
            [rcm setTargetPlayer: player];
            [rcm setArmies:0];
            [rcm setDamage: arg3];            
            [rcm setShields: 0];
            [rcm setTargetPlanet:planet];
            [rcm setWeaponTemp:karg5];
            [notificationCenter postNotificationName:@"SPW_RCM_DMBOMB" object:self userInfo:rcm];
            message = nil;
			break;
		case SPW_DMDEST :
			planet = [universe planetWithId: arg1];
			player = [universe playerWithId: arg2];
            
            rcm = [[RCMmessage alloc] init];
            [rcm setFlags: TEAM | VALID | DEST];
            [rcm setTo: [[planet owner] bitMask]];
            [rcm setType:4];
            [rcm setSender: player];
            [rcm setTargetPlayer: player];
            [rcm setArmies:0];
            [rcm setDamage: 0];            
            [rcm setShields: 0];
            [rcm setTargetPlanet:planet];
            [rcm setWeaponTemp:karg5];
            [notificationCenter postNotificationName:@"SPW_RCM_DMDEST" object:self userInfo:rcm];
            message = nil;
			break;
		case SPW_DMTAKE :
			planet = [universe planetWithId: arg1];
			player = [universe playerWithId: arg2];	
            
            rcm = [[RCMmessage alloc] init];
            [rcm setFlags: TEAM | VALID | TAKE];
            [rcm setTo: [[planet owner] bitMask]];
            [rcm setType:5];
            [rcm setSender: player];
            [rcm setTargetPlayer: player];
            [rcm setArmies:0];
            [rcm setDamage: 0];            
            [rcm setShields: 0];
            [rcm setTargetPlanet:planet];
            [rcm setWeaponTemp:karg5];
            [notificationCenter postNotificationName:@"SPW_RCM_DMTAKE" object:self userInfo:rcm];
            message = nil;
			break;
		case SPW_DGHOSTKILL :
        {
			int damage = karg3 | ((karg4 & 0xFF) << 8);
			player = [universe playerWithId: arg1];
            
            rcm = [[RCMmessage alloc] init];
            [rcm setFlags: TEAM | VALID];
            [rcm setTo: [[planet owner] bitMask]];
            [rcm setType:6];
            [rcm setSender: player];
            [rcm setTargetPlayer: player];
            [rcm setArmies:0];
            [rcm setDamage: damage / 100];            
            [rcm setShields: damage % 100];
            [rcm setTargetPlanet: nil];
            [rcm setWeaponTemp:karg5];
            [notificationCenter postNotificationName:@"SPW_RCM_DMGHOSTKILL" object:self userInfo:rcm];
            message = nil;
			break;
        }
		case SPW_INLDRESUME :
			message = [NSString stringWithFormat: @" Game will resume in %d seconds",arg1];
            // $$ this is not an ordnairy message
			//view.dmessage.newMessage(message,	(ALL | VALID),255, 0);
            [notificationCenter postNotificationName:@"SPW_INLDRESUME" object:self userInfo:message];
			break;
		case SPW_INLDTEXTE :
			if(arg1 < [deamonMessages count]) {
				message = [deamonMessages objectAtIndex: arg1];
                // $$ this is not an ordnairy message
				//view.dmessage.newMessage(message,	(ALL | VALID),	255, 0);
                [notificationCenter postNotificationName:@"SPW_INLDTEXTE" object:self userInfo:message];
			}
			break;
		case SPW_STEXTE :
            // recall string
			if([serverSentStrings objectAtIndex: arg1] != nil) {
				message = [serverSentStrings objectAtIndex: arg1];
                [notificationCenter postNotificationName:@"SPW_STEXTE" object:self userInfo:message];
			}			
			break;
		case SPW_SHORT_WARNING :
			message = [[[NSString alloc] initWithBytes:(buffer + 4) length:(arg2 -5) encoding:NSASCIIStringEncoding] autorelease]; 
			[notificationCenter postNotificationName:@"SPW_SHORT_WARNING" object:self userInfo:message];
			break;
		case SPW_STEXTE_STRING :
			message = [[[NSString alloc] initWithBytes:(buffer + 4) length:(arg2 -5) encoding:NSASCIIStringEncoding] autorelease]; 

            // store it for recall
            [serverSentStrings insertObject: message atIndex:(buffer[2] & 0xFF)];			
			[notificationCenter postNotificationName:@"SPW_STEXTE_STRING" object:self userInfo:message];
			break; 
		default :
			message = @"Unknown short message!";
			[notificationCenter postNotificationName:@"SPW_UNKNOWN" object:self userInfo:message];
			break;
		}	
	
        // Generic post of message
		if ((message == nil) && (rcm != nil)) { // message is an RCM
			message = [macroHandler parseMacro:rcm];
		}        
		[notificationCenter postNotificationName:@"SPW_MESSAGE" object:self userInfo:message];	
	
        return message;
}

@end
