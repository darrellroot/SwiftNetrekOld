//
//  DemoClientController.h
//  MacTrek
//
//  Created by Aqua on 27/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "MetaServerEntry.h"
#import "JTrekController.h"
#import "BaseClass.h"


@interface DemoClientController : BaseClass {
    MetaServerEntry  *selectedServer;
    JTrekController  *jtrek;
}

- (void) setServer:(MetaServerEntry *) server;
- (IBAction)play:(id)sender;

@end
