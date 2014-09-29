//
//  MenuViewController.h
//  Antumbra
//
//  Created by Nicholas Peretti on 9/21/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AXStatusItemPopup.h"
#import "AppDelegate.h"
#import "AGlow.h"


@interface MenuViewController : NSViewController 

@property(weak, nonatomic) AXStatusItemPopup *statusItemPopup;
@property(weak, nonatomic) AGlow *glowDevice;
@property (weak) IBOutlet NSColorWell *colorWell;


@property (weak) IBOutlet NSSegmentedControl *controlBar;


- (IBAction)controlBarChanged:(id)sender;

- (IBAction)quiteAntumbra:(id)sender;



@end
