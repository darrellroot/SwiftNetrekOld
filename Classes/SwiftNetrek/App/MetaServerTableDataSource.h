//
//  MetaServerTableDataSource.h
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import <Cocoa/Cocoa.h>
#import "BaseClass.h"
#import "MetaServerParser.h"

@interface MetaServerTableDataSource : BaseClass {
	
    // must be tied to the tableview in question
    IBOutlet NSTableView *serverTableView;
    
    // internal data
    MetaServerParser *meta;
    
    // selected entry
    MetaServerEntry *selectedServer;
	NSNetServiceBrowser *serviceBrowser;
	LLRendezvousController *rendezvousController;
	NSMutableArray *bonjourServers;
	NSMutableArray *metaServerServers;
	NSArray *availableServices;
}

- (IBAction)refreshServers:(id)sender;
- (void) refreshServersInSeperateThread:(id)sender;
- (MetaServerEntry *) selectedServer;
- (void) removeServer:(NSString *)name;
- (void) addServer:(MetaServerEntry *) entry;
- (void) addServerPassivly:(MetaServerEntry *) entry;
- (MetaServerEntry *) findServer:(NSString *)name;
- (void) deselectServer;
- (void) setServerSelected:(MetaServerEntry *) server;
- (void) addRendezVousServerToArray:(NSMutableArray*) result;

// rendezvous delegate functions
/*
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing;
*/
@end
