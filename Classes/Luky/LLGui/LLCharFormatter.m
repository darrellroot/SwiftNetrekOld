//
//  LLCharFormatter.m
//  MacTrek
//
//  Created by Aqua on 21/04/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLCharFormatter.h"


@implementation LLCharFormatter

- (NSString *)stringForObjectValue:(id)anObject {
    return anObject;
}

- (BOOL)getObjectValue:(id *)anObject 
             forString:(NSString *)string 
      errorDescription:(NSString **)error {
    
    *anObject = [NSString stringWithString: string];
    error = nil;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString *)partialString 
            newEditingString:(NSString **)newString 
            errorDescription:(NSString **)error {
    *newString = nil;
    if ([partialString length] > 1) {
        *error = @"You can only press one character at the time";
        return NO;
    } else {
        return YES;
    }   
}


@end
