//
//  AppDelegate.m
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "AppDelegate.h"
#include "serial.h"
#include "hsv.h"

@implementation AppDelegate {
    int red;
    int green;
    int blue;
    
    int tick;
    
    BOOL on;
    
    NSColorPanel *panel;
    
    NSTimer *sweepTimer;
    
    
    NSMutableArray *savedColorConfigurations;
}

@synthesize statusBar = _statusBar;
@synthesize titleLabel;
@synthesize strobeSlider;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"A";
    [_window setTitle:@""];
    self.statusMenu.delegate = self;
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    panel = [NSColorPanel sharedColorPanel];
    [panel setTarget:self];
    [panel setAction:@selector(changeColor:)];
    [panel setContinuous:YES];
    
    
    ser_init();
    
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
    
    [self updateBoard];
    
}


- (IBAction)toggleOnOff:(id)sender {
    on = !on;
    [self updateBoard];
}


- (IBAction)openSettings:(id)sender {
    [_window makeKeyAndOrderFront:sender];
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
        
        [panel makeKeyWindow];
        [panel makeKeyAndOrderFront:item];
        
    }
    if ([item.title isEqualTo:@"Slow Sweep"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(slowSweep) userInfo:nil repeats:YES];
        red = 50;
        green = 200;
        blue = 100;
    }
    if ([item.title isEqualTo:@"Fast Sweep"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fastSweep) userInfo:nil repeats:YES];
        red = 0;
        green = 155;
        blue = 200;
    }
    if ([item.title isEqualTo:@"Sound Reactive"]){
        //Send Sound mode
        ser_set_mode(7);
    }
    if ([item.title isEqualTo:@"Mirror Screen"]){
        /*
        NSLog(@"saw");
        system("screencapture -c -x");
        NSImage *mage=[[NSImage alloc]initWithPasteboard:[NSPasteboard generalPasteboard]];
        
        NSImageView *mageView = [[NSImageView alloc]initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, mage.size.width, mage.size.height))];
        [mageView setImage:mage];
       
        [self.window.contentView addSubview:mageView];
        
        NSLog(@"%f   %f",mage.size.width, mage.size.height);
        */
    }
    if ([item.title isEqualTo:@"Seizure"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(randomColorTick) userInfo:nil repeats:YES];
    }
    
    
}
-(void)randomColorTick{
    red = arc4random()%256;
    blue = arc4random()%256;
    green = arc4random()%256;
    [self updateBoard];
}

-(void)fastSweep{
    uint8_t reed;
    uint8_t bluee;
    uint8_t greeen;
    hsv2rgb(tick/.4, 1.0, 1.0, &reed, &greeen, &bluee);
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
    hsv2rgb(tick/20.0, 1.0, 1.0, &reed, &greeen, &bluee);
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
        ser_set_color(red, green, blue);
        
    } else {
        //write all zeros
        ser_set_color(0, 0, 0);
        
    }
    
}
@end
