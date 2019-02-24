//
//  LLScreenResolution.h
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 11/03/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LLObject.h"

// use this to define mode e.g.
//
// const struct screenMode screenModeList[] = {
//	{ 640, 480, 8 },		/* 640 x 480,  8 bits per pixel */
//	{ 832, 624, 16 },		/* 832 x 624, 16 bits per pixel */
//	{ 1120, 832, 32 },		/* 1120 x 832, 32 bits per pixel */
// };


struct screenMode {
    size_t width;
    size_t height;
    size_t bitsPerPixel;
};

@interface LLScreenResolution : LLObject {

}

+ (LLScreenResolution*) defaultScreenResolution;
- (NSRect) frameForPrimairyDisplay;
- (struct screenMode) screenModeOnPrimairyDisplay;
- (void) setPrimairyDisplayToMode: (struct screenMode) mode;

@end
