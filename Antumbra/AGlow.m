//
//  AGlow.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/22/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "AGlow.h"


@implementation AGlow{
    CGRect samplingRect;
    AnLightInfo inf;
    NSTimer *sweepTimer;
    
}
@synthesize device;
@synthesize context;
@synthesize smoothFactor;
@synthesize currentColor;
@synthesize mirrorAreaWindow;
@synthesize maxBrightness;

typedef void * CGSConnection;
extern OSStatus CGSSetWindowBackgroundBlurRadius(CGSConnection connection, NSInteger   windowNumber, int radius);
extern CGSConnection CGSDefaultConnectionForThread();

- (void)enableBlurForWindow:(NSWindow *)window  withColor:(NSColor *)coler
{
    [window setOpaque:YES];
    window.backgroundColor = coler;
    CGSConnection connection = CGSDefaultConnectionForThread();
    CGSSetWindowBackgroundBlurRadius(connection, [window windowNumber], 20);
}

-(id)initWithAntumbraDevice:(AnDevice *)dev andContext:(AnCtx *)con{
    self = [super init];
    if (self) {
        device = dev;
        maxBrightness = 1.0;
        context = con;
        AnLight_Info_S(context, device, &inf);
        smoothFactor = 0.9;
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
        self.currentColor = [NSColor colorWithCalibratedRed:0.011 green:0.010 blue:0.011 alpha:1.000];
        [self fadeToColor:[NSColor whiteColor] inTime:1.0];
    }
    return self;
}

-(void)fadeToColor:(NSColor *)col inTime:(NSTimeInterval)time{
    col =  [col colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    float numSteps = 60.0;
    NSTimeInterval stepTime = time/numSteps;
    
    float currentRed = currentColor.redComponent;
    float currentGreen = currentColor.greenComponent;
    float currentBlue = currentColor.blueComponent;
    
    float toRed = col.redComponent;
    float toGreen = col.greenComponent;
    float toBlue = col.blueComponent;
    
    float redStep = (toRed-currentRed)/numSteps;
    float greenStep = (toGreen-currentGreen)/numSteps;
    float blueStep = (toBlue-currentBlue)/numSteps;
    
    
    for (int i = 0; i<numSteps; i++) {
        currentRed = currentRed+redStep;
        currentGreen = currentGreen+greenStep;
        currentBlue = currentBlue+blueStep;
        self.currentColor = [NSColor colorWithCalibratedRed:currentRed green:currentGreen blue:currentBlue alpha:1.0];
        [self sendColor:self.currentColor smooth:NO];
        [NSThread sleepForTimeInterval:stepTime];
    }
    
}
-(void)updateSetColor:(NSColor *)color smooth:(BOOL)s{
    self.currentColor = color;
    [self sendColor:color smooth:s];
}

-(void)sendColor:(NSColor*)color smooth:(BOOL)sm{
    float red = color.redComponent;
    float green = color.greenComponent;
    float blue = color.blueComponent;
    if (!sm) {
        AnLight_Set_S(context, device, &inf, (uint16_t)((red*65535.0)*maxBrightness), (uint16_t)((green*65535.0)*maxBrightness), (uint16_t)((blue*65535.0)*maxBrightness));
    }else{
        float currentRed = (currentColor.redComponent*smoothFactor)+(red*(1-smoothFactor));
        float currentGreen = (currentColor.greenComponent*smoothFactor)+(green*(1-smoothFactor));
        float currentBlue = (currentColor.blueComponent*smoothFactor)+(blue*(1-smoothFactor));
        AnLight_Set_S(context, device, &inf, (uint16_t)((currentRed*65535.0)*maxBrightness), (uint16_t)((green*65535.0)*maxBrightness), (uint16_t)((blue*65535.0)*maxBrightness));
        currentColor = [NSColor colorWithCalibratedRed:currentRed green:currentGreen blue:currentBlue alpha:1.0];
    }
}

-(void)openWindow{
    [self enableBlurForWindow:mirrorAreaWindow withColor:[NSColor colorWithCalibratedRed:0.185 green:0.210 blue:1.000 alpha:0.500]];
    [mirrorAreaWindow setIsVisible:YES];
}


-(void)mirrorAreaSelected{
    samplingRect = CGRectMake(mirrorAreaWindow.frame.origin.x, mirrorAreaWindow.frame.origin.y, mirrorAreaWindow.frame.size.width, mirrorAreaWindow.frame.size.height);
    [mirrorAreaWindow setIsVisible:NO];
}



@end
