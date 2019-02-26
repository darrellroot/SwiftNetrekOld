//
//  LLNotificationCenter.m
//  MacTrek
//
//  Created by Aqua on 27/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLNotificationCenter.h"


@implementation LLNotificationCenter

LLNotificationCenter *defaultCenter;
NSLock *synchronizeAccess;
NSMutableDictionary *senders;
LLDOReceiver *receiver;
NSString *mainThreadID;
bool sendEvents = YES;

- (id) init {
    self = [super init];
    if (self != nil) {
        listeners = [[NSMutableDictionary alloc] init];
        useLocks = NO; // default off
        synchronizeAccess = [[NSLock alloc] init];
        timeOut = 2; // default wait 2 seconds
        
        // this is the main run loop so set up the DO
        receiver = [[LLDOReceiver alloc] init];
        // this will be called from a thread when an event was posted
        [receiver setTarget:self withSelector:@selector(remotelyPostedEvent:)];
        // this will store the senders
        senders = [[NSMutableDictionary alloc] init];
        // and this is the id of the main thread
        mainThreadID = [NSString stringWithFormat:@"%d", [NSThread currentThread]];
        [mainThreadID retain];
    }
    return self;
}

+ (LLNotificationCenter*) defaultCenter {
    if (defaultCenter == nil) {
        defaultCenter = [[LLNotificationCenter alloc] init];
    }
    return defaultCenter;
}

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName {
       
    [self addObserver:notificationObserver 
             selector:notificationSelector 
                 name:notificationName 
               object:nil 
             useLocks:NO
       useMainRunLoop:NO];
}

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName        // nil means all
             object:(NSString *)notificationSender {    // nil means of all
    
    [self addObserver:notificationObserver 
             selector:notificationSelector 
                 name:notificationName 
               object:notificationSender 
             useLocks:NO
       useMainRunLoop:NO];
}

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName        // nil means all
             object:(NSString *)notificationSender      // nil means of all
           useLocks:(bool)protect {
    [self addObserver:notificationObserver 
             selector:notificationSelector 
                 name:notificationName 
               object:notificationSender 
             useLocks:protect
       useMainRunLoop:NO];
}

- (void)addObserver:(id)notificationObserver            // cannot be nil
           selector:(SEL)notificationSelector           // cannot be nil
               name:(NSString *)notificationName        // nil means all
             object:(NSString *)notificationSender      // nil means of all
           useLocks:(bool)protect 
  useMainRunLoop:(bool)useMainLoop {                                                     
    LLLog(@"LLNotificationCenter.addObserver name");
    LLLog(notificationName);

    if (notificationObserver == nil) {
        LLLog(@"LLNotificationCenter.addObserver notificationObserver cannot be nil");
        return;
    } 
    if (notificationSelector == nil) {
        LLLog(@"LLNotificationCenter.addObserver notificationSelector cannot be nil");
        return;
    }
    // little optimalization, when using the mainloop it is thread safe anyway
    if (useMainLoop) {
        protect = NO; // no need for locks AND DO
    }
    
    // create a new entry
    LLNotificationCenterEntry *newListener = [[LLNotificationCenterEntry alloc] initWithNotificationName:notificationName
                                                                                                  source:notificationSender 
                                                                                                  target:notificationObserver
                                                                                                selector:notificationSelector
                                                                                                useLocks:protect
                                                                                             useMainLoop:useMainLoop];

    // see if anyone is listening
    NSMutableArray *listenersForThisKey = [listeners valueForKey:notificationName];
    if (listenersForThisKey == nil) {
        // first one ? create table
        listenersForThisKey = [[NSMutableArray alloc] init];
        [listeners setValue: listenersForThisKey forKey:notificationName];
    }
    
    // add us to these listeners
    [listenersForThisKey addObject:newListener];
    
    return;    
}    

- (void) remotelyPostedEvent:(LLNotificationCenterEntry *)listener {
    
    LLLog(@"LLNotificationCenter.remotelyPostedEvent %@", [listener name]);
    
    // get the parameters passed over the DO
    id target = [listener target];
    SEL selector = [listener selector];
    id userInfo = [listener userData];
    
    // invoke the selector (we are now in the main loop)
    [target performSelector:selector withObject:userInfo];
}

- (LLDOSender *) getSenderForMyThread {
    // create a new one for every event.... $$
    NSString *threadID = [NSString stringWithFormat:@"%d", [NSThread currentThread]]; 
    
    // for the main thread do nothing
    if ([threadID isEqualToString: mainThreadID]) {
        return nil;
    }
    
    LLDOSender *sender = [senders objectForKey:threadID];
    if (sender == nil) {
        // new thread? create a seperate sender
        LLLog(@"LLNotificationCenter.getSenderForMyThread creating sender for thread %d", threadID);
        sender = [[LLDOSender alloc] init];
        [senders setObject:sender forKey:threadID];
    }
    return sender;
}

- (void) setEnable:(bool)enable {
    sendEvents = enable;
}

- (void) postNotificationName:(NSString *)name object:(id) sender userInfo:(id)userInfo {
    
    if (!sendEvents) {
        return;
    }
    
    // debug print, very helpfull, but takes load
    //LLLog(@"LLNotificationCenter.postNotificationName %@", name);
    
    bool hasObserver = NO;
    
    if (name == nil) {
        LLLog(@"LLNotificationCenter.postNotification nil strings are no longer accepted");
        return;
    }
    
    NSMutableArray *listenersForThisKey = [listeners valueForKey:name];
    
    // now execute all listeners
    for (int i = 0; i < [listenersForThisKey count]; i++) {
        LLNotificationCenterEntry *listener = [listenersForThisKey objectAtIndex:i];
        
        // filter on source first
        if (([listener source] == sender) || ([listener source] == nil)) { // nil means all source
            hasObserver = YES;
            id target = [listener target];
            SEL selector = [listener selector];                    
            // check for the use of locks (protect multithreading)
            if (useLocks || [listener useLocks]) {
                // if we use locks, use a timeout
                if ([synchronizeAccess lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:timeOut]]) {
                    //[synchronizeAccess lock]; // lock was obtained, don't lock twice
                    [target performSelector:selector withObject:userInfo];       // invoke 
                    [synchronizeAccess unlock]; // but unlock                        
                } else {
                    LLLog(@"LLNotificationCenter.postNotificationName waited %d seconds for lock, discarding event");
                    return; // no lock obtained, so no need to unlock
                }
            } else {
                if ([listener useMainLoop]) {
                    // this event could have occured in a seperate thread as the main thread
                    // so we need to perform the execution over the DO
                    
                    // store the data
                    [listener setUserData:userInfo]; 
                    // get the sender
                    LLDOSender *sender = [self getSenderForMyThread];
                    // send the notification over the do
                    if (sender != nil) {
                        [sender invokeRemoteObjectWithUserData:listener];
                    } else { // try something
                        [target performSelector:selector withObject:userInfo];       // normal invoke
                    }                        
                    
                } else {
                    [target performSelector:selector withObject:userInfo];       // normal invoke 
                }                 
            }
        } 
    }
    if (!hasObserver) { // avoid this to speed up things
       LLLog(@"LLNotificationCenter.postNotificationName WARNING notification %@ has no observer", name);
    }
}

- (void)removeObserver:(id)notificationObserver        
                  name:(NSString *)notificationName {
    LLLog(@"LLNotificationCenter.removeObserver %@", notificationObserver); 
    
    int removed = 0;
    // go through entire dictionairy
    // not needed if notificationName != nil
    // but as that is usually the case, we better keep it simple
    unsigned int i, count = [[listeners allKeys] count];
    for (i = 0; i < count; i++) {
        
        // $$ hmm could do this outside the loop
        NSMutableArray *toBeRemovedListners = [[NSMutableArray alloc] init];   
        
        NSString *key = [[listeners allKeys] objectAtIndex:i];
        NSMutableArray *listenersForThisKey = [listeners objectForKey:key];
        
        // check for every key entry if we are the observer
        for (int i = 0; i < [listenersForThisKey count]; i++) {
            LLNotificationCenterEntry *listener = [listenersForThisKey objectAtIndex:i];        
            
            if ([listener target] == notificationObserver) {
                // found the right lister target
                if ([[listener name] isEqualToString:notificationName] ||
                    (notificationName == nil)) {
                    // notification name is ok
                    [toBeRemovedListners addObject:listener];              
                }
            }
        }
        
        // remove
        [listenersForThisKey removeObjectsInArray:toBeRemovedListners];
        removed += [toBeRemovedListners count];
        [toBeRemovedListners release];
        
        // check if any left, if none, remove index
        /* $$ can't since we the index would shift and that would 
              mean that the for loop would fail
        if ([listenersForThisKey count] == 0) {
            [listeners removeObjectForKey:key];
            [listenersForThisKey release];
        }
         */
    }   
    LLLog(@"LLNotificationCenter.removeObserver removed %d occurences", removed);
}

- (void) postNotificationName:(NSString *)name {
    [self postNotificationName:name object:self userInfo:nil];
}

- (void) postNotificationName:(NSString *)name userInfo:(id)userInfo {
    [self postNotificationName:name object:self userInfo:userInfo];
}

- (bool) useLocks {
    return useLocks;
}

- (void) setUseLocks:(bool)protect {
    useLocks = protect;
}

- (int)  timeOut {
    return timeOut;
}

- (void) setTimeOut:(int)interval {
    timeOut = interval;
}

@end
