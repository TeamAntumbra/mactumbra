//
//  AppDelegate.m
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"


#define maxDifference = 5;

@implementation AppDelegate {
    
    AnDevice *dev;
    AnCtx *context;
    
    AXStatusItemPopup *_statusItemPopup;
    MenuViewController *contentViewController;
    AGlow *foundDevice;

    NSMutableArray *foundDevices;
    AGlowManager *manager;
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    contentViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:nil];
    
    // create icon images shown in statusbar
    NSImage *image = [NSImage imageNamed:@"icon"];
    //NSImage *alternateImage = [NSImage imageNamed:@"iconGrey"];
    
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:image];
    
    
    
    [_statusItemPopup showPopover];
    [self appearanceValueChanged:self]; //This only works if I encapsulate this inside a show/hide setneedsdisplay? whatevs

    
    manager = [[AGlowManager alloc]init];
    contentViewController.manager = manager;
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification
{
    [contentViewController.manager scanForGlows];
}


- (void)appearanceValueChanged:(id)sender {

    NSPopoverAppearance newAppearance = NSPopoverAppearanceHUD;

    _statusItemPopup.popover.appearance = newAppearance;
}
-(void)resizePopover:(CGSize)newSize{
    [_statusItemPopup setContentSize:newSize];
}
-(BOOL)isHiden{
    return _statusItemPopup.isActive;
}

@end