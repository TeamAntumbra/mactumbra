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
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    
    contentViewController = [[MenuViewController alloc] initWithNibName:@"MenuView" bundle:nil];
    
    // create icon images shown in statusbar
    NSImage *image = [NSImage imageNamed:@"icon"];
    NSImage *alternateImage = [NSImage imageNamed:@"iconGrey"];
    
    _statusItemPopup = [[AXStatusItemPopup alloc] initWithViewController:contentViewController image:image alternateImage:nil];
    
    
    [self findAntumbra];
    
    [_statusItemPopup showPopover];
    [self appearanceValueChanged:self]; //This only works if I encapsulate this inside a show/hide setneedsdisplay? whatevs
    [_statusItemPopup hidePopover];
    
}


-(void)findAntumbra{
    
    
    if (AnCtx_Init(&context)) {
        fputs("ctx init failed\n", stderr);
    }
    AnDevice_Populate(context);
    
    int count  = AnDevice_GetCount(context);
    if (count == 0) {
        
        //Handle no Antumbra found
        NSAlert *lert = [[NSAlert alloc]init];
        [lert setShowsSuppressionButton:YES];
        [lert setMessageText:@"No Antumbra detected. Please plug one in and then press OK."];
        //[lert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
        //    [self findAntumbra];
        //}];
    } else{
        
        //Atleast 1 antumbra found
        for (int i = 0; i < AnDevice_GetCount(context); ++i) {
            const char *ser;
            dev = AnDevice_Get(context, i);
            
            AnDevice_Info(dev, NULL, NULL, &ser);
            
            if (AnDevice_Open(context, dev)) {
                fputs("device open failed\n", stderr);
                
            }
            
        }
        
        foundDevice = [[AGlow alloc]initWithAntumbraDevice:dev andContext:context];
        contentViewController.glowDevice = foundDevice;
        
    }
    
}

-(void)changeColor:(id)sender{
    [foundDevice changeColor:sender];
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