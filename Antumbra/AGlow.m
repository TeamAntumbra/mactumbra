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
@synthesize isMirroring, smoothFactor;

typedef void * CGSConnection;
extern OSStatus CGSSetWindowBackgroundBlurRadius(CGSConnection connection, NSInteger   windowNumber, int radius);
extern CGSConnection CGSDefaultConnectionForThread();

- (void)enableBlurForWindow:(NSWindow *)window  withColor:(NSColor *)coler
{
    [window setOpaque:NO];
    window.backgroundColor = coler;
    
    CGSConnection connection = CGSDefaultConnectionForThread();
    CGSSetWindowBackgroundBlurRadius(connection, [window windowNumber], 20);
}

-(id)initWithAntumbraDevice:(AnDevice *)dev andContext:(AnCtx *)con{
    self = [super init];
    if (self) {
        device = dev;
        context = con;
        sweepSpeed = 0.2;
        isMirroring = false;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(colorProcessFinishedNotification:) name:kScreenDidFinishProcessingNotification object:nil];
        
        tick=0;
        on = YES;
        
        red = 255;
        green = 255;
        blue = 255;
        
        smoothFactor = 0.9;
        
        currentBlue = blue;
        currentRed = red;
        currentGreen = green;
        
        samplingRect = CGRectMake([ScreenColor width]*0.2, [ScreenColor height]*0.2, [ScreenColor width]*0.6, [ScreenColor height]*0.6);
        mirrorAreaWindow = [[NSWindow alloc]initWithContentRect:NSMakeRect([ScreenColor width]*0.2, [ScreenColor height]*0.2, [ScreenColor width]*0.6, [ScreenColor height]*0.6) styleMask:NSTitledWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
        mirrorAreaWindow.backgroundColor = [NSColor whiteColor];
        mirrorAreaWindow.minSize = NSMakeSize(200, 200);
        mirrorAreaWindow.title = @"Resize to the area you want this glow to grab colors from";
        [mirrorAreaWindow setOpaque:NO];
        [mirrorAreaWindow setAlphaValue:0.75];
        [mirrorAreaWindow setShowsResizeIndicator:YES];
        [mirrorAreaWindow.contentView setAutoresizesSubviews:YES];
        NSButton *setButton = [[NSButton alloc]initWithFrame:NSMakeRect(mirrorAreaWindow.frame.size.width/2.0-50, mirrorAreaWindow.frame.size.height/2.0+32, 100, 64)];
        [setButton setAction:@selector(mirrorAreaSelected)];
        [setButton setTarget:self];
        [setButton setBezelStyle:NSRoundedBezelStyle];
        [setButton setTitle:@"Save"];
        [setButton setAlphaValue:1.0];
        [setButton setAutoresizingMask:NSViewMinXMargin | NSViewMaxXMargin | NSViewMinYMargin | NSViewMaxYMargin];
        [mirrorAreaWindow.contentView addSubview:setButton];
        
        [self enableBlurForWindow:mirrorAreaWindow withColor:[NSColor colorWithCalibratedRed:0.757 green:0.967 blue:1.000 alpha:0.490]];
        [self updateBoard];

    }
    return self;
}

-(void)openWindow{
    
    [self enableBlurForWindow:mirrorAreaWindow withColor:[NSColor colorWithCalibratedRed:0.185 green:0.210 blue:1.000 alpha:0.500]];
    [mirrorAreaWindow setIsVisible:YES];
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


-(void)setColor:(NSColor *)newColor{
    CGFloat r,g,b;
    [newColor getRed:&r green:&g blue:&b alpha:NULL];
    red = floorf(r*255.0);
    green = floorf(g*255.0);
    blue = floorf(b*255.0);
    [self updateBoard];
    
}

-(void)updateBoard{
    if (isMirroring) {
        currentRed = (red*smoothFactor)+(currentRed*(1.0-smoothFactor));
        currentBlue = (blue*smoothFactor)+(currentBlue*(1.0-smoothFactor));
        currentGreen = (green*smoothFactor)+(currentGreen*(1.0-smoothFactor));
        AnDevice_SetRGB_S(context, device, (uint8_t)currentRed,(uint8_t)currentGreen,(uint8_t)currentBlue);
    }else{
        AnDevice_SetRGB_S(context, device, (uint8_t)red,(uint8_t)green,(uint8_t)blue);
    }
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
    currentRed = red;
    currentGreen = green;
    currentBlue = blue;
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(augmentScreenTick) userInfo:nil repeats:YES];
    isMirroring = true;
}
-(void)mirror{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(screenCaptureTick) userInfo:nil repeats:YES];
    isMirroring = true;
    
}
-(void)sweep{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(fastSweep) userInfo:nil repeats:YES];
    isMirroring = false;
}
-(void)stopUpdates{
    isMirroring = false;
     [sweepTimer invalidate];
}



@end
