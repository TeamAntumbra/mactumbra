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
#import "ReactiveView.h"
#import "BFPopoverColorWell.h"
#import "BFColorPickerPopover.h"

@interface MenuViewController : NSViewController 

@property(weak, nonatomic) AXStatusItemPopup *statusItemPopup;
@property(weak, nonatomic) AGlow *glowDevice;
@property (weak) IBOutlet BFPopoverColorWell *colorWell;


@property (weak) IBOutlet NSSegmentedControl *controlBar;

@property (weak) IBOutlet NSButton *mirrorButton;
@property (weak) IBOutlet NSButton *augmentButton;
@property (weak) IBOutlet NSButton *smoothMirrorButton;
@property (weak) IBOutlet NSSlider *tickSlider;
@property (weak) IBOutlet NSButton *HSVButton;
@property (weak) IBOutlet NSButton *RGBButtpn;
@property (weak) IBOutlet NSButton *DeepBlueButtpn;
@property (weak) IBOutlet NSTextField *slowLabel;
@property (weak) IBOutlet NSTextField *fastLabel;

- (IBAction)mirrorClicked:(id)sender;
- (IBAction)augmentClicked:(id)sender;
- (IBAction)smoothClicked:(id)sender;

- (IBAction)tickSliderChanged:(id)sender;


- (IBAction)HSVSweepTapped:(id)sender;
- (IBAction)deepBlueTapped:(id)sender;
- (IBAction)rgbTapped:(id)sender;



- (IBAction)controlBarChanged:(id)sender;

- (IBAction)quiteAntumbra:(id)sender;



@end
