//
//  LLSystemInformation.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 14/12/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import <Cocoa/Cocoa.h>

// requires carbon and the iokit
// shamelessly stolen from http://www.cocoadev.com/index.pl?HowToGetHardwareAndNetworkInfo

@interface LLSystemInformation : NSObject {

}
	
//all the info at once!
+ (NSDictionary *)miniSystemProfile;

+ (NSString *)machineType;
+ (NSString *)humanMachineType;
//+ (NSString *)humanMachineTypeAlternate;

+ (long)processorClockSpeed;
+ (long)processorClockSpeedInMHz;
+ (unsigned int)countProcessors;
+ (BOOL) isPowerPC;
+ (BOOL) isG3;
+ (BOOL) isG4;
+ (BOOL) isG5;
+ (NSString *)powerPCTypeString;

+ (NSString *)computerName;
//+ (NSString *)computerSerialNumber;

+ (NSString *)operatingSystemString;
+ (NSString *)systemVersionString;

@end
