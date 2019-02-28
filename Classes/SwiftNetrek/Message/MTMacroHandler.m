//
//  MTMacroHandler.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 26/02/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MTMacroHandler.h"


@implementation MTMacroHandler

char buffer[10 * MAX_MACRO_LENGTH];
int  line_length = 0;

- (id) init {
	self = [super init];
	if (self != nil) {
		featureList = nil;
		//keyMap = nil;
		storedMacro = nil;
		gameViewPointOfCursor = NSZeroPoint;
		macros = [[NSMutableDictionary alloc] init];
		[self initializeMacros];
	}
	return self;
}

- (void) setGameViewPointOfCursor:(NSPoint) p {
	gameViewPointOfCursor = p;
}

- (void) initializeMacros {
	// Read from a file here
	// syntax conforms to netrek standard... (wauw!)
	NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
	NSString *pathToMacros = [NSString stringWithFormat:@"%@/macros.txt", pathToResources];
	NSString *stringWithAllMacros = [[NSString alloc]
                                      initWithContentsOfFile:pathToMacros
													encoding:NSUTF8StringEncoding
													   error:nil];
	if (stringWithAllMacros == nil) {
		// setup some defaults
		[macros setObject:[[MTMacro alloc] initWithName:@"mac.e.T" macro:@"Help!  Damage %d!!"] forKey:@"e"];
		[macros setObject:[[MTMacro alloc] initWithName:@"mac.f.T" macro:@"Help!  Carrying %a!!"] forKey:@"f"];	
	} else {
		// parse the macro file (let's hope it is there)
		NSArray *lines = [stringWithAllMacros componentsSeparatedByString:@"\n"];
		unsigned int i, count = [lines count];
		for (i = 0; i < count; i++) {
			NSString *macroLine = [lines objectAtIndex:i];
			NSArray *macroElements = [macroLine componentsSeparatedByString:@":"];
			if ([macroElements count] == 2) {
				MTMacro *macro = [[MTMacro alloc] initWithName:[macroElements objectAtIndex:0] macro:[macroElements objectAtIndex:1]];
				[macros setObject:macro forKey:[macro keyAsString]];
			} else {
				LLLog(@"MTMacroHandler.initializeMacros illigal macro %@", macroLine);
			}
		}
	}
}

- (void) setFeatureList:(FeatureList *)list {
	featureList = list;
}

/** handleMacro */
- (bool) handleMacroForKey:(char) key {
	
	if(storedMacro != nil) {
		[self sendMacro:storedMacro toPlayer:key];
		storedMacro = nil;
		return YES;
	}
	
	//MTMacro *macro = [self getMacroForKey:key];
	MTMacro *macro = [macros objectForKey:[NSString stringWithFormat:@"%c", key]];	
	
	if(macro == nil) {
		
		// could be a default distress 
		// $$ leave this for now, distress is normal macro
		/*
		for(int r = 0; r < Defaults.rcds.length; ++r) {
			if(key == Defaults.rcds[r].key) {
				[self sendDistress:r];
				return YES;
			}
		}
		*/
		// status display should listen to this
		[notificationCenter postNotificationName:@"MH_UNKNOWN_MACRO" userInfo:[NSNumber numberWithChar:key]];
		
		return YES;
	}
	return [self executeMacro:macro];
}

/** handleSingleMacro */
- (bool) handleSingleMacroForKey:(char) key {
	
	//MTMacro *macro = [self getMacroForKey:key];
	MTMacro *macro = [macros objectForKey:[NSString stringWithFormat:@"%c", key]];
	if(macro == nil) {
		[notificationCenter postNotificationName:@"MH_UNKNOWN_MACRO" userInfo:[NSNumber numberWithChar:key]];
		return YES; 
	}
	return [self executeMacro:macro];
}


/** executeMacro */
- (bool) executeMacro:(MTMacro *) macro {
	if([macro type] != MACRO_NBTM && [featureList valueForFeature:FEATURE_LIST_NEW_MACRO] != FEATURE_ON) {
		[notificationCenter postNotificationName:@"MH_SERVER_NOT_ALLOWS_NEWMACRO"];
		return YES;
	}
	if([macro type] == MACRO_NEWM) {
		storedMacro = macro;
		// wait until we are assigned a destination
		//[notificationCenter postNotificationName:@"MH_UNKNOWN_DESTINATION_MACRO"];
		return NO;
	}
	[self sendMacro:macro];
	return YES;
}

/** sendMacro */
-(void) sendMacro:(MTMacro*) macro {
	[self sendMacro:macro toPlayer:[macro who]];
}

/** sendMacro */
-(void) sendMacro:(MTMacro*) macro toPlayer:(char) who {
	
	switch([macro type]) {
		case MACRO_NBTM:
		case MACRO_NEWMSPEC:
		case MACRO_NEWM:
			break;
		case MACRO_NEWMOUSE: {
			int target_type ;
			switch([macro who]) {
				case MACRO_FRIEND:
				case MACRO_ENEMY:
				case MACRO_PLAYER: {
					target_type = UNIVERSE_TARG_PLAYER | UNIVERSE_TARG_CLOAK;
					if([macro who] == MACRO_ENEMY) {
						target_type |= UNIVERSE_TARG_ENEMY;
					}
					else if([macro who] == MACRO_FRIEND) {
						target_type |= UNIVERSE_TARG_FRIEND;
					}
					Player *player =  [universe playerNearPosition:gameViewPointOfCursor ofType:target_type];
					who = [[player team] letterForPlayer:[player playerId]];
					break;	
				}
				case MACRO_TEAM: {
					Planet *planet = [universe planetNearPosition:gameViewPointOfCursor];
					Player *player = [universe playerNearPosition:gameViewPointOfCursor ofType:UNIVERSE_TARG_PLAYER];
					if ([universe entity:player closerToMeThan:planet]) {
						who = [[player team] letterForPlayer:[player playerId]];
					} else {
						who = [[player team] letterForTeam];
					}
					break;
					default:
						player =  [universe playerThatIsMe];
						who = [[player team] letterForPlayer:[player playerId]];
						break;
				}
			}
			break;
		}
	}
	
	// use clean macro's or create a distress call..
	// $$$ very strange should support MACRO_NEWMSPEC too
	// $$$ should put this in the macro itself and not in the handler
	NSString *message;
	if ([macro type] != MACRO_NBTM) {
		MTDistress *distress = [[MTDistress alloc] initWithType:DC_GENERIC gamePointForMousePosition:gameViewPointOfCursor];
		message = [self parseMacro:distress];
		[distress release];
	} else {
		message = [macro macroString];
	}

	
	// iterate message for newlines
	NSRange range = [message rangeOfString:@"\n"];
	if (range.location == NSNotFound) {
		// prepend the destination
		NSMutableString *temp = [NSMutableString stringWithString:[macro whoLongFormat]];
		[temp appendString:message];
		[notificationCenter postNotificationName:@"MH_MESSAGE" userInfo:temp];
	} else {
		while (range.location != NSNotFound) {
			NSRange lineRange = NSMakeRange(0, range.location);
			// prepend the destination
			NSMutableString *temp = [NSMutableString stringWithString:[macro whoLongFormat]];
			[temp appendString:[message substringWithRange:lineRange]];
			[notificationCenter postNotificationName:@"MH_MESSAGE" userInfo:temp];
			// remove string and search again
			message = [message substringFromIndex:range.location+1];
			range = [message rangeOfString:@"\n"];
		}
	}
}

/** sendDistress */
-(void) sendReceiverConfigureableDistress:(int) type {
	MTDistress *distress = [[MTDistress alloc] initWithType:type gamePointForMousePosition:gameViewPointOfCursor];
	
	[distress setDestinationGroup: (TEAM | DISTR)
					   individual: [[[universe playerThatIsMe] team] bitMask]];
	
	// create RCD String
	NSString *message = [distress rcdString];
	[distress release];
	NSString *destination = [[[[universe playerThatIsMe] team] abbreviation] uppercaseString];
	// prepend the destination 
	NSMutableString *temp = [NSMutableString stringWithString:destination];
	[temp appendString:message];
	[notificationCenter postNotificationName:@"MH_RCD_MESSAGE" userInfo:temp];
}

/** sendDistress */
-(void) sendDistress:(int) type {
	MTDistress *distress = [[MTDistress alloc] initWithType:type gamePointForMousePosition:gameViewPointOfCursor];
	
	[distress setDestinationGroup: TEAM
					   individual: [[[universe playerThatIsMe] team] bitMask]];
	
	// initial version sends a distress parsed as a macro,
	// not as a true RCD
	NSString *message = [self parseMacro:distress];
	[distress release];
	
	// iterate message for newlines
	NSRange range = [message rangeOfString:@"\n"];
	// $$$ SEND ALL to my TEAM
	NSString *destination = [[[[universe playerThatIsMe] team] abbreviation] uppercaseString];
	if (range.location == NSNotFound) {
		// prepend the destination 
		NSMutableString *temp = [NSMutableString stringWithString:destination];
		[temp appendString:message];
		[notificationCenter postNotificationName:@"MH_MESSAGE" userInfo:temp];
	} else {
		while (range.location != NSNotFound) {
			NSRange lineRange = NSMakeRange(0, range.location);
			// prepend the destination
			NSMutableString *temp = [NSMutableString stringWithString:destination];
			[temp appendString:[message substringWithRange:lineRange]];
			[notificationCenter postNotificationName:@"MH_MESSAGE" userInfo:temp];
			// remove string and search again
			message = [message substringFromIndex:range.location+1];
			range = [message rangeOfString:@"\n"];
		}
	}	
}

/** parseMacro */
- (NSString*) parseMacro:(MTDistress*) distress {
	
	return [distress parsedMacroString]; // watch out is autoretained
}

@end
