//
//  LoginManager.m
//  MacTrek
//
//  Created by Aqua on 19/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "LoginManager.h"


@implementation LoginManager

bool serverReplyReceived = NO;

- (id) init {
    self = [super init];
    if (self != nil) {
        name  = nil;
        pass  = nil;
        state = LOGIN_GETNAME;
        
        // set up some hooks for server replies
        [notificationCenter addObserver:self selector:@selector(serverReportsInvalidServer:) 
                                   name:@"SP_LOGIN_INVALID_SERVER" object:nil];
        [notificationCenter addObserver:self selector:@selector(serverReportsLoginAccepted:) 
                                   name:@"SP_LOGIN_ACCEPTED" object:nil];
        [notificationCenter addObserver:self selector:@selector(serverReportsLoginDenied:) 
                                   name:@"SP_LOGIN_NOT_ACCEPTED" object:nil];      
		
		// auto login
		[notificationCenter addObserver:self selector:@selector(autoLogin:) 
                                   name:@"GM_SEND_LOGIN_REQ" object:nil]; 
    }
    return self;
}

-(int) state {
    return state;
}

//--
-(void) reset {
    state = LOGIN_GETNAME;
    LLLog(@"LoginManager.reset state %d", state);
}

// handle server reports
- (void) serverReportsInvalidServer: (id) me {
    [notificationCenter postNotificationName:@"LM_LOGIN_INVALID_SERVER" object:self userInfo:nil];
    state = LOGIN_GETNAME;
}

- (void) serverReportsLoginAccepted: (id) me {
    
    switch(state) {
		case LOGIN_GETNAME:
            state = LOGIN_GETPASS;
            if ([[name uppercaseString] isEqualToString:@"GUEST"]) {
                [self setPassword:nil];
            } else {                
                [notificationCenter postNotificationName:@"LM_LOGIN_GET_PASSWORD" object:self userInfo:nil];                     
            }
			break;
		case LOGIN_GETPASS:
        case LOGIN_MAKEPASS1:
		case LOGIN_MAKEPASS2: 
		case LOGIN_GUEST_LOGIN:
		case LOGIN_AUTOLOGIN_PASS:
            state = LOGIN_COMPLETE;
            [notificationCenter postNotificationName:@"LM_LOGIN_COMPLETE" object:self userInfo:nil];
			break;
        default:
            LLLog(@"LoginManager.serverReportsLoginAccepted state %d", state);
            break;
    }
}

- (void) serverReportsLoginDenied: (id) me {
    
    switch(state) {
		case LOGIN_GETNAME:         // name accepted, password not
            state = LOGIN_MAKEPASS1;
            [notificationCenter postNotificationName:@"LM_LOGIN_MAKE_PASSWORD" object:self userInfo:nil];
			break;
		case LOGIN_AUTOLOGIN_NAME:  // old code
			state = LOGIN_GETNAME;
			break;
		case LOGIN_GETPASS:         // deny, retry
		case LOGIN_MAKEPASS2: 
		case LOGIN_GUEST_LOGIN:
		case LOGIN_AUTOLOGIN_PASS:
			state = LOGIN_BADPASS;
            [notificationCenter postNotificationName:@"LM_LOGIN_BAD_PASSWORD" object:self userInfo:nil];
			break;
        default:
            LLLog(@"LoginManager.serverReportsLoginDenied state %d", state);
            break;
    }
    
}

// handle user requests
- (void) setName:(NSString *)loginName {
    
    if (state != LOGIN_GETNAME) {
        LLLog(@"LoginManager.setName strange ? did not expect state %d", state);
        state = LOGIN_GETNAME;
    }        
    
    // store this name
    [name release];
    name = loginName;
    [name retain];
    
    // send the name to the server
    bool checkName = YES;
    if ([name isEqualToString:@"Guest"] || [name isEqualToString:@"guest"]) {
        checkName = NO;
    }
    // ask if this is a valid name
    [notificationCenter postNotificationName:@"COMM_SEND_LOGIN_REQ" 
                                      object:nil 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys: 
                                        name, @"name",
                                        @"", @"pass", 
                                        NSUserName(), @"login", 
                                        [NSNumber numberWithInt:(checkName ? 1 : 0)], @"query",
                                        nil]];
}

- (void) autoLogin:(NSDictionary *)data {
	[self setName:[data objectForKey:@"name"]];
	if ([name isEqualToString:@"Guest"] || [name isEqualToString:@"guest"]) {
        // do nothing
    } else {
		[self setPassword:[data objectForKey:@"pass"]];	
	}	
}

- (void) setPassword:(NSString *)loginPassword {
    
    // store this password
    [pass release];
    pass = loginPassword;
    [pass retain];
    
    // ask if this is a valid name / password
    [notificationCenter postNotificationName:@"COMM_SEND_LOGIN_REQ" 
                                      object:nil 
                                    userInfo:[NSDictionary dictionaryWithObjectsAndKeys: 
                                        name, @"name",
                                        pass, @"pass", 
                                        NSUserName(), @"login", 
                                        (char) 0, @"query",
                                        nil]];
}


@end
