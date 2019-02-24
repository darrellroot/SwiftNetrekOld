//
//  MTMacro.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 26/02/2007.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MTMacro.h"


@implementation MTMacro

// name should be something like mac.b.T meaning macro when pressed b send to Team
// macros should be something like @"Help!  Carrying %a!!"
//  or something as crazy as: @"(%S+%a) %?%f<30%{ LOW%!%} fuel(%f%%) %?%s<30%{ POOR%!%}%?%s<80%{ Shds(%s%%) %!%}%?%d>60%{ BAD%!%}%?%d>10%{ DMG(%d%%) %!%}%?%E=1%{ ETEMPED %!%?%e>60%{ Etmp(%e%%) %!%}%}%?%W=1%{ WTEMPED %!%?%w>80%{ Wtmp(%w%%) %!%}%}"
- (id) initWithName:(NSString*)name macro:(NSString*)newMacro {
	self = [super init];
	if (self != nil) {
		
		macro = newMacro;
		
		int bpos  = 0;
		const char *buffer = [[name substringFromIndex:4] UTF8String];
		int length = [name length] - 4;
		
		// determine what key is supposed to be pressed to activate the macro
		if(buffer[0] == '?') {
			LLLog(@"MTMacro.initWithName: cannot use '?' for a macro");
			return nil;
		}
		else if(length >= 2 && buffer[0] == '^' && buffer[1] != '.') {
			key = (char)(buffer[1] + 128);
			bpos += 2;
		}
		else {
			key = buffer[0];
			bpos += 1;
		}
		
		// find who the macro is supposed to goto, and what type it is
		if(length > (bpos + 1) && buffer[bpos] == '.') {
			++bpos;
			if(length > (bpos + 1) && buffer[bpos] == '%') {
				switch(buffer[bpos + 1]) {
					case 'u' :
					case 'U' :
					case 'p' :
						who = MACRO_PLAYER;
						break;
					case 't':
					case 'z':
					case 'Z':
						who = MACRO_TEAM;
						break;
					case 'g':
						who = MACRO_FRIEND;
						break;
					case 'h':
						who = MACRO_ENEMY;
						break;
					default:
						who = MACRO_ME;
						break;
				}
				type = MACRO_NEWMOUSE;
			}			
			else {
				who = buffer[bpos];
				type = MACRO_NEWMSPEC;
			}
		}
		else {
			who = '\0';
			type = MACRO_NEWM;
		}
	}
	return self;
}

- (NSString*) keyAsString {
	
	NSMutableString *buffer = [NSMutableString stringWithFormat:@""];
	// $$ hmm, MacTrek enforces the use of CNTR so no need to check on it
	// will be false always
	/*
	 if(key > 128) {
		[buffer appendString:[NSString stringWithFormat:@"^%c", (key - 128)]];
	}
	else { */
		[buffer appendString:[NSString stringWithFormat:@"%c", key]];
	//}
	if(type != MACRO_NEWM) {
		[buffer appendString:@"."];
		if(type == MACRO_NEWMSPEC) {
			[buffer appendString:[NSString stringWithFormat:@"%c", who]];
		}
		else if (type == MACRO_NEWMOUSE) {
			[buffer appendString:@"%%"];
			char c;
			switch(who) {
				case MACRO_PLAYER :
					c = 'u';
					break;
				case MACRO_TEAM :
					c = 't';
					break;
				case MACRO_FRIEND :
					c = 'g';
					break;
				case MACRO_ENEMY :
					c = 'h';
					break;
				default:
					c = 'i';
			}
			[buffer appendString:[NSString stringWithFormat:@"%c", c]];
		}
	}
	return buffer;
} 

- (int) type {
	return type;
}

- (char) key {
	return key;
}

- (char) who {
	return who;
}

- (NSString*) whoLongFormat {
	
	if        (who == 'T') {
		return [[[[universe playerThatIsMe] team] abbreviation] uppercaseString];
	} else if (who == 'A') {
		return @"ALL";
	} else if (who == 'F') {
		return @"FED";
	} else if (who == 'K') {
		return @"KLI";
	} else if (who == 'O') {
		return @"ORI";
	} else if (who == 'R') {
		return @"ROM";
	} else if (who == 'G') {
		return @"GOD";
	} else {
		// it must be a player [F|O|R|K][0..f]
		// find out the player id
		char playerId = who;
		if (playerId >= '0' && playerId <= '9') {
			playerId -= '0';
		} else if (playerId >= 'a' && playerId <= 'k'){ // WAS f but i see more players !!!!!
			playerId -= 'a';
			playerId += 10;
		} else {
			LLLog(@"MTMacro.whoLongFormat Unknown player %@", who);
			return nil;  
		}
		// append a space
		return [NSString stringWithFormat:@"%@ ", [[universe playerWithId:playerId] mapChars]];		
	}
}

-(NSString *)macroString {
	return macro;
}

@end
