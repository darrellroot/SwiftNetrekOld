//
//  LoginManager.h
//  MacTrek
//
//  Created by Aqua on 19/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"

#define LOGIN_GETNAME			0
#define LOGIN_GETPASS			1
#define LOGIN_MAKEPASS1			2
#define LOGIN_MAKEPASS2			3
#define LOGIN_GUEST_LOGIN		4
#define LOGIN_BADMATCH			5
#define LOGIN_BADPASS			6
#define LOGIN_AUTOLOGIN_NAME	7
#define LOGIN_AUTOLOGIN_PASS	8
#define LOGIN_COMPLETE          9

@interface LoginManager : BaseClass {

    NSString *name;
    NSString *pass;
    int      state;
}

- (void) setName:(NSString *)loginName;
- (void) setPassword:(NSString *)loginPassword;
- (void) reset;
- (int) state;
- (void) autoLogin:(NSDictionary *)data;

@end
