//
//  ScreenColor.m
//  Antumbra
//
//  Created by Nick Peretti on 8/13/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "ScreenColor.h"

NSString * const kScreenDidFinishProcessingNotification = @"ScreenDidProcessNotification";

@implementation ScreenColor{
    float screenWidth;
    float screenHeight;
}



-(void)loadUpDimmensions{
    screenWidth = [NSScreen mainScreen].frame.size.width;
    screenHeight = [NSScreen mainScreen].frame.size.height;
}
+(float)width{
    return [NSScreen mainScreen].frame.size.width;
}
+(float)height{
    return [NSScreen mainScreen].frame.size.height;
}


+(void)colorFromRect:(NSRect)rect{
    
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, rect);
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    
    
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    
    
    [pic addTarget:average];
    
    
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        
        NSColor *color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];
        [[NSNotificationCenter defaultCenter]postNotificationName:kScreenDidFinishProcessingNotification object:color userInfo:nil];
        
    }];
    
    
    [pic processImage];
    
    CFRelease(first);
  
}
+(void)augmentColorFromRect:(NSRect)rect{

    
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, rect);
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    
    GPUImageSaturationFilter *sat = [[GPUImageSaturationFilter alloc]init];
    sat.saturation = 2.0;
    
    
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    
    
    [pic addTarget:sat];
    
    [sat addTarget:average];
    
    
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        
        NSColor *color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];
       [[NSNotificationCenter defaultCenter]postNotificationName:kScreenDidFinishProcessingNotification object:color userInfo:nil];
        
    }];
    
    
    [pic processImage];

    CFRelease(first);
    
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
