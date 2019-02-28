//
//  Ship.m
//  MacTrek
//
//  Created by Aqua on 22/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Ship.h"


@implementation Ship

- (id) init {
    self = [super init];
    if (self != nil) {
        abbrev = nil;      
        phaserdamage = 0;
        maxspeed = 0;
        maxfuel = 0;
        maxshield = 0;
        maxdamage = 0;
        maxegntemp = 0;
        maxwpntemp = 0;
        maxarmies = 0;
        width = 0;
        height = 0;
        type = 0;             
        torpspeed = 0;
        phaserfuse = 0;
    }
    return self;
}

- (id) initWithType:(int)shiptype {
    self = [self init];
    if (self != nil) {
        type = shiptype;
        
        switch (type) {
        case SHIP_SC:
            abbrev = [NSString stringWithString:@"SC"];
            phaserdamage = 75;
            torpspeed = 16;
            maxspeed = 12;       
            maxfuel = 5000;      
            maxarmies = 2;       
            maxshield = 75;
            maxdamage = 75;      
            maxwpntemp = 1000;   
            maxegntemp = 1000;   
            width = 20;          
            height = 20;         
            phaserfuse = 10;
            break;
        case SHIP_DD:
            abbrev = [NSString stringWithString:@"DD"];
            phaserdamage = 85;
            torpspeed = 14;  
            maxspeed = 10;   
            maxfuel = 7000;  
            maxarmies = 5;   
            maxshield = 85;  
            maxdamage = 85;  											   
            maxwpntemp = 1000;											  
            maxegntemp = 1000;
            width = 20;      
            height = 20;     											   
            phaserfuse = 10;
            break;
        case SHIP_CA:
            abbrev = [NSString stringWithString:@"CA"];
            phaserdamage = 100;
            torpspeed = 12;    
            maxspeed = 9;      
            maxfuel = 10000;   
            maxarmies = 10;    
            maxshield = 100;   
            maxdamage = 100;                                              
            maxwpntemp = 1000;                                          
            maxegntemp = 1000;
            width = 20;        
            height = 20;       
            phaserfuse = 10;            
            break;
        case SHIP_BB:
            abbrev = [NSString stringWithString:@"BB"];
            phaserdamage = 105;											   
            torpspeed = 12;
            maxspeed = 8;   											  
            maxfuel = 14000;
            maxarmies = 6;  											   
            maxshield = 130;											   
            maxdamage = 130;											   
            maxwpntemp = 1000;											  
            maxegntemp = 1000;
            width = 20;     
            height = 20;    											   
            phaserfuse = 10;            
            break;
        case SHIP_AS:
            abbrev = [NSString stringWithString:@"AS"];
            phaserdamage = 80;
            torpspeed = 16;
            maxspeed = 8;      
            maxfuel = 6000;    
            maxarmies = 20;    
            maxshield = 80;    
            maxdamage = 200;
            maxwpntemp = 1000;											   
            maxegntemp = 1200;
            width = 20;        
            height = 20;       
            phaserfuse = 10;
            break;
        case SHIP_SB:
            abbrev = [NSString stringWithString:@"SB"];
            phaserdamage = 120;
            torpspeed = 14;   
            maxfuel = 60000;  
            maxarmies = 25;   
            maxshield = 500;  
            maxdamage = 600;  
            maxspeed = 2;     											   
            maxwpntemp = 1300;											   
            maxegntemp = 1000;
            width = 20;       
            height = 20;      
            phaserfuse = 4;
            break;
        case SHIP_GA:
            abbrev = [NSString stringWithString:@"GA"];
            phaserdamage = 100;
            torpspeed = 13;    
            maxspeed = 9;      
            maxfuel = 12000;   
            maxarmies = 12;    
            maxshield = 140;   
            maxdamage = 120;   
            maxwpntemp = 1000;
            maxegntemp = 1000;
            width = 20;        
            height = 20;       
            phaserfuse = 10;
            break;
        case SHIP_AT:
            abbrev = [NSString stringWithString:@"AT"];
            phaserdamage = 10000;  
            torpspeed = 30;        
            maxspeed = 60;         
            maxfuel = 12000;       
            maxarmies = 1000;      
            maxshield = 30000;     
            maxdamage = 30000;     
            maxwpntemp = 10000;    
            maxegntemp = 10000;    
            width = 28;            
            height = 28;           
            phaserfuse = 1;
            break;
        default:
            abbrev = [NSString stringWithString:@"??"];
            LLLog(@"Ship.initWithType: unknown %d", type);
            break;
        }
        [abbrev retain];
    }
    return self;
}

- (void) setTorpSpeed: (int) newSpeed {
    torpspeed = newSpeed;
}

- (void) setPhaserDamage: (int) newPhaserDamage {
    phaserdamage = newPhaserDamage;
}

- (int) phaserDamage {
    return phaserdamage;
}

- (int) phaserRange {
    return 6000*phaserdamage/100;
}

- (void) setMaxSpeed: (int) newMaxSpeed {
    maxspeed = newMaxSpeed;
}

- (void) setMaxFuel: (int) newMaxFuel {
    maxfuel = newMaxFuel;
}

- (void) setMaxShield: (int) newMaxShield {
    maxshield = newMaxShield;
}

- (void) setMaxDamage: (int) newMaxDamage {
    maxdamage = newMaxDamage;
}

- (void) setMaxWeaponTemp: (int) newMaxWeaponTemp {
    maxwpntemp = newMaxWeaponTemp;
}

- (void) setMaxEngineTemp: (int) newMaxEngineTemp {
    maxegntemp = newMaxEngineTemp;
}

- (void) setWidth: (int) newWidth {
	
	// Sturgion server send crazy widths
	LLLog(@"Ship.setWidth to %d, old setting %d");
	//width = newWidth;
}

- (void) setHeight: (int) newHeight {
    height = newHeight;
}

// original netrek sizes are scaled at a factor 40 fix!
- (NSSize) size {
    return NSMakeSize(width*40, height*40);
}

- (NSSize) explosionSize {
    if (type == SHIP_SB) {
        return NSMakeSize(width*40*2, height*40*2);
    } else {
        return NSMakeSize(width*40, height*40);
    }
}

- (int) type {
    return type;
}

- (int) maxDamage {
    return maxdamage; 
}

- (int) maxPhaserFuse {
    // always 100 % though it might depend on shiptype...
    return 100; 
}

- (NSString*)abbreviation {
    return abbrev;
}

- (NSString*)shortName {
    return [NSString stringWithFormat:@"%@", abbrev];
}

- (NSString*)longName {
    return [NSString stringWithFormat:@"[%@]", abbrev];
}

- (int) maxShield {
    return maxshield;
}

- (int) maxHull {
    return maxdamage;
}

- (int) maxFuel {
    return maxfuel;
}

- (int) maxSpeed {
    return maxspeed;
}

- (int) maxEngineTemp {
    return maxegntemp;
}

- (int) maxWeaponTemp {
    return maxwpntemp;
}

- (int) maxArmies {
    return maxarmies;
}

- (void) setMaxArmies: (int) newMaxArmies {
    maxarmies = newMaxArmies;
}

- (int) maxTorps {
    // ok very bad this should have been TORP_MAX, but for some crasy reason
    // i cant get it imported
    return 8;
}

@end
