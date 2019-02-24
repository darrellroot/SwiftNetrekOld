//
//  MTDistressKeyMap.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 08/03/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "MTDistressKeyMap.h"


@implementation MTDistressKeyMap

- (void) fillWithDefaults {
    MTKeyMapEntry *entry;
    
	// help 
    entry = [[MTKeyMapEntry alloc] initAction: DC_HELP3 
									  withKey:'E' 
								modifierFlags: NSControlKeyMask 
								  description: @"Help me!"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];	
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_RCM 
									  withKey:'e' 
								modifierFlags: NSControlKeyMask 
								  description: @"Help me! (detailed)"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];	
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_DOING3
									  withKey:'F' 
								modifierFlags: NSControlKeyMask 
								  description: @"General status report"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	// my actions
	entry = [[MTKeyMapEntry alloc] initAction: DC_TAKE 
									  withKey:'t' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am taking planet x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_ESCORTING 
									  withKey:'r' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am escorting player x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_OGGING
									  withKey:'o' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am ogging player x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_BOMBING 
									  withKey:'b' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am bombing planet x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_ASBOMB 
									  withKey:'a' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am about to bomb planet x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_CONTROLLING 
									  withKey:'s' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am controlling space near planet x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_ASW 
									  withKey:'p' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am protecting planet x from bombers"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_CARRYING 
									  withKey:'c' 
								modifierFlags: NSControlKeyMask 
								  description: @"I am carrying x armies"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	// my info
	entry = [[MTKeyMapEntry alloc] initAction: DC_FREE_BEER 
									  withKey:'f' 
								modifierFlags: NSControlKeyMask 
								  description: @"Player x is an easy kill"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_NO_GAS 
									  withKey:'n' 
								modifierFlags: NSControlKeyMask 
								  description: @"Player x is low on fuel"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_CRIPPLED 
									  withKey:'h' 
								modifierFlags: NSControlKeyMask 
								  description: @"Player x is crippled"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_PICKUP 
									  withKey:'x' 
								modifierFlags: NSControlKeyMask 
								  description: @"Player x has picked up armies"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_POP 
									  withKey:'i' 
								modifierFlags: NSControlKeyMask 
								  description: @"Planet y has armies"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	// commands		
	entry = [[MTKeyMapEntry alloc] initAction: DC_BOMB 
									  withKey:'1' 
								modifierFlags: NSControlKeyMask 
								  description: @"We shoud bomb planet x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_SPACE_CONTROL 
									  withKey:'2' 
								modifierFlags: NSControlKeyMask 
								  description: @"We shoud control space near x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_BASE_OGG 
									  withKey:'3' 
								modifierFlags: NSControlKeyMask 
								  description: @"We shoud ogg base x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
	
	entry = [[MTKeyMapEntry alloc] initAction: DC_OGG 
									  withKey:'4' 
								modifierFlags: NSControlKeyMask 
								  description: @"We shoud ogg player x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];

	
	entry = [[MTKeyMapEntry alloc] initAction: DC_SAVE_PLANET 
									  withKey:'5' 
								modifierFlags: NSControlKeyMask 
								  description: @"We shoud save planet x"];
    [keyMap setObject:entry forKey:[NSNumber numberWithInt:[entry action]]];
}

- (id) init {
    self = [super init];
    if (self != nil) {
		// we use a different file
		[pathToKeyMap release];
        NSString *pathToResources = [[NSBundle mainBundle] resourcePath];
        pathToKeyMap = [NSString stringWithFormat:@"%@/distressmap.xml", pathToResources];
        [pathToKeyMap retain];
    }
	
    return self;
}

@end
