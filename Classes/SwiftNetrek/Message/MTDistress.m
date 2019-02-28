//
//  MTDistress.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 01/03/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MTDistress.h"


@implementation MTDistress

- (id) init {
	self = [super init];
	if (self != nil) {
		sender = [universe playerThatIsMe];
		damage = 0;
		shields = 0;
		armies = 0;
		wtemp = 0;
		etemp = 0;
		fuel_percentage = 0;
		short_status = 0;
		wtemp_flag = 0;
		etemp_flag = 0;
		cloak_flag = 0;
		distress_type = 0;
		macro_flag = 0;
		
		close_planet = nil;
		target_planet = nil;
		
		close_player = nil;
		close_friend = nil;
		close_enemy = nil;
		
		target_player = nil;
		target_friend = nil;
		target_enemy = nil;	
		cclist = (char*) malloc(6);
		prepend = NO;
		prepend_append = @"";	
		
		destinationGroup = -1;
		destinationIndiv = -1;
	}
	return self;
}

- (id) initWithSender:(Player*)player buffer:(char *)buffer {
	self = [self init];
	if (self != nil) {
		sender = player;
		
		const char *mtext = &buffer[10]; 
		
		distress_type = mtext[0] & 0x1F;
		macro_flag = ((mtext[0] & 0x20) > 0);
		fuel_percentage = mtext[1] & 0x7F;
		damage = mtext[2] & 0x7F;
		shields = mtext[3] & 0x7F;
		etemp = mtext[4] & 0x7F;
		wtemp = mtext[5] & 0x7F;
		armies = mtext[6] & 0x1F;
		short_status = mtext[7] & 0x7F;
		wtemp_flag = ((short_status & PLAYER_WEP) != 0);
		etemp_flag= ((short_status & PLAYER_ENG) != 0);
		cloak_flag = ((short_status & PLAYER_CLOAK) != 0);
		
		close_planet = [universe planetWithId:(mtext[8] & 0x7F)];
		target_planet = [universe planetWithId:(mtext[10] & 0x7F)];
		
		close_player = [universe playerWithId:(mtext[13] & 0x7F)];
		close_friend = [universe playerWithId:(mtext[15] & 0x7F)];
		close_enemy = [universe playerWithId:(mtext[9] & 0x7F)];
		
		target_player = [universe playerWithId:(mtext[12] & 0x7F)];
		target_friend = [universe playerWithId:(mtext[14] & 0x7F)];
		target_enemy = [universe playerWithId:(mtext[11] & 0x7F)];
		
		int i = 0;
		while ((mtext[16 + i] & 0xC0) == 0xC0 && (i < 6)) {
			cclist[i] = (char)(mtext[16 + i] & 0x1F);
			i++;
		}
		cclist[i] = mtext[16 + i];
		prepend = ((cclist[i] & 0xFF) == 0x80);
		int end = 17 + i;
		if(buffer[end] != '\0') {
			
			prepend_append = [[[NSString alloc] initWithBytes:&mtext[end] length:(80 - end) encoding:NSASCIIStringEncoding] autorelease]; 
		}
	}
	return self;
}

- (id) initWithType:(int)type gamePointForMousePosition:(NSPoint)mouse {
	
	self = [self init];
	if (self != nil) {
		
		distress_type = (char)type;
		if(distress_type < DC_TAKE || distress_type > DC_GENERIC) {
			distress_type = DC_GENERIC;
		}		
		
		damage = (100 * [sender damage]) / [[sender ship] maxDamage];
		shields = (100 * [sender shield]) / [[sender ship] maxShield];
		armies = [sender armies];
		fuel_percentage = (100 * [sender fuel]) / [[sender ship] maxFuel];
		wtemp = (100 * [sender weaponTemp]) / [[sender ship] maxWeaponTemp];
		etemp = (100 * [sender engineTemp]) / [[sender ship] maxEngineTemp];
		short_status = ([sender flags] & 0xFF) | 0x80;
		wtemp_flag = (([sender flags] & PLAYER_WEP) != 0);
		etemp_flag= (([sender flags] & PLAYER_ENG) != 0);
		cloak_flag = (([sender flags] & PLAYER_CLOAK) != 0);
		
		
		
		close_planet = [universe planetNearMe];
		close_player = [universe playerNearMeOfType:UNIVERSE_TARG_PLAYER];
		close_friend = [universe playerNearMeOfType:UNIVERSE_TARG_FRIEND];
		close_enemy =  [universe playerNearMeOfType:UNIVERSE_TARG_ENEMY];
		
		target_planet = [universe planetNearPosition:mouse];		
		target_player = [universe playerNearPosition:mouse ofType:UNIVERSE_TARG_PLAYER];
		target_friend = [universe playerNearPosition:mouse ofType:UNIVERSE_TARG_FRIEND];
		target_enemy =  [universe playerNearPosition:mouse ofType:UNIVERSE_TARG_ENEMY];	
		
		cclist[0] = (char)0x80;		
	}
	return self;
}

- (id) initWithSender:(Player*) sndr targetPlayer:(Player*) trgtPlyr armies:(int) arms 
			  damage:(int) dmg shields:(int) shlds targetPlanet:(Planet*)trgtPlnt
		   weaponTemp:(int) wtmp {
	
	self = [self init];
	if (self != nil) {
		distress_type = DC_RCM;
		sender = sndr;
		target_player = trgtPlyr;
		armies = arms;
		damage = dmg;
		shields = shlds;
		target_planet = trgtPlnt;
		wtemp = wtmp;	
	}
	return self;
}

- (NSString*) rcdString {
	
	NSMutableString *message;
	int length = 16;
		
	message = [NSMutableString stringWithFormat:@"%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c",
		(char)((macro_flag ? 1 : 0) << 5 | distress_type),
		(char)(fuel_percentage | 0x80),
		(char)(damage | 0x80),
		(char)(shields | 0x80),
		(char)(etemp | 0x80),
		(char)(wtemp | 0x80),
		(char)(armies | 0x80),
		(char)(short_status | 0x80),
		(char)([close_planet planetId] | 0x80),
		(char)([close_enemy playerId] | 0x80),
		(char)([target_planet planetId] | 0x80),
		(char)([target_enemy playerId] | 0x80),
		(char)([target_player playerId] | 0x80),
		(char)([close_player playerId] | 0x80),
		(char)([target_friend playerId] | 0x80),
		(char)([close_friend playerId] | 0x80)];
	
	// cclist better be terminated properly otherwise we hose here
	int i = 0;
	while (((cclist[i] & 0xc0) == 0xc0)) {
		[message appendFormat:@"%c", (char)(cclist[i] & 0xFF)];
		i++;
	}
	// get the pre/append cclist terminator in there
	[message appendFormat:@"%c", (char)(cclist[i] & 0xFF)]; // strange ??
	
	length = 17 + i;
	if ([prepend_append length] > 0) {
		[message appendString:prepend_append];
	}
	
	// retain string !!
	[message retain];
	
	return message;
}

- (void) setDestinationGroup:(int)grp individual:(int)indiv {
	destinationGroup = grp;
	destinationIndiv = indiv;
}

- (int) destinationGroup {
	return destinationGroup;
}

- (int) destinationIndiv {
	return destinationIndiv;
}

- (NSString *)defaultMacro {
	return [self defaultMacroForType:distress_type];
}

- (NSString *)defaultMacroForType:(int)type {
	
	switch (type) {
		case  DC_TAKE:
			return @" %T%c@%b (%S) Carrying %a to %l%?%n>-1%{ @ %n%}";
			break;
		case  DC_OGG:
			return @" %T%c@%b Help Ogg %p at %l";
			break;
		case  DC_BOMB:
			return @" %T%c@%b %?%n>4%{bomb %l @ %n%!bomb%}";
			break;
		case  DC_SPACE_CONTROL:
			return @" %T%c@%b Help Control at %L";
			break;
		case  DC_SAVE_PLANET:
			return @" %T%c@%b Emergency at %L!!!!";
			break;
		case  DC_BASE_OGG:
			return @" %T%c@%b Sync with --]> %g <[-- OGG ogg OGG base!!";
			break;
		case  DC_HELP3:
			return @" %T%c@%b Help me! %d%% dam, %s%% shd, %f%% fuel %a armies.";
			break;
		case  DC_HELP4:
			return @" %T%c@%b Help me! %d%% dam, %s%% shd, %f%% fuel %a armies.";
			break;
		case  DC_ESCORTING:
			return @" %T%c@%b ESCORTING %g (%d%%D %s%%S %f%%F)";
			break;
		case  DC_OGGING:
			return @" %T%c@%b Ogging %h";
			break;
		case  DC_BOMBING:
			return @" %T%c@%b Bombing %l @ %n";
			break;
		case  DC_CONTROLLING:
			return @" %T%c@%b Controlling at %l";
			break;
		case  DC_ASW:
			return @" %T%c@%b Anti-bombing %p near %b.";
			break;
		case  DC_ASBOMB:
			return @" %T%c@%b DON'T BOMB %l. Let me bomb it (%S)";
			break;
		case  DC_DOING3:
			return @" %T%c@%b (%i)%?%a>0%{ has %a arm%?%a=1%{y%!ies%}%} at %l.  (%d%% dam, %s%% shd, %f%% fuel)";
			break;
		case  DC_DONIG4:
			return @" %T%c@%b (%i)%?%a>0%{ has %a arm%?%a=1%{y%!ies%}%} at %l.  (%d%% dam, %s%% shd, %f%% fuel)";
			break;
		case  DC_FREE_BEER:
			return @" %T%c@%b %p is free beer";
			break;
		case  DC_NO_GAS:
			return @" %T%c@%b %p @ %l has no gas";
			break;
		case  DC_CRIPPLED:
			return @" %T%c@%b %p @ %l crippled";
			break;
		case  DC_PICKUP:
			return @" %T%c@%b %p++ @ %l";
			break;
		case  DC_POP:
			return @" %T%c@%b %l%?%n>-1%{ @ %n%}!";
			break;
		case  DC_CARRYING:
			return @" %T%c@%b %?%S=SB%{Your Starbase is c%!C%}arrying %?%a>0%{%a%!NO%} arm%?%a=1%{y%!ies%}.";
			break;
		case  DC_OTHER1:
			return @" %T%c@%b (%i)%?%a>0%{ has %a arm%?%a=1%{y%!ies%}%} at %l. (%d%%D, %s%%S, %f%%F)";
			break;
		case  DC_OTHER2:
			return @" %T%c@%b (%i)%?%a>0%{ has %a arm%?%a=1%{y%!ies%}%} at %l. (%d%%D, %s%%S, %f%%F)";
			break;
		case  DC_GENERIC:
		case  DC_RCM:
		default:
			return @" %T%c@%b Help(%S)! %s%% shd, %d%% dmg, %f%% fuel,%?%S=SB%{ %w%% wtmp,%!%}%E%{ ETEMP!%}%W%{ WTEMP!%} %a armies!";
			break;
	}
}	

/** parseVariables */
- (NSString *) filledMacroString {
	
	// get the default and put it in a buffer
	NSString *defaultMacroValue = [self defaultMacro];
	NSMutableString *buffer = [NSMutableString stringWithCapacity:[defaultMacroValue length]];
	[buffer setString:defaultMacroValue];
	
	// parse it and replace the values
	NSString *string;
	int bpos = 0;
	//LLLog(@"MTDistress.fillMacroString source [%@]", buffer);
	while(bpos < [buffer length]) {
		if([buffer characterAtIndex:bpos] == '%') {
			switch([buffer characterAtIndex:(bpos + 1)]) {
				case ' ':
					string = @" ";
					break;
				case 'O':                 // push a 3 character team name into buf
					string = [[sender team] abbreviation];
					break;
				case 'o':                 // push a 3 character team name into buf
					string = [[[sender team] abbreviation] lowercaseString];
					break;
				case 'a':                 // push army number into buf
					string = [NSString stringWithFormat:@"%d", armies];
					break;
				case 'd':                 // push damage into buf	
					string = [NSString stringWithFormat:@"%d", damage];
					break;
				case 's':                 // push shields into buf
					string = [NSString stringWithFormat:@"%d", shields];
					break;
				case 'f':                 // push fuel into buf 
					string = [NSString stringWithFormat:@"%d", fuel_percentage];
					break;
				case 'w':                 // push wtemp into buf
					string = [NSString stringWithFormat:@"%d", wtemp];
					break;
				case 'e':                 // push etemp into buf
					string = [NSString stringWithFormat:@"%d", etemp];
					break;
				case 'P':                 // push player id into buf
					string = [NSString stringWithFormat:@"%c", [close_player letterForPlayer]];
					break;
				case 'G':                 // push friendly player id into buf
					string = [NSString stringWithFormat:@"%c", [close_friend letterForPlayer]];
					break;
				case 'H':                 // push enemy target player id into buf
					string = [NSString stringWithFormat:@"%c", [close_enemy letterForPlayer]];
					break;
				case 'p':                 // push player id into buf
					string = [NSString stringWithFormat:@"%c", [target_player letterForPlayer]];
					break;
				case 'g':                 // push friendly player id into buf
					string = [NSString stringWithFormat:@"%c", [target_friend letterForPlayer]];
					break;
				case 'h':                 // push enemy target player id into buf
					string = [NSString stringWithFormat:@"%c", [target_enemy letterForPlayer]];
					break;
				case 'n':                 // push planet armies into buf
					string = [NSString stringWithFormat:@"%d", [target_planet armies]];				
					break;
				case 'B':
					string = [[close_planet name] uppercaseString];
					if([string length] > 3) {
						string = [string substringToIndex:3];
					}
					break;
				case 'b':                 // push planet into buf
					string = [close_planet name];
					if([string length] > 3) {
						string = [string substringToIndex:3];
					}
					break;
				case 'L':
					string = [[target_planet name] uppercaseString];
					if([string length] > 3) {
						string = [string substringToIndex:3];
					}						
					break;
				case 'l':                 // push planet into buf
					string = [target_planet name];
					if([string length] > 3) {
						string = [string substringToIndex:3];
					}						
					break;
				case 'N':				// push planet into buf
					string = [target_planet name];
					break;
				case 'Z':                 // push a 3 character team name into buf
					string = [[[target_planet owner] abbreviation] uppercaseString];
					if([string length] > 3) {
						string = [string substringToIndex:3];
					}
						break;
				case 'z':                 // push a 3 character team name into buf
					string = [[target_planet owner] abbreviation];
					if([string length] > 3) {
						string = [string substringToIndex:3];
					}
						break;
				case 't':				// push a team character into buf
					string = [NSString stringWithFormat:@"%c", [[target_planet owner] letterForTeam]];					
					break;
				case 'T':				// push my team into buf
					string = [NSString stringWithFormat:@"%c", [[sender team] letterForTeam]];					
					break;
				case 'r':				// push target team letter into buf
					string = [NSString stringWithFormat:@"%c", [[target_player team] letterForTeam]];
					break;
				case 'c':				// push my id char into buf
					string = [[[sender mapChars] substringFromIndex:1] substringToIndex:1];				
					break;
				case 'W':				// push WTEMP flag into buf
					if(distress_type == DC_RCM) {
						switch (wtemp) {
						case 1:
							string = @"[quit]";
							break;
						case 2:
							string = @"[photon]";
							break;
						case 3:
							string = @"[phaser]";
							break;
						case 4:
							string = @"[planet]";
							break;
						case 5:
							string = @"explosion";
							break;
						case 8:
							string = @"[ghostbust]";
							break;
						case 9:
							string = @"[genocide]";
							break;
						case 11:
							string = @"[plasma]";
							break;	
						case 12:
							string = @"[detted photon]";
							break;
						case 13:
							string = @"[chain explosion]";
							break;
						case 14:
							string = @"[TEAM]";
							break;
						case 16:
							string = @"[team det]";
							break;
						case 17:
							string = @"[team explosion]";
							break;
						default:
							string = @"";
							break;
						}
					}
					else {
						string = (wtemp_flag ? @"1" : @"0");
					}
					break;
				case 'E':				// push ETEMP flag into buf
					string = etemp_flag ? @"1" : @"0";	
					break;
				case 'K':
					string = [NSString stringWithFormat:@"%f", ([target_enemy wins] / 100.0)];
					break;
				case 'k':
					if(distress_type == DC_RCM) {
						string = [NSString stringWithFormat:@"%d.%d", damage, shields];
					}
					else {
						string = [NSString stringWithFormat:@"%f", ([sender wins] / 100.0)];
					}
					break;
				case 'U':                 // push player name into buf 
					string = [[target_player name] uppercaseString];
					break;
				case 'u':                 // push player name into buf 				
					string = [target_player name];
					break;
				case 'I':                 // my player name into buf 
					string = [[sender name] uppercaseString];
					break;
				case 'i':                 // my player name into buf 
					string = [sender name];
					break;
					/*  disabled for now, distress would require a link with comms 
						that's spagetti at best
				case 'v' :
					string = [NSString stringWithFormat:@"%d", comm.ping_stats.av);
					break;
				case 'V' :
					string = [NSString stringWithFormat:@"%d", comm.ping_stats.sd);
					break;
				case 'y' :
					string = [NSString stringWithFormat:@"%d", (2 * comm.ping_stats.tloss_sc + comm.ping_stats.tloss_cs) / 3);
					break;
				case 'M' :					// put capitalized last message into buf
					string = view.smessage.last_message.toUpperCase();
					break;
				case 'm' :					// put the last message send into buf
					string = view.smessage.last_message;
					break;
					*/
				case 'S' :					// push ship type into buf 
					string = [[sender ship] shortName];
					break;
				case '*' :					// push %* into buf 
					string = @"%*";
					break;
				case '}' :                  // push %} into buf 
					string = @"%}";
					break;
				case '{' :                  // push %{ into buf 
					string = @"%{";
					break;
				case '!' :					// push %! into buf 
					string = @"%!";
					break;
				case '?' :					// push %? into buf 
					string = @"%?";
					break;
				case '%' :					// push %% into buf 
					string = @"%%";
					break;
				default:				
					LLLog(@"MTDistress.filledMacroString Bad character %c", [buffer characterAtIndex:(bpos + 1)]);
					break;
				}
			
			NSRange range = NSMakeRange(bpos, 2); // replace the two characters
			[buffer replaceCharactersInRange:range withString:string];
			bpos += [string length];
		}
		else {
			++bpos;
		}
	}
	//LLLog(@"MTDistress.fillMacroString result [%@]", buffer);
	return buffer; // watch out is autoretained!
}

/** parseMacro */
- (NSString*) parsedMacroString {
	
	// first step is to substitute variables
	NSMutableString *buffer = [NSMutableString stringWithString:[self filledMacroString]];
	
	// second step is to evaluate tests
	[self parseTests:buffer];
	
	// third step is to include conditional text
	[self parseConditionals:buffer];
	
	// fourth step is to remove all the rest of the control characters
	[self parseRemaining:buffer];
	
	return buffer; // watch out is autoretained
}


/* support function */
- (void) deleteCharsFromBuffer:(NSMutableString*)buffer start:(int)start end:(int)end {
	
	NSRange range = NSMakeRange(start, end - start + 1);
	//NSString *temp = [buffer substringWithRange:range];
	//LLLog(@"MTMacroHandler.deleteCharsFromBuffer deleting [%@] at %d from [%@]", temp, start, buffer);
	[buffer deleteCharactersInRange:range];
}


/** parseTests */
- (void) parseTests:(NSMutableString *)buffer {
	
	for(int bpos = 0; bpos < [buffer length] - 1; ++bpos) {
		if([buffer characterAtIndex:bpos] == '%') {
			switch([buffer characterAtIndex:bpos + 1]) {
				case '*' :
				case '%' :
				case '{' :
				case '}' :
				case '!' :
					++bpos;
					break;
				case '?' : { 					// solve the conditional
					
					int op_pos = bpos + 2;
					while([buffer characterAtIndex:op_pos] != '<' && [buffer characterAtIndex:op_pos] != '>' && [buffer characterAtIndex:op_pos] != '=') {
						if(op_pos >= [buffer length]) {
							// $$$ MIGHT WANT TO DO SOMETHING SMART HERE!!!
							return;
						}
						op_pos++;
					}
					char operation = [buffer characterAtIndex:op_pos];
					
					int end = op_pos;
					while(++end < [buffer length] - 1) {
						if([buffer characterAtIndex:end] == '%' && ([buffer characterAtIndex:end + 1] == '?' || [buffer characterAtIndex:end + 1] == '{')) {
							break;
						}
					}
					
					NSString *left = [buffer substringWithRange:NSMakeRange(bpos + 2, op_pos - bpos - 2)];
					NSString *right = [buffer substringWithRange:NSMakeRange(op_pos + 1, end - op_pos - 1)];
					
					int compare = [left compare:right]; // $$ assuming this is the 
					switch(operation) {
						case '=' :					// character by character equality
							[buffer replaceCharactersInRange:NSMakeRange(bpos, 1) withString: ((compare ==  NSOrderedSame) ? @"1" : @"0")];
							break;
						case '<' :
							[buffer replaceCharactersInRange:NSMakeRange(bpos, 1) withString: ((compare < NSOrderedAscending) ? @"1" : @"0")];
							break;
						case '>' :
							[buffer replaceCharactersInRange:NSMakeRange(bpos, 1) withString: ((compare > NSOrderedDescending) ? @"1" : @"0")];
							break;
						default :
							[buffer replaceCharactersInRange:NSMakeRange(bpos, 1) withString:@"1"];
							LLLog(@"MTMTDistress.parseTests Bad operation %c", operation);
					}
					[self deleteCharsFromBuffer:buffer start:(bpos+1) end: (end - 1)]; // was end - 1
				}
					break;
				default :
					LLLog(@"MTMTDistress.parseTests Bad character %c", [buffer characterAtIndex:(bpos + 1)]);
					// remove the bad tokens
					[self deleteCharsFromBuffer:buffer start:bpos end: (bpos+1)];
					break;
			}
		}
	}	
}

/** parseConditionals */
- (void) parseConditionals:(NSMutableString *)buffer {
	
	for(int bpos = 1; bpos < [buffer length] - 1;) {
		if([buffer characterAtIndex:bpos] == '%' && [buffer characterAtIndex:bpos + 1] == '{') {
			char c = [buffer characterAtIndex:bpos - 1];
			if(c == '0' || c == '1') {
				[self deleteCharsFromBuffer:buffer start:(bpos - 1) end: (bpos + 1)];
				bpos = [self evaluateConditionalBlockStartingAt:(bpos - 1) inBuffer:buffer include:(c == '1')];
				continue;
			}
		} 
		++bpos;		
	}
}


/** evaluateConditionalBlock */
-  (int) evaluateConditionalBlockStartingAt:(int) bpos inBuffer:(NSMutableString *)buffer include: (bool) include {
	
	int remove_start = bpos;
	NSString *temp, *temp2;
	while(bpos < [buffer length] - 1) {
		temp = [buffer substringFromIndex:bpos];
		temp2 = [buffer substringFromIndex:remove_start];
		if([buffer characterAtIndex:bpos] == '%') {
			switch([buffer characterAtIndex:bpos + 1]) {
				case '}' :					// done with this conditional, return
					if(!include) {
						[self deleteCharsFromBuffer:buffer start:remove_start end: (bpos + 1)];
						return remove_start;
					}
					[self deleteCharsFromBuffer:buffer start:bpos end: (bpos+1)];
					return bpos;
				case '{' :					// handle new conditional
					if(include) {
						char c = [buffer characterAtIndex:bpos - 1];
						if(c == '0' || c == '1') {
							[self deleteCharsFromBuffer:buffer start:(bpos - 1) end: (bpos + 1)];
							// $$$ wauw recursion
							bpos = [self evaluateConditionalBlockStartingAt:bpos - 1 inBuffer:buffer include:c == '1'];
							continue;
						}
					}
					bpos += 2;
					break;
				case '!' :					// handle not indicator
					if(include) {
						remove_start = bpos;
						++bpos;
					}
					else {
						[self deleteCharsFromBuffer:buffer start:remove_start end: (bpos + 1)];
						bpos = remove_start;
					}
					include = !include;
					break;
				default :
					++bpos;
			}
		}
		else {
			++bpos;
		}
	}
	if(!include) {
		[self deleteCharsFromBuffer:buffer start:remove_start end: ([buffer length] - 1)];
	}
	
	return [buffer length];	
}

/** parseRemaining */
- (void) parseRemaining:(NSMutableString *)buffer {
	for(int bpos = 0; bpos < [buffer length]; ++bpos) {
		if([buffer characterAtIndex:bpos] == '%') {
			[buffer deleteCharactersInRange:NSMakeRange(bpos, 1)];
		}
	}
}



@end
