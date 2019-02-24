//
//  LLColorFilter.m
//  MacTrek
//
//  Created by Aqua on 15/08/2006.
//  Copyright 2006 Luky Soft. LGPL Licence.
//

#import "LLColorFilter.h"


@implementation LLColorFilter


- (int)pixelForColor:(NSColor *)srcColor {
    
    NSColor* srcCol = [srcColor colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
   
    // components
    char srcRed   = (char) rint([srcCol redComponent] * 255);
    char srcGreen = (char) rint([srcCol greenComponent] * 255);
    char srcBlue  = (char) rint([srcCol blueComponent] * 255);
    char srcAlpha = (char) rint([srcCol alphaComponent] * 255);
    
    int color =   ((srcRed << 24) & 0xFF000000);
    color    |= ((srcGreen << 16) & 0x00FF0000);
    color    |=  ((srcBlue <<  8) & 0x0000FF00); 
    color    |= ((srcAlpha <<  0) & 0x000000FF); 
    
    return color;
}

- (NSImage *)replaceColor:(NSColor *)srcColor withColor:(NSColor *)dstColor 
                  inImage:(NSImage *)srcImage ignoreAlha:(bool)ignoreAlpha {
    
    NSBitmapImageRep *srcImageRep = [NSBitmapImageRep 
			imageRepWithData:[srcImage TIFFRepresentation]];
    
    //[srcImageRep setAlpha:YES];
    
    // check if source is ok    
    if ([srcImageRep bitsPerSample] != 8) {
	    LLLog(@"LLColorFilter.replaceColor src has incompatible colordepth %d", [srcImageRep bitsPerSample]);
	    return nil;
    }
    if (([srcImageRep samplesPerPixel] != 3) && ([srcImageRep samplesPerPixel] != 4)) { 
	    LLLog(@"LLColorFilter.replaceColor src has incompatible samples per pixel %d", [srcImageRep samplesPerPixel]);
	    return nil;
    }
    if ([srcImageRep isPlanar]) {
	    LLLog(@"LLColorFilter.replaceColor src has incompatible planes");
	    return nil;
    }
    if ([srcImageRep hasAlpha]) {
	    LLLog(@"LLColorFilter.replaceColor src has no alpha");
	    return nil;
    }
    if (sizeof(int) != 4) {
	    LLLog(@"LLColorFilter.replaceColor platform error, int is not 4 bytes");
	    return nil;
    }
    
    int w = [srcImageRep pixelsWide];
    int h = [srcImageRep pixelsHigh];
    int x, y;
    NSImage *destImage = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    
    NSBitmapImageRep *destImageRep = [[[NSBitmapImageRep alloc] 
				    initWithBitmapDataPlanes:NULL
                                  pixelsWide:w 
                                  pixelsHigh:h 
                               bitsPerSample:8 
                             samplesPerPixel:4
                                    hasAlpha:YES
                                    isPlanar:NO
                              colorSpaceName:NSCalibratedRGBColorSpace
                                 bytesPerRow:0 
                                bitsPerPixel:0] autorelease];
       
    unsigned char *srcData = [srcImageRep bitmapData];
    unsigned char *dstData = [destImageRep bitmapData];
    unsigned int  *p1, *p2;  // point to entire pixels
    
    int srcCol = [self pixelForColor:srcColor];
    int dstCol = [self pixelForColor:dstColor];
    
    int mask = 0xFFFFFFFF;     // everything is interesing
    if ((ignoreAlpha) || ([srcImageRep samplesPerPixel] == 3)) {
	    mask = 0xFFFFFF00; // except the alpha channel
	    srcCol &= mask;
    }
    
    for ( y = 0; y < h; y++ ) {
        for ( x = 0; x < w; x++ ) {
                 
            // tiny bug, the last byte will be read outside the buffer...
            // when there is no alpha channel (3 bytes vs int)
            p1 = (unsigned int *)srcData;
            p2 = (unsigned int *)dstData;
            
            if (((*p1) & mask) == srcCol) {
                // match found
                (*p2) = dstCol;
                
                if (!ignoreAlpha) {
                    // keep exising alpha channel value
                    int alpha = 0x000000FF & (*p1);
                    (*p2) |= alpha;
	            }
            } else  {
                // keep color
                *p2 = *p1;
            } 
            
            srcData += [srcImageRep samplesPerPixel]; // move to next pixel
            dstData += 4; // always 4
        }
    }
	
    [destImage addRepresentation:destImageRep];
    return destImage;
    
}

- (NSImage *)grayScaleImage:(NSImage *)srcImage {
    
    NSBitmapImageRep *srcImageRep = [NSBitmapImageRep 
			imageRepWithData:[srcImage TIFFRepresentation]];
    
    int w = [srcImageRep pixelsWide];
    int h = [srcImageRep pixelsHigh];
    int x, y;
    NSImage *destImage = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
    
    NSBitmapImageRep *destImageRep = [[[NSBitmapImageRep alloc] 
				    initWithBitmapDataPlanes:NULL
                                  pixelsWide:w 
                                  pixelsHigh:h 
                               bitsPerSample:8 
                             samplesPerPixel:1
                                    hasAlpha:NO
                                    isPlanar:NO
                              colorSpaceName:NSCalibratedWhiteColorSpace
                                 bytesPerRow:0 
                                bitsPerPixel:0] autorelease];
    
    unsigned char *srcData = [srcImageRep bitmapData];
    unsigned char *destData = [destImageRep bitmapData];
    unsigned char *p1, *p2;
    
    for ( y = 0; y < h; y++ ) {
        for ( x = 0; x < w; x++ ) {
            p1 = srcData + 3 * (y * w + x);       
            p2 = destData + y * w + x;
            
            *p2 = (char)rint((*p1 + *(p1 + 1) + *(p1 + 2)) / 3);
        }
    }
	
    [destImage addRepresentation:destImageRep];
    return destImage;
}

@end
