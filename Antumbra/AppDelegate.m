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
#import "AGlow.h"


#define maxDifference = 5;

@implementation AppDelegate {
    
    AnDevice *dev;
    AnCtx *context;
    
    AXStatusItemPopup *_statusItemPopup;
    MenuViewController *contentViewController;
    AGlow *foundDevice;

    NSMutableArray *foundDevices;
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    contentViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:nil];
    
    // create icon images shown in statusbar
    NSImage *image = [NSImage imageNamed:@"icon"];
    NSImage *alternateImage = [NSImage imageNamed:@"iconGrey"];
    
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:alternateImage alternateImage:alternateImage];
    
    foundDevices = [[NSMutableArray alloc]init];
    
    [self findAntumbra];
    
    [_statusItemPopup showPopover];
    [self appearanceValueChanged:self]; //This only works if I encapsulate this inside a show/hide setneedsdisplay? whatevs
    [_statusItemPopup hidePopover];
    
   
    
}


-(void)findAntumbra{
    if (AnCtx_Init(&context)) {
        fputs("ctx init failed\n", stderr);
    }
    
    AnDeviceInfo **devs;
    size_t nDevices;
    
    AnDevice_GetList(context, &devs, &nDevices);
    if (nDevices>=1) {
        for (int i =0; i<nDevices; i++) {
            AnDeviceInfo *inf = devs[i];
            AnDevice *newDevice;
            AnError er = AnDevice_Open(context, inf, &newDevice);
            if (er) {
                //error deal with it
                NSLog(@"%s",AnError_String(er));
            }else{
                [foundDevices addObject:[[AGlow alloc]initWithAntumbraDevice:newDevice andContext:context]];
            }
        }
        AnDevice_FreeList(devs);
    }else{
        NSLog(@"no antumbras found");
    }
    
    
    contentViewController.glowDevices = foundDevices;
        
    
    
}

-(void)changeColor:(id)sender{
    for(AGlow *glowDev in foundDevices){
        [glowDev changeColor:sender];
    }
}
- (void)appearanceValueChanged:(id)sender {
    if ([_statusItemPopup isActive]) {
        [_statusItemPopup hidePopover];
    }
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