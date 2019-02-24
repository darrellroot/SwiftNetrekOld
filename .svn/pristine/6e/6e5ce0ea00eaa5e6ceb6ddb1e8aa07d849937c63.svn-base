//
//  PacketTypes.h
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>

#define SP_MESSAGE			  1 	
#define SP_PLAYER_INFO		  2 	// general player info not elsewhere 
#define SP_KILLS				  3 	// # kills a player has 
#define SP_PLAYER				  4 	// x,y for player 
#define SP_TORP_INFO			  5 	// torp status 
#define SP_TORP				  6 	// torp location 
#define SP_PHASER				  7 	// phaser status and direction 
#define SP_PLASMA_INFO		  8 	// player login information 
#define SP_PLASMA				  9 	// like SP_TORP 
#define SP_WARNING			  10 	// like SP_MESG 
#define SP_MOTD				  11 	// line from .motd screen 
#define SP_YOU				  12 	// info on you? 
#define SP_QUEUE				  13 	// estimated loc in queue? 
#define SP_STATUS				  14 	// galaxy status numbers 
#define SP_PLANET				  15 	// planet armies & facilities 
#define SP_PICKOK				  16 	// your team & ship was accepted 
#define SP_LOGIN				  17 	// login response 
#define SP_FLAGS				  18 	// give flags for a player 
#define SP_MASK				  19 	// tournament mode mask 
#define SP_PSTATUS			  20 	// give status for a player 
#define SP_BADVERSION			  21 	// invalid version number 
#define SP_HOSTILE			  22 	// hostility settings for a player 
#define SP_STATS				  23 	// a player's statistics 
#define SP_PL_LOGIN			  24 	// new player logs in 
#define SP_RESERVED			  25 	// query for RSA version
#define SP_PLANET_LOC			  26 	// planet name, x, y 
#define SP_SCAN				  27 	// ATM: results of player scan 
#define SP_UDP_REPLY			  28 	// notify client of UDP status 
#define SP_SEQUENCE			  29 	// sequence # packet 
#define SP_SC_SEQUENCE		  30 	// this trans is semi-critical info 
#define SP_RSA_KEY			  31 	// handles binary verification 
#define SP_MOTD_PIC			  32 	// motd bitmap pictures (paradise) 
                                    // 33 - 38 are apparently not used
#define SP_SHIP_CAP			  39 	// Handles server ship mods 
#define SP_S_REPLY			  40 	// reply to send-short request 
#define SP_S_MESSAGE			  41 	// var. Message Packet 
#define SP_S_WARNING			  42 	// Warnings with 4  Bytes 
#define SP_S_YOU				  43 	// hostile,armies,whydead,etc .. 
#define SP_S_YOU_SS			  44 	// your ship status 
#define SP_S_PLAYER			  45 	// variable length player packet 
#define SP_PING				  46 	// ping packet 
#define SP_S_TORP				  47 	// variable length torp packet 
#define SP_S_TORP_INFO		  48 	// SP_S_TORP with TorpInfo 
#define SP_S_8_TORP			  49 	// optimized SP_S_TORP 
#define SP_S_PLANET			  50 	// see SP_PLANET 
                                    // 51 - 55 are apparently no used
#define SP_S_SEQUENCE			  56 	// SP_SEQUENCE for compressed packets 
#define SP_S_PHASER			  57 	// see struct 
#define SP_S_KILLS			  58 	// # of kills player have 
#define SP_S_STATS			  59 	// see SP_STATS 
#define SP_FEATURE			  60 
#define SP_BITMAP				  61 

// packets sent from remote client to xtrek server
#define CP_MESSAGE			  1 	// send a message 
#define CP_SPEED				  2 	// set speed 
#define CP_DIRECTION			  3 	// change direction 
#define CP_PHASER				  4 	// phaser in a direction 
#define CP_PLASMA				  5 	// plasma (in a direction) 
#define CP_TORP				  6 	// fire torp in a direction 
#define CP_QUIT				  7 	// self destruct 
#define CP_LOGIN				  8 	// log in (name, password) 
#define CP_OUTFIT				  9 	// outfit to new ship 
#define CP_WAR 				  10 	// change war status 
#define CP_PRACTR				  11 	// create practice robot? 
#define CP_SHIELD				  12 	// raise/lower sheilds 
#define CP_REPAIR				  13 	// enter repair mode 
#define CP_ORBIT				  14 	// orbit planet/starbase 
#define CP_PLANLOCK			  15 	// lock on planet 
#define CP_PLAYLOCK			  16 	// lock on player 
#define CP_BOMB				  17 	// bomb a planet 
#define CP_BEAM				  18 	// beam armies up/down 
#define CP_CLOAK				  19 	// cloak on/off 
#define CP_DET_TORPS			  20 	// detonate enemy torps 
#define CP_DET_MYTORP			  21 	// detonate one of my torps 
#define CP_COPILOT 			  22 	// toggle copilot mode 
#define CP_REFIT				  23 	// refit to different ship type 
#define CP_TRACTOR 			  24 	// tractor on/off 
#define CP_REPRESS 			  25 	// pressor on/off 
#define CP_COUP				  26 	// coup home planet 
#define CP_SOCKET				  27 	// new socket for reconnection 
#define CP_OPTIONS 			  28 	// send my options to be saved 
#define CP_BYE 				  29 	// I'm done! 
#define CP_DOCKPERM			  30 	// set docking permissions 
#define CP_UPDATES 			  31 	// set number of usecs per update 
#define CP_RESETSTATS			  32 	// reset my stats packet 
#define CP_RESERVED			  33 	// for future use 
#define CP_SCAN				  34 	// ATM 
#define CP_UDP_REQ 			  35 	// request UDP on/off 
#define CP_SEQUENCE			  36 	// sequence # packet 
#define CP_RSA_KEY 			  37 	// handles binary verification 
#define CP_PING_RESPONSE		  42 	// client response 
#define CP_S_REQ				  43 
#define CP_S_THRS				  44 
#define CP_S_MESSAGE			  45 	// vari. Message Packet 
#define CP_S_RESERVED			  46 
#define CP_S_DUMMY 			  47 
#define CP_FEATURE 			  60 

#define VPLAYER_SIZE			  4 
#define SHORTVERSION			  11 	// other number blocks, like UDP Version 
#define OLDSHORTVERSION		  10 	// S_P2 
#define SOCKVERSION			  4 
#define UDPVERSION 			  10 

// short packets
#define SPK_VOFF				  0 	// variable packets off
#define SPK_VON				  1 	// variable packets on
#define SPK_MOFF				  2 	// message packets off
#define SPK_MON				  3 	// message packets on
#define SPK_M_KILLS			  4 	// send kill mesgs
#define SPK_M_NOKILLS			  5 	// don't send kill mesgs
#define SPK_THRESHOLD			  6 	// threshold
#define SPK_M_WARN 			  7 	// warnings
#define SPK_M_NOWARN			  8 	// no warnings
#define SPK_SALL				  9 	// only planets,kills and weapons
#define SPK_ALL				  10 	// Full Update - SP_STATS
#define SPK_NUMFIELDS			  6 

#define SPK_VFIELD 			  0 
#define SPK_MFIELD 			  1 
#define SPK_KFIELD 			  2 
#define SPK_WFIELD 			  3 
#define SPK_TFIELD 			  4 
#define SPK_DONE				  5 

// UDP control stuff
#define UDP_NUMOPTS			  10 
#define UDP_CURRENT			  0 
#define UDP_STATUS 			  1 
#define UDP_DROPPED			  2 
#define UDP_SEQUENCE			  3 
#define UDP_SEND				  4 
#define UDP_RECV				  5 
#define UDP_DEBUG				  6 
#define UDP_FORCE_RESET		  7 
#define UDP_UPDATE_ALL 		  8 
#define UDP_DONE				  9 
#define COMM_TCP				  0 
#define COMM_UDP				  1 
#define COMM_VERIFY			  2 
#define COMM_UPDATE			  3 
#define COMM_MODE				  4 
#define SWITCH_TCP_OK			  0 
#define SWITCH_UDP_OK			  1 
#define SWITCH_DENIED			  2 
#define SWITCH_VERIFY			  3 
#define CONNMODE_PORT			  0 
#define CONNMODE_PACKET		  1 
#define STAT_CONNECTED 		  0 
#define STAT_SWITCH_UDP		  1 
#define STAT_SWITCH_TCP		  2 
#define STAT_VERIFY_UDP		  3 
#define MODE_TCP				  0 
#define MODE_SIMPLE			  1 
#define MODE_FAT				  2 
#define MODE_DOUBLE			  3 
#define UDP_RECENT_INTR		  300 
#define UDP_UPDATE_WAIT		  5     


