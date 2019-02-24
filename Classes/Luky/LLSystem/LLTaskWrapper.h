/*
 File:		LLTaskWrapper.h

 Description: 	This class is a generalized process handling class that makes asynchronous interaction with an NSTask easier.  There is also a protocol designed to work in conjunction with the LLTaskWrapper class; your process controller should conform to this protocol.  LLTaskWrapper objects are one-shot (since NSTask is one-shot); if you need to run a task more than once, destroy/create new LLTaskWrapper objects.

 Author:		EP & MCF

 Copyright: 	© Copyright 2002 Apple Computer, Inc. LGPL Licence.

 Disclaimer:	IMPORTANT:  This Apple software is supplied to you by Apple Computer, Inc.
 ("Apple") in consideration of your agreement to the following terms, and your
 use, installation, modification or redistribution of this Apple software
 constitutes acceptance of these terms.  If you do not agree with these terms,
 please do not use, install, modify or redistribute this Apple software.

 In consideration of your agreement to abide by the following terms, and subject
 to these terms, Apple grants you a personal, non-exclusive license, under Apple’s
 copyrights in this original Apple software (the "Apple Software"), to use,
 reproduce, modify and redistribute the Apple Software, with or without
 modifications, in source and/or binary forms; provided that if you redistribute
 the Apple Software in its entirety and without modifications, you must retain
 this notice and the following text and disclaimers in all such redistributions of
 the Apple Software.  Neither the name, trademarks, service marks or logos of
 Apple Computer, Inc. may be used to endorse or promote products derived from the
 Apple Software without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or implied,
 are granted by Apple herein, including but not limited to any patent rights that
 may be infringed by your derivative works or by other works in which the Apple
 Software may be incorporated.

 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
 WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
 WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
 COMBINATION WITH YOUR PRODUCTS.

 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
                        GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR DISTRIBUTION
 OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF CONTRACT, TORT
 (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN
 ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */


#import <Foundation/Foundation.h>
#import "LLObject.h"

@protocol LLTaskWrapperController

// Your controller's implementation of this method will be called when output arrives from the NSTask.
// Output will come from both stdout and stderr, per the LLTaskWrapper implementation.
- (void)appendOutput:(NSString *)output fromTask:(id) task;

// This method is a callback which your controller can use to do other initialization when a process
// is launched.
- (void)processStarted:(id)task;

// This method is a callback which your controller can use to do other cleanup when a process
// is halted.
- (void)processFinished:(id)task;

@end

@interface LLTaskWrapper : LLObject {
    NSTask 			*task;
    id				<LLTaskWrapperController>controller;
    NSArray			*arguments;
}

// This is the designated initializer - pass in your controller and any task arguments.
// The first argument should be the path to the executable to launch with the NSTask.
- (id)initWithController:(id <LLTaskWrapperController>)controller arguments:(NSArray *)args;

// This method launches the process, setting up asynchronous feedback notifications.
- (void) startProcess;

// This method stops the process, stoping asynchronous feedback notifications.
- (void) stopProcess;

@end

