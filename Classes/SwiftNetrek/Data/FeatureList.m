//
//  FeatureList.m
//  MacTrek
//
//  Created by Aqua on 26/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "FeatureList.h"
#import "BeepLite.h"


@implementation FeatureList

- (id) init {
    features = nil;
    self = [super init];
    if (self != nil) {
        features = [NSArray arrayWithObjects:
                [[Feature alloc] initWithName:@"FEATURE_PACKETS" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_ALREADY_SENT],
                [[Feature alloc] initWithName:@"NEWMACRO" type: FEATURE_CLIENT_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"SMARTMACRO" type: FEATURE_CLIENT_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"WHY_DEAD" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"SBHOURS" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"CLOAK_MAXWARP" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"SELF_8FLAGS" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"SELF_8FLAGS2" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_OFF sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"RC_DISTRESS" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"MULTIMACROS" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"SHIP_CAP" type: FEATURE_SERVER_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"BEEPLITE" type: FEATURE_CLIENT_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"CONTINUOUS_MOUSE" type: FEATURE_CLIENT_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                [[Feature alloc] initWithName:@"CONTINUOUS_STEER" type: FEATURE_CLIENT_TYPE 
                                 desiredValue:FEATURE_ON sendWithRSA: FEATURE_SEND_FEATURE],
                nil];
        // important! arrayWithObjects is autoretained ! so lock it here
        [features retain];
                
    }
    return self;
}

- (int) valueForFeature:(int)feature {
    Feature *feat = [features objectAtIndex:feature];
    return [feat value];
}

-(void) checkFeature:(NSString*)name withType:(char)type withArg1:(int)arg1 withArg2:(int)arg2 withValue:(int)value {
    
    if (features == nil) {
        LLLog(@"FeatureList.checkFeature %@ initialization ERROR", name);
        return;
    }
    
    for(int f = 0; f < [features count]; f++) {
        Feature *feature = [features objectAtIndex: f]; 
        if([name isEqualToString:[feature name]]) {
            // if server returns unknown, set to off for server mods, desired
            // value for client mods. Otherwise,  set to value from server.
            if (value == FEATURE_UNKNOWN) {
                if ([feature type] == FEATURE_SERVER_TYPE) {
                    [feature setValue: FEATURE_OFF];
                } else {
                    [feature setValue:[feature desiredValue]];
                }
            } else {
                [feature setValue:value];
            }

            if ([feature arg1] != 0) {
                [feature setArg1:arg1];
            }
            if ([feature arg2] != 0) {
                [feature setArg2:arg2];
            }
            
            if([name isEqualToString:@"FEATURE_PACKETS"]) {
              //  for (int i = 0; i < [features count]; i++) {
              //     LLLog([NSString stringWithFormat:@"FeatureList.checkFeature: SERVER FEATURES - %@ = %d", 
              //         [[features objectAtIndex:i] name], 
              //         [[features objectAtIndex:i] value]]);
              //  }
            }
            else if([name isEqualToString: @"RC_DISTRESS"] && 
                    [self valueForFeature: FEATURE_LIST_GEN_DISTRESS] != FEATURE_OFF) {
                //$$ no idea what to do with that
                //Defaults.rcds = Defaults.preferred_rcds;
            }
            else if([name isEqualToString:@"BEEPLITE"]) {
                
                feature = [features objectAtIndex:FEATURE_LIST_BEEPLITE];
                switch (value) {
					case FEATURE_UNKNOWN: // Unknown, we can use all of the features!
						[feature setArg1: BEEPLITE_PLAYERS_MAP | BEEPLITE_PLAYERS_LOCAL 
                        | BEEPLITE_SELF | BEEPLITE_PLANETS | BEEPLITE_SOUNDS 
                        | BEEPLITE_COLOR | BEEPLITE_TTS];
						break;
					case FEATURE_ON:
						if ([feature arg1] == 0) {					
							// Server says we can have beeplite, but no
							// options??? must be configured wrong.
							[feature setArg1: BEEPLITE_PLAYERS_MAP | BEEPLITE_PLAYERS_LOCAL
                                | BEEPLITE_SELF | BEEPLITE_PLANETS | BEEPLITE_SOUNDS 
                                | BEEPLITE_COLOR | BEEPLITE_TTS];
						}
						int flags = [feature arg1];
						NSMutableString *s;
						if ((flags & BEEPLITE_PLAYERS_MAP) == 0) {
							[s appendString:@" PLAYERS_MAP"];
						}
                        if ((flags & BEEPLITE_PLAYERS_LOCAL) == 0) {
                            [s appendString:@" PLAYERS_LOCAL"];
                        }
                        if ((flags & BEEPLITE_SELF) == 0) {
                            [s appendString:@" SELF"];
                        }
                        if ((flags & BEEPLITE_PLANETS) == 0) {
                            [s appendString:@" PLANETS"];
                        }
                        if ((flags & BEEPLITE_SOUNDS) == 0) {
                            [s appendString:@" SOUNDS"];
                        }
                        if ((flags & BEEPLITE_COLOR) == 0) {
                            [s appendString:@" COLOR"];
                        }
                        if ((flags & BEEPLITE_TTS) == 0) {
                            [s appendString:@" TTS"];
                        }
                        if ([s length] > 0) {
                            LLLog([NSString stringWithFormat:@"%@ disabled", s]);
                        }
                        break;
					case FEATURE_OFF:
						[feature setArg1: 0];
						break;
                }
            }
        } 
        //LLLog([NSString stringWithFormat:@"FeatureList.checkFeature: Feature %@ from server unknown to client!", name]);
    }
    
}


@end
