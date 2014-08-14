//
//  ScreenColor.m
//  Antumbra
//
//  Created by Nick Peretti on 8/13/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "ScreenColor.h"

@implementation ScreenColor{
    float screenWidth;
    float screenHeight;
}



-(void)screenCaptureTick{
    screenWidth = [NSScreen mainScreen].frame.size.width;
    screenHeight = [NSScreen mainScreen].frame.size.height;
    
    
}



+(NSColor *)colorFromRect:(NSRect)rect{
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, rect);
    
    NSImage *mage = [[NSImage alloc]initWithCGImage:first size:NSMakeSize(rect.size.width, rect.size.height)];
    [mage setScalesWhenResized:YES];
    
    NSImage *smallImage = [[NSImage alloc] initWithSize: NSMakeSize(1, 1)] ;
    [smallImage lockFocus];
    [mage setSize: NSMakeSize(1, 1)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationMedium];
    [mage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, 1, 1) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    
    NSRect rec = NSMakeRect(0, 0, smallImage.size.width, smallImage.size.height);
    CGImageRef ref = [smallImage CGImageForProposedRect:&rec context:nil hints:nil];
    NSBitmapImageRep *map = [[NSBitmapImageRep alloc]initWithCGImage:ref];
    NSColor *color = [map colorAtX:0 y:0];
    CFRelease(first);
    return color;
    
}

+(NSColor *)highlightColorFromRect:(NSRect)rect{
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, rect);
    
    NSImage *mage = [[NSImage alloc]initWithCGImage:first size:NSMakeSize(rect.size.width, rect.size.height)];
    [mage setScalesWhenResized:YES];
    
    NSImage *smallImage = [[NSImage alloc] initWithSize: NSMakeSize(3, 3)] ;
    [smallImage lockFocus];
    [mage setSize: NSMakeSize(3, 3)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationMedium];
    [mage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, 3, 3) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    
    NSRect rec = NSMakeRect(0, 0, smallImage.size.width, smallImage.size.height);
    CGImageRef ref = [smallImage CGImageForProposedRect:&rec context:nil hints:nil];
    NSBitmapImageRep *map = [[NSBitmapImageRep alloc]initWithCGImage:ref];
    NSColor *min = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
    
    for (int y = 0; y<map.size.height; y++) {
        for (int x = 0; x<map.size.width; x++) {
            NSColor *newCol = [map colorAtX:x y:y];
            if ((newCol.redComponent+newCol.greenComponent+newCol.blueComponent)>(min.redComponent+min.greenComponent+min.blueComponent)) {
                min=newCol;
            }
        }
    }
    
    
    CFRelease(first);
    return min;
    
    
    
    
}

-(NSArray *)pointsFromWidth:(float)w height:(float)h widthDivs:(int)wDivs heightDivs:(int)hDivs{
    float widthAdd = w/wDivs;
    float hiteAdd = h/hDivs;
    NSMutableArray *points = [[NSMutableArray alloc]init];
    for (float y = hiteAdd; y<h; y+=hiteAdd) {
        for (float x = widthAdd; x<w; x+=widthAdd) {
            [points addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
        }
    }
    return [points copy];
    
}

@end
