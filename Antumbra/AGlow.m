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
    AnLightInfo inf;
    
    
    NSTimer *sweepTimer;
}
@synthesize device;
@synthesize context;
@synthesize sweepSpeed;
@synthesize isMirroring, smoothFactor;
@synthesize isFading;

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
        context = con;
        sweepSpeed = 0.2;
        isMirroring = false;
        isFading = false;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(colorProcessFinishedNotification:) name:kScreenDidFinishProcessingNotification object:nil];
        
        tick=0;
        on = false;
        AnLight_Info_S(context, device, &inf);
        red = 0;
        green = 0;
        blue = 0;
        
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
        
        [self fadeToColor:[NSColor whiteColor] inTime:1.0];

    }
    return self;
}

-(void)fadeToColor:(NSColor *)col inTime:(NSTimeInterval)time{
    col =  [col colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    int numSteps = 50;
    NSTimeInterval stepTime = time/numSteps;
    int newRed = (floorf(col.redComponent*65535.0)-red)/numSteps;
    int newGreen = (floorf(col.greenComponent*65535.0)-green)/numSteps;
    int newBlue = (floorf(col.blueComponent*65535.0)-blue)/numSteps;
    
    for (int i = 0; i<numSteps; i++) {
        red = red+newRed;
        blue = blue+newBlue;
        green = green+newGreen;
        [self updateBoard];
        [NSThread sleepForTimeInterval:stepTime];
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


-(void)augmentScreenTick{
    [self augmentColorFromRect:samplingRect];
}


-(void)screenCaptureTick{
    [self colorFromRect:samplingRect];
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
    isMirroring = false;
    isFading = false;
    NSColor *currentColor = [[NSColorPanel sharedColorPanel] color];
    red = floor(currentColor.redComponent*65535.0);
    green = floor(currentColor.greenComponent*65535.0);
    blue = floor(currentColor.blueComponent*65535.0);
    [self updateBoard];
}


-(void)setColor:(NSColor *)newColor{
    CGFloat r,g,b;
    newColor = [newColor colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    [newColor getRed:&r green:&g blue:&b alpha:NULL];
    red = floorf(r*65535.0);
    green = floorf(g*65535.0);
    blue = floorf(b*65535.0);
    [self updateBoard];
    
}

-(void)updateBoard{
    if (isMirroring) {
        currentRed = (red*smoothFactor)+(currentRed*(1.0-smoothFactor));
        currentBlue = (blue*smoothFactor)+(currentBlue*(1.0-smoothFactor));
        currentGreen = (green*smoothFactor)+(currentGreen*(1.0-smoothFactor));
        
       
        AnLight_Set_S(context, device, &inf, (uint16_t)currentRed, (uint16_t)currentGreen, (uint16_t)currentBlue);
        
    }else{
       
        
        AnLight_Set_S(context, device, &inf, (uint16_t)red, (uint16_t)green, (uint16_t)blue);
    }
}



-(void)colorProcessFinishedNotification:(NSNotification *)notification{
    NSColor *color = [notification object];
    color =  [color colorUsingColorSpace:[NSColorSpace genericRGBColorSpace]];
    red = floor(color.redComponent*65535.0);
    green = floor(color.greenComponent*65535.0);
    blue = floor(color.blueComponent*65535.0);
    [self updateBoard];
}

-(void)augment{
    
    [sweepTimer invalidate];
    currentRed = red;
    currentGreen = green;
    currentBlue = blue;
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(augmentScreenTick) userInfo:nil repeats:YES];
    isMirroring = true;
    isFading = false;
}
-(void)mirror{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/30.0 target:self selector:@selector(screenCaptureTick) userInfo:nil repeats:YES];
    isMirroring = true;
    isFading = false;
    
}
-(void)sweep{
    [sweepTimer invalidate];
    sweepTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(fastSweep) userInfo:nil repeats:YES];
    isMirroring = false;
    isFading = true;
}
-(void)stopUpdates{
    isMirroring = false;
    isFading = false;
     [sweepTimer invalidate];
}



-(void)colorFromRect:(NSRect)rect{
    
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, rect);
    
    
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    
    
    [pic addTarget:average];
    
    
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        
        red = floor(r*65535.0);
        green = floor(g*65535.0);
        blue = floor(b*65535.0);
        
        /*
        float outH,outS,outV;
        
        rgb2hsv(red, green, blue, &outH, &outS, &outV);
        
        outS = outS * 1.2 > 1.0 ? 1.0 : outS * 1.5;
        
        uint8_t oR,oG,oB;
        
        hsv2rgb(outH, outS, outV, &oR, &oG, &oB);
        
        red = oR;
        green = oG;
        blue = oB;
        */
        
        [self updateBoard];
        
    }];
    
    
    [pic processImage];
    
    CFRelease(first);
    
}

-(void)augmentColorFromRect:(NSRect)rect{
    
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, rect);
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    
    GPUImageSaturationFilter *sat = [[GPUImageSaturationFilter alloc]init];
    sat.saturation = 2.0;
    
    
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    
    
    [pic addTarget:sat];
    
    [sat addTarget:average];
    
    
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        
        red = floor(r*65535.0);
        green = floor(g*65535.0);
        blue = floor(b*65535.0);
        [self updateBoard];
        
    }];
    
    
    [pic processImage];
    
    CFRelease(first);
    
}





@end
