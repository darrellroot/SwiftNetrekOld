//
//  SelectServerController.h
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "MetaServerTableDataSource.h"
#import "MetaServerTableDataSource.h"

@interface SelectServerController : MetaServerTableDataSource {
    IBOutlet NSTextField               *serverNameTextField;
    IBOutlet NSButton                  *loginButton;
    IBOutlet NSButton                  *refreshButton;
	IBOutlet NSProgressIndicator       *spinner;
    // the Back button is covered by the menu controller
}

- (void) setServerSelected:(MetaServerEntry *) server;
- (void) deselectServer:(id)sender;
- (void) disableLogin;
- (void) enableLogin;
- (void) invalidServer;
@end
