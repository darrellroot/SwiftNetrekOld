//
//  PlayerStats.m
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "PlayerStats.h"


@implementation PlayerStats

- (id) init {
    self = [super init];
    if (self != nil) {
        // float hours, float ratings, float defense, String name
        ranks = [NSArray arrayWithObjects:
            [[Rank alloc] initWithHours: 0 ratings:0 defense:0.0 name:@"Ensign" abbrev:@"Ens"],
            [[Rank alloc] initWithHours: 2 ratings:1 defense:0.0 name:@"Lieutenant" abbrev:@"Lt "],
            [[Rank alloc] initWithHours: 4 ratings:2 defense:0.8 name:@"Lt. Cmdr." abbrev:@"Lt Com"],
            [[Rank alloc] initWithHours: 8 ratings:3 defense:0.8 name:@"Commander" abbrev:@"Com"],
            [[Rank alloc] initWithHours:15 ratings:4 defense:0.8 name:@"Captain" abbrev:@"Cap"],
            [[Rank alloc] initWithHours:20 ratings:5 defense:0.8 name:@"Flt. Capt." abbrev:@"Flt Cap"],
            [[Rank alloc] initWithHours:25 ratings:6 defense:0.8 name:@"Commodore" abbrev:@"Com"],
            [[Rank alloc] initWithHours:30 ratings:7 defense:0.8 name:@"Rear Adm." abbrev:@"Rear Adm"],
            [[Rank alloc] initWithHours:40 ratings:8 defense:0.8 name:@"Admiral" abbrev:@"Adm"],
            nil];
        [ranks retain];
        
        // the rest
        maxkills = 0;				    // max kills ever
        kills = 0;  					// how many kills
        losses = 0;						// times killed
        armsbomb = 0;					// armies bombed
        planets = 0;					// planets conquered
        tkills = 0;						// Kills in tournament play
        tlosses = 0;					// Losses in tournament play
        tarmsbomb = 0;					// Tournament armies bombed
        tplanets = 0;					// Tournament planets conquered
        tticks = 0;						// Tournament ticks
        sbkills = 0;					// Kills as starbase
        sblosses = 0;					// Losses as starbase
        sbticks = 0;					// Time as starbase
        sbmaxkills = 0;                 // Max kills as starbase
        st_lastlogin = 0;				// Last time this player was played
        flags = 0;						// Misc option flags
        rank = [self setRankWithId:0];  // Ranking of the player
    }
    return self;
}

-(Rank *) rankWithId:(int)rankId {
    return [ranks objectAtIndex:rankId];
}

-(Rank *) setRankWithId:(int)rankId {
    rank = [ranks objectAtIndex:rankId];
    return rank;
}

-(Rank*)rank {
    return rank;
}

-(void) setFlags:(int)newFlags {
    flags = newFlags;
}

-(void) setStarbaseTicks:(int) starbaseTicks {
    sbticks = starbaseTicks;   
}

-(void) setMaxKills:(double)newMaxKills {
    maxkills = newMaxKills;
}

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
             starbaseMaxKills: (double)newSBMaxKills {
    
    tkills      = newTKills;
    tlosses     = newTLosses;
    kills       = newKills;
    losses      = newLosses;
    tticks      = newTTicks;
    tplanets    = newTPlanets;
    tarmsbomb   = newTArmiesBombed;
    sbkills     = newSBKills;
    sblosses    = newSBLosses;
    armsbomb    = newArmiesBombed;
    planets     = newPlanets;
    sbmaxkills  = newSBMaxKills;
}

- (int)kills {
    return kills;
}

- (int)losses {
    return losses;
}
- (int)maxKills {
    return maxkills;
}
- (int)tournamentKills {
    return tkills;
}

- (int)tournamentLosses {
    return tlosses;
}

- (int)starbaseKills {
    return sbkills;
}

- (int)starbaseLosses {
    return sblosses;
}

- (int)starbaseMaxKills {
    return sbmaxkills;
}

-(float) bombingRating:(Status *) sts {
    if(tticks <= 0 || [sts armiesBombed] <= 0) {
        return 0.0;
    }
    return (float)(((double)tarmsbomb * (double)[sts timeProductive]) / ((double)tticks * (double)[sts armiesBombed]));
}

-(float) planetRating:(Status *) sts {
    if(tticks <= 0 || [sts planets] <= 0) {
        return 0.0;
    }
    return (float)(((double)tplanets * (double)[sts timeProductive]) / ((double)tticks * (double)[sts planets]));
}

-(float) offenceRating:(Status *) sts{
    if(tticks <= 0 || [sts kills] <= 0) {
        return 0.0;
    }
    return (float)(((double)tkills * (double)[sts timeProductive]) / ((double)tticks * (double)[sts kills]));
}

-(float) defenceRating:(Status *) sts{
    if([sts timeProductive] <= 0) {
        return 0.0;
    }
    double top = (double)tticks * (double)[sts losses];
    if(top <= 0) {
        return (float)(top / (double)[sts timeProductive]);
    }
    if(tlosses <= 0) {
        return 1;
    }		
    return (float)(top / ((double)tlosses * (double)[sts timeProductive]));
}

-(float) starbaseKillsPerHour{
    return (sbticks == 0) ? 0.0 : (float)sbkills * 36000.0 / (float)sbticks;
    }

-(float) starbaseDefensePerHour{
    return (sbticks == 0) ? 0.0 : (float)sblosses * 36000.0 / (float)sbticks;
}



@end
