//
//  AppDelegate.m
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "AppDelegate.h"
#import "ScreenColor.h"
#import "MenuViewController.h"
#import "AXStatusItemPopup.h"


#define maxDifference = 5;

@implementation AppDelegate {
    float red;
    float green;
    float blue;
    
    
    int tick;
    
    NSWindow *mirrorAreaWindow;
    CGRect samplingRect;
    
    BOOL on;

    
    NSTimer *sweepTimer;
    
    AnDevice *dev;
    AnCtx *context;
    
    AXStatusItemPopup *_statusItemPopup;
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    MenuViewController *contentViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:nil];
    
    // create icon images shown in statusbar
    NSImage *image = [NSImage imageNamed:@"icon"];
    NSImage *alternateImage = [NSImage imageNamed:@"iconGrey"];
    
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:alternateImage];
    
    contentViewController.statusItemPopup = _statusItemPopup;
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(colorProcessFinishedNotification:) name:kScreenDidFinishProcessingNotification object:nil];
    
    tick=0;
    on = YES;
    
    red = 255;
    green = 255;
    blue = 255;
    
    samplingRect = CGRectMake([ScreenColor width]*0.1, [ScreenColor height]*0.1, [ScreenColor width]*0.8, [ScreenColor height]*0.8);
    mirrorAreaWindow = [[NSWindow alloc]initWithContentRect:NSMakeRect([ScreenColor width]*0.1, [ScreenColor height]*0.1, [ScreenColor width]*0.8, [ScreenColor height]*0.8) styleMask:NSTitledWindowMask|NSResizableWindowMask backing:NSBackingStoreBuffered defer:NO];
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
    [self findAntumbra];
    
}


-(void)findAntumbra{
    
    
    if (AnCtx_Init(&context)) {
        fputs("ctx init failed\n", stderr);
    }
    AnDevice_Populate(context);
    
    int count  = AnDevice_GetCount(context);
    if (count == 0) {
        NSAlert *lert = [[NSAlert alloc]init];
        [lert setShowsSuppressionButton:YES];
        [lert setMessageText:@"No Antumbra detected. Please plug one in and then press OK."];
        //[lert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        //    [self findAntumbra];
        //}];
    } else{
        for (int i = 0; i < AnDevice_GetCount(context); ++i) {
            const char *ser;
            dev = AnDevice_Get(context, i);

            
            AnDevice_Info(dev, NULL, NULL, &ser);
            
            if (AnDevice_Open(context, dev)) {
                fputs("device open failed\n", stderr);
                
            }
            
        }
        [self updateBoard];
    }
    
}


- (IBAction)setMirrorArea:(id)sender {
    [mirrorAreaWindow setIsVisible:YES];
    [mirrorAreaWindow setFrame:mirrorAreaWindow.frame display:YES];
    [mirrorAreaWindow makeKeyAndOrderFront:self];
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
    hsv2rgb(tick*0.2, 1.0, 1.0, &reed, &greeen, &bluee);
    red = reed;
    green = greeen;
    blue = bluee;
    
    tick++;
    [self updateBoard];
}

-(void)slowSweep{
    uint8_t reed;
    uint8_t bluee;
    uint8_t greeen;
    hsv2rgb(tick*0.05, 1.0, 1.0, &reed, &greeen, &bluee);
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
    
    AnDevice_SetRGB_S(context, dev, (uint8_t)red,(uint8_t)green,(uint8_t)blue);
    
}



-(void)colorProcessFinishedNotification:(NSNotification *)notification{
    NSColor *color = [notification object];
    red = floor(color.redComponent*255.0);
    green = floor(color.greenComponent*255.0);
    blue = floor(color.blueComponent*255.0);
    [self updateBoard];
}


@end