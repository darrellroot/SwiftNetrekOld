//
//  ServerControllerNew.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 14/12/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "ServerControllerNew.h"


@implementation ServerControllerNew

- (id) init {
	self = [super init];
	if (self != nil) {
		NSString *cpuType;
		
		// see what we are
		if ([LLSystemInformation isPowerPC]) {
			cpuType = @"PPC";
		} else {
			cpuType = @"INTEL";
		}
		
		LLLog(@"ServerControllerNew.init selecting %@", cpuType);
		
		pathToResources = [[[NSBundle mainBundle] resourcePath] retain];
		pathToExe = [[NSString stringWithFormat:@"%@/PRECOMPILED/%@/lib", pathToResources, cpuType] retain];
		pathToServer = [[NSString stringWithFormat:@"%@/newstartd", pathToExe] retain];
        //pathToPid = [[NSString stringWithFormat:@"%@/PRECOMPILED/%@/var/netrek.pid", pathToResources] retain];
	}
	return self;
}

- (void)restartServer {
	[self stopServer];
	[self startServer];
}

- (void)startServer {
        
	NSTask *server = [[NSTask alloc] init];
	
	[server setCurrentDirectoryPath:pathToExe];
	[server setLaunchPath:pathToServer];
	[server launch];	
	LLLog(@"ServerControllerNew.startServer launched %@", pathToServer);
	/* 1691205 1.2.0RC1 sometimes hangs during launch
	[server waitUntilExit];
	[server release]; */
}

- (void)stopServer {
    
	NSTask *server = [[NSTask alloc] init];
	
	[server setCurrentDirectoryPath:pathToExe];
	[server setLaunchPath:pathToServer];
	[server setArguments:[NSArray arrayWithObjects:@"stop", nil]];
	[server launch];
	[server waitUntilExit];
	[server release];
	
	// make sure we kill the bots
	server = [[NSTask alloc] init];
	[server setLaunchPath:@"/usr/bin/killall"];
	[server setArguments:[NSArray arrayWithObjects:@"robot", nil]];
	[server launch];
	[server waitUntilExit];
	[server release];
	
	// and the server
	server = [[NSTask alloc] init];
	[server setLaunchPath:@"/usr/bin/killall"];
	[server setArguments:[NSArray arrayWithObjects:@"newstartd", nil]];
	[server launch];
	[server waitUntilExit];
	[server release];
    
    // remove the pid file BUG 1780013
    //[[NSFileManager defaultManager] removeItemAtPath:pathToPid error:NULL];

}

@end
