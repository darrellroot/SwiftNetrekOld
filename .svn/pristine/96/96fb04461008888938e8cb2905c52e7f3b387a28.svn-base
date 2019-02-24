//
//  Feature.m
//  MacTrek
//
//  Created by Aqua on 26/04/2006.
//  Copyright 2006 Luky Soft. See Licence.txt for licence details.
//

#import "Feature.h"


@implementation Feature

- (id) init {
    self = [super init];
    if (self != nil) {
        name = nil;
        type = 'r';
        desired_value = 0;
        send_with_rsa = NO;
        arg1 = 0;
        arg2 = 0;
    }
    return self;
}

- (id) initWithName:(NSString *)nam type:(char)t desiredValue:(int)val sendWithRSA:(bool) rsa {
    self = [self init];
    if (self != nil) {
        name = nam;
        type = t;
        desired_value = val;
        send_with_rsa = rsa;
        value = val;
    }
    return self;
}

- (int) value {
    return value;
}

- (NSString*)name {
    return name;
}

- (char) type {
    return type;
}

- (int) desiredValue {
    return desired_value;
}

-(void) setValue:(int)val {
    value = val;
}

- (int) arg1 {
    return arg1;
}

- (int) arg2 {
    return arg2;
}

-(void) setArg1:(int)a1 {
    arg1 = a1;
}

-(void) setArg2:(int)a2 {
    arg2 = a2;
}

- (bool) sendWithRSA {
    return send_with_rsa;
}

@end
