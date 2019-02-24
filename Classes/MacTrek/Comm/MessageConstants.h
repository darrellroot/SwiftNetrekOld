/*
 *  MessageConstants.h
 *  MacTrek
 *
 *  Created by Aqua on 26/04/2006.
 *  Copyright 2006 Luky Soft. See Licence.txt for licence details.
 *
 */


#define VALID		  0x01 
#define GOD			  0x10 
#define MOO			  0x12 

#define MVALID 0x01
#define MINDIV 0x02
#define MTEAM  0x04
#define MALL   0x08
#define MDISTR 0xC0

// order flags by importance (0x100 - 0x400) 
// restructuring of message flags to squeeze them all #defineo 1 #define - jmn 
// hopefully quasi-back-compatible:
// MVALID, MINDIV, MTEAM, MALL, MGOD use up 5 bits. this leaves us 3 bits.
// since the server only checks for those flags when deciding message
// related things and since each of the above cases only has 1 flag on at
// a time we can overlap the meanings of the flags 

#define INDIV		  0x02 
// these go with MINDIV flag 
#define DBG			  0x20 
#define CONFIG		  0x40 
#define DIST		  0x60 
#define MACRO		  0x80 
#define TEAM		  0x04 
// these go with MTEAM flag
#define TAKE		  0x20 
#define DEST		  0x40 
#define BOMB		  0x60 

#define ALL			  0x08 
// these go with MALL flag
#define CONQ		  0x20 
#define KILL		  0x80 
#define DISTR		  0xC0 
#define PHASER		  0x100 