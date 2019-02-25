//
//  MetaServerTableDataSource.m
//  MacTrek
//
//  Created by Aqua on 26/05/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "MetaServerTableDataSource.h"


@implementation MetaServerTableDataSource

- (id) init {
    self = [super init];
    if (self != nil) {
        selectedServer = nil;
        meta = [[MetaServerParser alloc] init];
		metaServerServers = [[NSMutableArray alloc] init];
		bonjourServers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)awakeFromNib {
	
	availableServices = nil;
	 
	rendezvousController = [[LLRendezvousController alloc] initWithName:@"MacTrek" type:@"_netrek._tcp." port:2592];
	[rendezvousController setDelegate:self];
	[rendezvousController activateBrowsing:YES];
	[rendezvousController activatePublishing:YES];	 
	
	// try again in 1 second
	[rendezvousController performSelector:@selector(refreshBrowsing) withObject:nil afterDelay:1.0];
	
	// initial query is in seperate thread		
	[NSThread detachNewThreadSelector:@selector(refreshServersInSeperateThread:) toTarget:self withObject:nil];
	//[self refreshServers:self];
	// try again in 1 second
	//[self performSelector:@selector(refreshServers:) withObject:self afterDelay:1.0];
}

- (void)discoveredServicesDidChange:(id)sender {
	[availableServices autorelease];
	availableServices = [[rendezvousController discoveredServicesWithInfo] retain];
	
	// clean up
	[bonjourServers removeAllObjects];
	
	unsigned int i, count = [availableServices count];
	for (i = 0; i < count; i++) {
		NSDictionary *dict = [availableServices objectAtIndex:i];
		
		// get data
		NSString *name = [dict objectForKey:@"name"];
		int port = [[dict objectForKey:@"port"] intValue];		
		NSNetService *service = [dict objectForKey:@"service"];
		NSString *ip = [service hostName]; //[dict objectForKey:@"ip"];
		
		LLLog(@"MetaServerTableDataSource.discoveredServicesDidChange adding service: %@ name: %@ at: %@:%d", 
			  service, name, ip, port);
		
		// we are called twice (once through localhost, and once through network adaptor, list only one
		if ([self findServer:ip] == nil) {
			// create a new entry
			MetaServerEntry *entry = [[MetaServerEntry alloc] init];
			[entry setAddress: ip];
			[entry setPort:    2592];  // use fixed ports
			[entry setStatus:  RENDEZVOUS];
			[entry setGameType:    BRONCO];	
			
			[bonjourServers insertObject:entry atIndex:0];  
		}
 		
	}
	
	// and reload
    dispatch_async(dispatch_get_main_queue(), ^{
        [serverTableView reloadData];
    });
	
}

- (void) refreshServersInSeperateThread:(id)sender {
    // technically this should be done with locks since
    // it can be invoked from init and by user if he is very very fast...
	
    // create a private pool for this thread
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    LLLog(@"MetaServerTableDataSource.refreshServersInSeperateThread: start running");
    [self refreshServers:self];
    LLLog(@"MetaServerTableDataSource.refreshServersInSeperateThread: complete");
    
    //[notificationCenter postNotificationName:@"MS_SERVERS_READ"];
    
    // release the pool
    [pool release];
}

- (IBAction)refreshServers:(id)sender {  

	LLLog(@"MetaServerTableDataSource.refreshServers");
	
	NSMutableArray *result, *result2;
	@try {
		result  = [meta readFromMetaServer:@"sage.real-time.com" atPort:3521];
	}
	@catch (NSException * e) {
		LLLog(@"MetaServerTableDataSource.refreshServers (sage.realtime.com): error %@", [e reason]);
		return; 
	}
	@try {
		result2 = [meta readFromMetaServer:@"metaserver.netrek.org" atPort:3521];
	}
	@catch (NSException * e) {
		LLLog(@"MetaServerTableDataSource.refreshServers (metaserver.netrek.org): error %@", [e reason]);
		return; 
	}
	// small protection allows for initial empty array, so when tehre is no internet,
	// you can still play on the local server.
	if (result != nil) {
		[metaServerServers release];
		metaServerServers = result;
		[metaServerServers retain];
        
#if 0 // Bug 2846441
		// check for localhost before releaseing
		MetaServerEntry *localhost = [self findServer:@"localhost"];
		if (localhost != nil) {
			LLLog(@"MetaServerTableDataSource.refreshServers: keeping localhost");
			[self addServerPassivly:localhost];
		}
#endif
	}
	
	// add the new server in result2 to metaServerServers
	for (int i=0; i < [result2 count]; i++) {
		MetaServerEntry *entry = [result2 objectAtIndex:i];
		if ([self findServer:[entry address]]) {
			// server already there
			//LLLog(@"MetaServerTableDataSource.refreshServers: duplicate entry for %@", [entry address]);
		} else {
			// new, must add
			LLLog(@"MetaServerTableDataSource.refreshServers: new entry for %@", [entry address]);
			[metaServerServers addObject:entry];
		}			
	}
	
	// rendezvous too
	[rendezvousController activateBrowsing:YES];
	[rendezvousController activatePublishing:YES];
	[rendezvousController refreshBrowsing];
	
	// show it
    dispatch_async(dispatch_get_main_queue(), ^{
        [serverTableView reloadData];
    });
    //[serverTableView reloadData];
}

- (void) addRendezVousServerToArray:(NSMutableArray*) result {
	[result addObjectsFromArray:bonjourServers];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
    if (serverTableView == aTableView) {
        return ([metaServerServers count] + [bonjourServers count]);
    }
    return 0;
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex {
    
	// create temp array with both
	NSMutableArray *entries = [NSMutableArray arrayWithArray:bonjourServers];
	[entries addObjectsFromArray:metaServerServers];
	
    if (serverTableView == aTableView) {
        MetaServerEntry *entry = [entries objectAtIndex:rowIndex];
        
        if ([[aTableColumn identifier] isEqualTo: @"address"]) {
            return [entry address];
        } else if ([[aTableColumn identifier] isEqualTo: @"status"]) {
            return [entry statusString];
        } else if ([[aTableColumn identifier] isEqualTo: @"players"]) {
			if ([entry status] == WAIT) { // 1718734	 support for wait queus
				return @"FULL";
			} else {
				return [NSString stringWithFormat:@"%d", [entry players]];
			}
        } else if ([[aTableColumn identifier] isEqualTo: @"game"]) {
            return [entry gameTypeString];
        } else {
            return @"ERROR"; // unknown column
        }
    }
    return @"ERROR";
}

- (MetaServerEntry *) selectedServer {
    return selectedServer;
}

- (void) setServerSelected:(MetaServerEntry *) server {

    LLLog(@"MetaServerTableDataSource.setServerSelected called, selecting %@", [server address]);
    [selectedServer release];
    selectedServer = server;
    [selectedServer retain];
    
    [notificationCenter postNotificationName:@"MS_SERVER_SELECTED" object:self userInfo:selectedServer];
}


// delegate functions
- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex {
    
	// create temp array with both
	NSMutableArray *entries = [NSMutableArray arrayWithArray:bonjourServers];
	[entries addObjectsFromArray:metaServerServers];
	
    // we abuse shouldSelectRow since it is a delegate function and not
    // a notification. (simpler)
    
    // update the selected server
    if (aTableView == serverTableView) {
        MetaServerEntry *entry = [entries objectAtIndex:rowIndex]; 
        [self setServerSelected:entry];
    }
    
    return YES;
}

- (void) deselectServer {
    selectedServer = nil;
    [serverTableView deselectAll:self];
}

- (MetaServerEntry *) findServer:(NSString *)name {
	
	// create temp array with both
	NSMutableArray *entries = [NSMutableArray arrayWithArray:bonjourServers];
	[entries addObjectsFromArray:metaServerServers];
    
    for (int i = 0; i < [entries count]; i++) {
        MetaServerEntry *entry = [entries objectAtIndex:i];
        if ([[entry address] isEqualToString:name]) {
            return entry;
        }
    }
    return nil;    
}

- (void) addServerPassivly:(MetaServerEntry *) entry {
    [metaServerServers insertObject:entry atIndex:0];    
    [serverTableView reloadData];
}

- (void) addServer:(MetaServerEntry *) entry {
    [metaServerServers insertObject:entry atIndex:0];    
    [serverTableView reloadData];
    // and select it
    [self setServerSelected:entry];
}

- (void) removeServer:(NSString *)name {
    
    MetaServerEntry *entry = [self findServer:name];
    if (entry != nil) {
        [metaServerServers removeObject:entry];
        [serverTableView reloadData];
        if (entry == selectedServer) {
            [self deselectServer];
        }
    }
}

@end
