//
//  Status.h
//  MacTrek
//
//  Created by Aqua on 23/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "SimpleBaseClass.h"

@interface Status : SimpleBaseClass {
	bool tourn;    // $$ when set???
	// Was I Promoted?
	bool promoted;    
	// These stats only updated during tournament mode
	int armsbomb; 
	int planets;
	int kills; 
	int losses;
	int timeElapsed;    
	// Use long for this, so it never wraps
	long timeprod;    
	// flag that indicates we are playing as an observer
	bool observer;
}

-(int) armiesBombed; 
-(int) planets;
-(int) kills; 
-(int) losses;
-(long) timeProductive;    

-(void) setObserver:(bool)on;
-(void) setPromoted:(bool)prom;
-(void) updateTournament: (int)newTournament
            armiesBombed: (int)newArmiesBombed
            planetsTaken: (int)newPlanets
                   kills: (int)newKills	
                  losses: (int)newLosses
                    time: (int)newTime
                timeProd: (int)newTimeProd;

@end
