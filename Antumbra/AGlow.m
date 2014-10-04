//
//  AGlow.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/22/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "AGlow.h"


@implementation AGlow{

    
    float red;
    float green;
    float blue;
    
    
    float currentRed;
    float currentGreen;
    float currentBlue;
    
    int tick;
    
    
    NSWindow *mirrorAreaWindow;
    CGRect samplingRect;
    
    BOOL on;
    
    
    NSTimer *sweepTimer;
}
@synthesize device;
@synthesize context;
@synthesize sweepSpeed;

-(id)initWithAntumbraDevice:(AnDevice *)dev andContext:(AnCtx *)con{
    self = [super init];
    if (self) {
        device = dev;
        context = con;
        sweepSpeed = 0.2;
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(colorProcessFinishedNotification:) name:kScreenDidFinishProcessingNotification object:nil];
        
        tick=0;
        on = YES;
        
        red = 255;
        green = 255;
        blue = 255;
        
        samplingRect = CGRectMake([ScreenColor width]*0.2, [ScreenColor height]*0.2, [ScreenColor width]*0.6, [ScreenColor height]*0.6);
        mirrorAreaWindow = [[NSWindow alloc]initWithContentRect:NSMakeRect([ScreenColor width]*0.2, [ScreenColor height]*0.2, [ScreenColor width]*0.6, [ScreenColor height]*0.6) styleMask:NSTitledWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
        mirrorAreaWindow.backgroundColor = [NSColor colorWithCalibratedRed:0.083 green:0.449 blue:0.618 alpha:0.690];
        mirrorAreaWindow.minSize = NSMakeSize(200, 200);
        mirrorAreaWindow.title = @"Resize to the area you want to grab colors from";
        [mirrorAreaWindow setOpaque:NO];
        [mirrorAreaWindow setAlphaValue:0.75];
        [mirrorAreaWindow setShowsResizeIndicator:YES];
        [mirrorAreaWindow.contentView setAutoresizesSubviews:YES];
        NSButton *setButton = [[NSButton alloc]initWithFrame:NSMakeRect(mirrorAreaWindow.frame.size.width/2.0-100, mirrorAreaWindow.frame.size.height/2.0+32, 200, 64)];
        [setButton setAction:@selector(mirrorAreaSelected)];
        [setButton setBezelStyle:NSRoundedBezelStyle];
        [setButton setTitle:@"Save"];
        [setButton setAlphaValue:1.0];
        [setButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        [mirrorAreaWindow.contentView addSubview:setButton];
        
        [self updateBoard];

    }
    return self;
}




-(void)mirrorAreaSelected{
    samplingRect = CGRectMake(mirrorAreaWindow.frame.origin.x, mirrorAreaWindow.frame.origin.y, mirrorAreaWindow.frame.size.width, mirrorAreaWindow.frame.size.height);
    [mirrorAreaWindow setIsVisible:NO];
}


-(void)augmentScreenTick{
    [ScreenColor augmentColorFromRect:samplingRect];
    
}


-(void)screenCaptureTick{
    [ScreenColor colorFromRect:samplingRect];
    
}


-(void)fastSweep{
    uint8_t reed;
    uint8_t bluee;
    uint8_t greeen;
    hsv2rgb((tick*sweepSpeed)+(tick*0.01), 1.0, 1.0, &reed, &greeen, &bluee);
    red = reed;
    green = greeen;
    blue = bluee;
    tick++;
    [self updateBoard];
}



-(void)changeColor:(id)sender{
    [sweepTimer invalidate];
    NSColor *currentColor = [[NSColorPanel sharedColorPanel] color];
    red = floor(currentColor.redComponent*255.0);
    green = floor(currentColor.greenComponent*255.0);
    blue = floor(currentColor.blueComponent*255.0);
    [self updateBoard];
}

-(void)updateBoard{
    
    AnDevice_SetRGB_S(context, device, (uint8_t)red,(uint8_t)green,(uint8_t)blue);
    
}



-(void)colorProcessFinishedNotification:(NSNotification *)notification{
    NSColor *color = [notification object];
    red = floor(color.redComponent*255.0);
    green = floor(color.greenComponent*255.0);
    blue = floor(color.blueComponent*255.0);
    [self updateBoard];
}

-(void)augment{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/50.0 target:self selector:@selector(augmentScreenTick) userInfo:nil repeats:YES];
    
}
-(void)mirror{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/50.0 target:self selector:@selector(screenCaptureTick) userInfo:nil repeats:YES];
    
}
-(void)sweep{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(fastSweep) userInfo:nil repeats:YES];
}




@end
