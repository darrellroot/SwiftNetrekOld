//
//  ServerControllerNew.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 14/12/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

// new wrapper based on server inclusion in resources and not as seperate package

#import <Cocoa/Cocoa.h>
#import "ServerController.h"
#import "LLSystemInformation.h"

@interface ServerControllerNew : ServerController  {
	NSString *pathToResources;
	NSString *pathToExe;
    NSString *pathToServer;
    NSString *pathToPid;
}

- (void)restartServer;

@end
