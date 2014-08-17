//
//  AppDelegate.m
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "AppDelegate.h"
#import "ScreenColor.h"



@implementation AppDelegate {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    
    int tick;
    
    NSWindow *mirrorAreaWindow;
    CGRect samplingRect;
    
    BOOL on;
    
    NSColorPanel *panel;
    
    NSTimer *sweepTimer;
    
    NSMutableArray *antumbras;
    AnDevice *dev;
    AnCtx *context;
    
    NSMutableArray *savedColorConfigurations;
}

@synthesize statusBar;;
@synthesize titleLabel;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    antumbras = [[NSMutableArray alloc]init];
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"A";
    [_window setTitle:@""];
    [_window makeKeyAndOrderFront:NSApp];
    self.statusMenu.delegate = self;
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    panel = [NSColorPanel sharedColorPanel];
    [panel setTarget:self];
    [panel setAction:@selector(changeColor:)];
    [panel setContinuous:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(colorProcessFinishedNotification:) name:kScreenDidFinishProcessingNotification object:nil];
    tick=0;
    on = YES;
    
    for (int i = 2; i<self.statusMenu.itemArray.count; i++) {
        NSMenuItem *currentItem = self.statusMenu.itemArray[i];
        [currentItem setTarget:self];
        [currentItem setAction:@selector(itemClicked:)];
    }
    
    red = 255;
    green = 0;
    blue = 0;
    
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
        [lert setMessageText:@"No antumbras found please plug in an antumra and then hit OK"];
        [lert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            [self findAntumbra];
        }];
    } else{
        for (int i = 0; i < AnDevice_GetCount(context); ++i) {
            const char *ser;
            dev = AnDevice_Get(context, i);

            
            AnDevice_Info(dev, NULL, NULL, &ser);
            
            if (AnDevice_Open(context, dev)) {
                fputs("device open failed\n", stderr);
                
            }
            //AnDevice_Close(ctx, dev);
            //AnDevice_Free(dev);
            //[antumbras addObject:(__bridge id)(dev)];
        }
        [self updateBoard];
    }
    
}


- (IBAction)toggleOnOff:(id)sender {
    on = !on;
    [self updateBoard];
}


- (IBAction)openSettings:(id)sender {
    [_window makeKeyAndOrderFront:sender];
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

- (void)itemClicked:(NSMenuItem *)item{
    tick = 0;
    [sweepTimer invalidate];
    for (int i = 2; i<self.statusMenu.itemArray.count; i++) {
        NSMenuItem *currentItem = self.statusMenu.itemArray[i];
        [currentItem setState:NSOffState];
    }
    [item setState:NSOnState];
    if ([item.title isEqualTo:@"Custom Color"]) {
        [self openSettings:nil];
        [panel makeKeyWindow];
        [panel makeKeyAndOrderFront:item];
        
    }
    if ([item.title isEqualTo:@"Slow Sweep"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(slowSweep) userInfo:nil repeats:YES];
        red = 50;
        green = 200;
        blue = 100;
    }
    if ([item.title isEqualTo:@"Fast Sweep"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(fastSweep) userInfo:nil repeats:YES];
        red = 0;
        green = 155;
        blue = 200;
    }
    if ([item.title isEqualTo:@"Sound Reactive"]){
        //Send Sound mode
        
    }
    if ([item.title isEqualTo:@"Mirror Screen"]){
        [self screenCaptureTick];
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(screenCaptureTick) userInfo:nil repeats:YES];
        
    }
    if ([item.title isEqualTo:@"Augment Screen"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(augmentScreenTick) userInfo:nil repeats:YES];
    }
    
    
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
    if (on) {
        //write RGB
        
        
       //self.window.backgroundColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
       

       AnDevice_SetRGB_S(context, dev, (uint8_t)red,(uint8_t)green,(uint8_t)blue);
    
    } else {
        
    }
    
}
-(void)colorProcessFinishedNotification:(NSNotification *)notification{
    NSColor *color = [notification object];
    red = floor(color.redComponent*255.0);
    green = floor(color.greenComponent*255.0);
    blue = floor(color.blueComponent*255.0);
    [self updateBoard];
}

@end