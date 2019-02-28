//
//  MTFontInstaller.m
//  MacTrek
//
//  Created by Chris & Judith Lukassen on 23/05/2007.
//  Copyright 2007 Luky Soft. All rights reserved.
//

#import "MTFontInstaller.h"


@implementation MTFontInstaller

- (bool) fileIsPresent:(NSString*)fileWithPath {	
	NSFileManager *fm = [NSFileManager defaultManager];
	return [fm fileExistsAtPath:fileWithPath];
}

- (bool) fontIsPresent {
	NSString *pathToFonts = @"/usr/local/lib";
	NSString *pathToMyFont = [NSString stringWithFormat:@"%@/Trek Regular", pathToFonts];
	return [self fileIsPresent:pathToMyFont];
}

@end
