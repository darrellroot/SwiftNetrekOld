//
//  LLNotificationCenter.h
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>
#import "LLNotificationCenterEntry.h"
#import "LLDOSender.h"
#import "LLDOReceiver.h"
#import "LLObject.h"

// very simple notification centre, but also very fast
// allows any kind of payload, even a dictionairy

// to make thread safe call setUseLocks:YES (default off)
// to make thread safe for a single observer use the appropriate addObserver
// don't forget to set the lock timeout (default 2 seconds)

@interface LLNotificationCenter : LLObject {

    NSMutableDictionary *listeners;
    bool useLocks;
    int timeOut;
	LLNotificationCenter *defaultCenter;
	NSLock *synchronizeAccess;
	NSMutableDictionary *senders;
	LLDOReceiver *receiver;
	NSString *mainThreadID;
}

// must be called from the main event loop!
+ (LLNotificationCenter*) defaultCenter;

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName;       // nil means all

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName        // nil means all
             object:(NSString *)notificationSender;     // nil means of all

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName        // nil means all
             object:(NSString *)notificationSender      // nil means of all
           useLocks:(bool)protect;                      // set to YES for multi thread safe


- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName        // nil means all
             object:(NSString *)notificationSender      // nil means of all
           useLocks:(bool)protect                       // set to YES for multi thread safe
     useMainRunLoop:(bool)mainThread;                   // set to YES for excute in my (main) thread
                                                        // even when event occured elsewhere

- (void)removeObserver:(id)notificationObserver         // remove observer for event
                  name:(NSString *)notificationName;    // nil means all

- (void) postNotificationName:(NSString *)name object:(id) sender userInfo:(id)userInfo;
- (void) postNotificationName:(NSString *)name userInfo:(id)userInfo;
- (void) postNotificationName:(NSString *)name;

- (bool) useLocks;
- (void) setUseLocks:(bool)protect;

- (int)  timeOut;
- (void) setTimeOut:(int)interval;

- (void) setEnable:(bool)enable;

@end
