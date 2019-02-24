//
//  LLNetServiceDelegate.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 01/03/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Luky.h"


@interface LLNetServiceDelegate : LLObject {

}

// Availability notifications
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary *)errorDict;
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict; 
- (void)netServiceDidPublish:(NSNetService *)sender;
- (void)netServiceWillPublish:(NSNetService *)sender;  
// Resolving services
- (void)netServiceDidResolveAddress:(NSNetService *)sender;  
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data;
- (void)netServiceWillResolve:(NSNetService *)sender;
// Stopping services
- (void)netServiceDidStop:(NSNetService *)sender;

@end
