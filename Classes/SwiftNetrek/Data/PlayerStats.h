//
//  PlayerStats.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "Rank.h"
#import "Status.h"
#import "SimpleBaseClass.h"

 #define STATS_MAPMODE			 1
 #define STATS_NAMEMODE          2
 #define STATS_SHOWSHIELDS		 4
 #define STATS_KEEPPEACE		 8
 #define STATS_SHOWLOCAL		 16	// two bits for these two
 #define STATS_SHOWGLOBAL		 64

@interface PlayerStats : SimpleBaseClass {
    
    double maxkills;				// max kills ever
    int kills;  					// how many kills
    int losses;						// times killed
    int armsbomb;					// armies bombed
    int planets;					// planets conquered
    int tkills;						// Kills in tournament play
    int tlosses;					// Losses in tournament play
    int tarmsbomb;					// Tournament armies bombed
    int tplanets;					// Tournament planets conquered
    int tticks;						// Tournament ticks
    
    // SB stats are entirely separate
    int sbkills;					// Kills as starbase
    int sblosses;					// Losses as starbase
    int sbticks;					// Time as starbase
    double sbmaxkills;				// Max kills as starbase
    
    long st_lastlogin;				// Last time this player was played
    int flags;						// Misc option flags
    Rank *rank;                     // Ranking of the player
    
    // a list of available ranks
    NSArray *ranks;
}

-(Rank*)rank;
- (int)kills;
- (int)losses;
- (int)maxKills;
- (int)tournamentKills;
- (int)tournamentLosses;
- (int)starbaseKills;
- (int)starbaseLosses;
- (int)starbaseMaxKills;
-(Rank *) rankWithId:(int)rankId;

-(void) setFlags:(int)newFlags;
-(Rank *) setRankWithId:(int)rankId;
-(void) setStarbaseTicks:(int) starbaseTicks;
-(void) setMaxKills:(double)newMaxKills;

-(float) bombingRating:(Status *) sts;
-(float) planetRating:(Status *) sts;
-(float) offenceRating:(Status *) sts;
-(float) defenceRating:(Status *) sts;
-(float) starbaseKillsPerHour;
-(float) starbaseDefensePerHour;

-(void) updateTournamentKills: (int) newTKills
             tournamentLosses: (int) newTLosses
                        kills: (int) newKills
                       losses: (int) newLosses
              tournamentTicks: (int) newTTicks
            tournamentPlanets: (int) newTPlanets
       tournamentArmiesBombed: (int) newTArmiesBombed
                starbaseKills: (int) newSBKills
               starbaseLosses: (int) newSBLosses
                 armiesBombed: (int) newArmiesBombed
                      planets: (int) newPlanets
             starbaseMaxKills: (double)newSBMaxKills;
@end
