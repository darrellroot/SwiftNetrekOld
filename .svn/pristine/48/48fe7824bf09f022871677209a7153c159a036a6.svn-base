//
//  LLRendezvousController.h
//
//  Created by Wolfgang Ante in June 2003.
//  Copyright (c) 2003 ARTIS Software. All rights reserved.
//  Published in MacTech Magazine. Feel free to use it in your software.
//

#import <Foundation/Foundation.h>

// interface of the rendezvous class
@interface LLRendezvousController : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
	NSNetService		*_service;
	NSString			*_serviceName;
	NSString			*_serviceType;
	BOOL				_browsing;
	BOOL				_publishing;
	
	NSNetServiceBrowser	*_serviceBrowser;
	NSNetServiceBrowser	*_domainBrowser;
	
	NSSocketPort		*_socketPort;
	int					_portNumber;
	
	NSMutableArray		*_discoveredServicesWithInfo;
	
	id					_delegate;
}

- (id)initWithName:(NSString *)name type:(NSString *)type port:(int)port;
- (void)dealloc;

- (id)delegate;
- (void)setDelegate:(id)object;
- (NSString *)name;
- (BOOL)setName:(NSString *)name;
- (NSSocketPort *)socket;

- (void)activateBrowsing:(BOOL)flag;
- (BOOL)isBrowsing;
- (void)refreshBrowsing;
- (void)activatePublishing:(BOOL)flag;
- (BOOL)isPublished;
- (NSArray *)discoveredServicesWithInfo;

- (NSString *)ipForName:(NSString *)name;
- (int)portForName:(NSString *)name;

@end

// to be implemented by the delegate
@interface NSObject (RendezvousControllerDelegate)

- (void)discoveredServicesDidChange:(id)sender;

@end
