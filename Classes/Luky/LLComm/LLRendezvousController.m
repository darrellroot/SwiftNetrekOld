//
//  LLRendezvousController.h
//
//  Created by Wolfgang Ante in June 2003.
//  Copyright (c) 2003 ARTIS Software. All rights reserved.
//  Published in MacTech Magazine. Feel free to use it in your software.
//

#import "LLRendezvousController.h"

#include <netinet/in.h>
#include <arpa/inet.h>

@interface LLRendezvousController (LLRendezvousControllerInternal)

// creation
- (void)createSocket;
- (void)createBrowser;
- (void)createService;

// management
- (BOOL)addInfoService:(NSNetService *)service name:(NSString *)name ip:(NSString *)ip port:(int)port;
- (BOOL)removeInfoService:(NSNetService *)service;

// other
- (void)startBrowsing;

@end

@interface LLRendezvousController (NSNetServiceDelegation)

// publication
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
- (void)netServiceWillPublish:(NSNetService *)sender;
- (void)netServiceDidStop:(NSNetService *)sender;

// resolution
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict;
- (void)netServiceDidResolveAddress:(NSNetService *)sender;
- (void)netServiceWillResolve:(NSNetService *)sender;

@end

@interface LLRendezvousController (NSNetServiceBrowserDelegation)

// browsing
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing;
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing;
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser;
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser;

@end

@implementation LLRendezvousController

- (id)initWithName:(NSString *)name type:(NSString *)type port:(int)port
{
	self = [super init];
	if (self)
	{
		// store name, type and port for later
		[self setName:name];
		_serviceType = [type retain];
		_portNumber = port;
		
		// initialize array
		_discoveredServicesWithInfo = [[NSMutableArray alloc] init];
		
		// create the socket and the browser
		[self createSocket];
		[self createBrowser];
	}
	return self;
}

- (void)dealloc
{
	// clean up
	[self activatePublishing:NO];
	[_serviceBrowser stop];
	[_domainBrowser stop];
	[_socketPort release];
	[_discoveredServicesWithInfo release];
	[super dealloc];
}

- (id)delegate
{
	return _delegate;
}

- (void)setDelegate:(id)object
{
	// find if delegate supports the delegation message
	if (![object respondsToSelector:@selector(discoveredServicesDidChange:)])
		NSLog (@"Delegate does not respond to 'discoveredServicesDidChange:'!");
	
	_delegate = object;
}

- (NSString *)name
{
	return _serviceName;
}

- (BOOL)setName:(NSString *)name
{
	// change name only when not already published
	if (!_publishing)
	{
		[name retain];
		[_serviceName release];
		_serviceName = name;
		return YES;
	}
	else
	{
		NSLog (@"Cannot change name while service is published!");
		return NO;
	}
}

- (NSSocketPort *)socket
{
	return _socketPort;
}

- (void)activateBrowsing:(BOOL)flag
{
	// if requested and actual state match don't proceed
	if (flag == _browsing)
		return;
	
	if (flag)
	{
		// activate browsing
		_browsing = YES;
		[_serviceBrowser searchForServicesOfType:_serviceType inDomain:@""];
	}
	else
	{
		// deactivate browsing
		_browsing = NO;
		[_serviceBrowser stop];
		[_discoveredServicesWithInfo removeAllObjects];
		[_delegate discoveredServicesDidChange:self];		
	}
}

- (BOOL)isBrowsing
{
	return _browsing;
}

- (void)startBrowsing
{
	// should only be called when browsing off
	if (_browsing)
	{
		NSLog (@"Browing already started!");
		return;
	}
	
	// start browsing
	_browsing = YES;
	[_serviceBrowser searchForServicesOfType:_serviceType inDomain:@""];
}

- (void)refreshBrowsing
{
	// don't refresh if not browsing
	if (!_browsing)
		return;
	
	// start/stop (stop is deferred to the end of message queue)
	[self activateBrowsing:NO];
	[self performSelector:@selector(startBrowsing) withObject:nil afterDelay:0.0];
}

- (void)activatePublishing:(BOOL)flag
{
	// if already activated then don't do anything
	if (_publishing == flag)
		return;
	
	if (flag)
	{
		// activate service
	    [self createService];
	}
	else
	{
		// deactivate service
		[_service stop];
		_service = nil;
	}
	
	// set new state
	_publishing = flag;
}

- (BOOL)isPublished
{
	return _publishing;
}

- (NSArray *)discoveredServicesWithInfo
{
	// return (autoreleased) copy
	return [NSArray arrayWithArray:_discoveredServicesWithInfo];
}

- (NSString *)ipForName:(NSString *)name
{
	NSEnumerator	*e = nil;
	NSDictionary	*dict = nil;
	
	// find the corresponding ip to the given name
	e = [_discoveredServicesWithInfo objectEnumerator];
	while (dict = [e nextObject])
		if ([[dict objectForKey:@"name"] isEqualToString:name])
			return [dict objectForKey:@"ip"];
	
	// return nil when not found
	return nil;
}

- (int)portForName:(NSString *)name
{
	NSEnumerator	*e = nil;
	NSDictionary	*dict = nil;
	
	// find the corresponding ip to the given name
	e = [_discoveredServicesWithInfo objectEnumerator];
	while (dict = [e nextObject])
		if ([[dict objectForKey:@"name"] isEqualToString:name])
			return [[dict objectForKey:@"port"] intValue];
	
	// return 0 when not found
	return 0;
}

@end

#pragma mark -

@implementation LLRendezvousController (RendezvousControllerInternal)

- (void)createSocket
{
	// already there
	if (_socketPort)
		return;
	
	// look for free port
	while (!_socketPort)
	{
		_socketPort = [[NSSocketPort alloc] initWithTCPPort:_portNumber];
		_portNumber++;
	}
	_portNumber--;
}

- (void)createService
{
	// already there
	if (_service)
		return;
	
	// create service, make self the delegate and publish
	_service = [[NSNetService alloc] initWithDomain:@"" type:_serviceType name:_serviceName port:_portNumber];
	[_service setDelegate:self];
	[_service publish];
}

- (void)createBrowser
{
	// setup service browser
	if (!_serviceBrowser)
	{
		_serviceBrowser = [[NSNetServiceBrowser alloc] init];
		[_serviceBrowser setDelegate:self];
	}
}

- (BOOL)addInfoService:(NSNetService *)service name:(NSString *)name ip:(NSString *)ip port:(int)port
{
	NSMutableDictionary	*dict = nil;
	NSEnumerator		*e = nil;
	
	// if already there then don't add
	e = [_discoveredServicesWithInfo objectEnumerator];
	while (dict = [e nextObject])
		if ([[dict objectForKey:@"ip"] isEqualToString:ip])
			if ([[dict objectForKey:@"port"] intValue] == port)
				return NO;
	
	// add if not found in array
	dict = [NSMutableDictionary dictionary];
	[dict setObject:ip forKey:@"ip"];
	[dict setObject:[NSNumber numberWithInt:port] forKey:@"port"];
	[dict setObject:name forKey:@"name"];
	[dict setObject:service forKey:@"service"];
	[_discoveredServicesWithInfo addObject:dict];
	return YES;
}

- (BOOL)removeInfoService:(NSNetService *)service
{
	NSDictionary	*dict = nil;
	NSEnumerator	*e = nil;
	NSMutableArray	*delete = nil;
	
	// look for object with this service and mark for delete
	delete =[NSMutableArray array];
	e = [_discoveredServicesWithInfo objectEnumerator];
	while (dict = [e nextObject])
		if ([[dict objectForKey:@"service"] isEqual:service])
			[delete addObject:dict];
	
	// delete marked objects
	e = [delete objectEnumerator];
	while (dict = [e nextObject])
		[_discoveredServicesWithInfo removeObject:dict];
	
	return NO;
}

@end

#pragma mark -

@implementation LLRendezvousController (NSNetServiceDelegation)

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict
{
	// publishing failed
	_publishing = NO;
	NSLog (@"Publishing the service %@failed.", [sender name]);
	[_delegate discoveredServicesDidChange:self];
}

- (void)netServiceWillPublish:(NSNetService *)sender
{
	// does nothing for now, implemented for your possible additions
}

- (void)netServiceDidStop:(NSNetService *)sender
{
	// does nothing for now, implemented for your possible additions
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	// resolving failed
	NSLog (@"Resolving of address for service %@ failed.", [sender name]);
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSData				*address = nil;
	struct sockaddr_in	*socketAddress = nil;
	NSString			*ipString = nil;
	int					port, i;
	
	for (i = 0; i < [[sender addresses] count]; i++)
	{
		// gather data about this published service
		address = [[sender addresses] objectAtIndex:i];
		socketAddress = (struct sockaddr_in *)[address bytes];
		ipString = [NSString stringWithFormat: @"%s", inet_ntoa (socketAddress->sin_addr)];
		port = socketAddress->sin_port;
		
		// published localhost is a Rendezvous strangeness: ignore that!
		if ([ipString isEqualToString:@"127.0.0.1"])
			continue;
		
		// notify delegate of change
		if ([self addInfoService:sender name:[sender name] ip:ipString port:port])
			[_delegate discoveredServicesDidChange:self];
	}
}

- (void)netServiceWillResolve:(NSNetService *)sender
{
	// does nothing for now, implemented for your possible additions
}

@end

@implementation LLRendezvousController (NSNetServiceBrowserDelegation)

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser 
	    didFindService:(NSNetService *)aNetService 
	    moreComing:(BOOL)moreComing
{
    // add to dicovered services and resolve it
    [aNetService setDelegate:self];
	[aNetService resolveWithTimeout:5.0];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser 
	    didRemoveService:(NSNetService *)aNetService 
	    moreComing:(BOOL)moreComing
{
	// remove and notify
	[self removeInfoService:aNetService];
	[_delegate discoveredServicesDidChange:self];
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
	// empty the arrays and notify delegate
	if (aNetServiceBrowser == _serviceBrowser)
	{
		[_discoveredServicesWithInfo removeAllObjects];
		[_delegate discoveredServicesDidChange:self];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
	NSLog (@"Unable to search.");
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser
{
	// does nothing for now, implemented for your possible additions
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
	// does nothing for now, implemented for your possible additions
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
	// does nothing for now, implemented for your possible additions
}

@end
