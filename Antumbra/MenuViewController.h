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
#import "AGlowManager.h"
#import "ReactiveView.h"
#import "DescriptiveView.h"
#import "FlatSegmentedView.h"

@interface MenuViewController : NSViewController <FlatSegmentedViewDelegate>

@property(weak, nonatomic) AXStatusItemPopup *statusItemPopup;
@property(weak, nonatomic) AGlowManager *manager;
@property (weak) IBOutlet NSSegmentedControl *controlBar;
@property (weak) IBOutlet DescriptiveView *mirrorButton;
@property (weak) IBOutlet DescriptiveView *augmentButton;
@property (weak) IBOutlet DescriptiveView *smoothMirrorButton;
@property (weak) IBOutlet NSSlider *tickSlider;
@property (weak) IBOutlet DescriptiveView *HSVButton;
@property (weak) IBOutlet DescriptiveView *RGBButtpn;
@property (weak) IBOutlet DescriptiveView *DeepBlueButtpn;
@property (weak) IBOutlet NSTextField *slowLabel;
@property (weak) IBOutlet NSTextField *fastLabel;
@property (weak) IBOutlet NSSlider *brightnessSlider;


- (IBAction)tickSliderChanged:(id)sender;
- (IBAction)settingsTapped:(id)sender;
- (IBAction)controlBarChanged:(id)sender;
- (IBAction)quiteAntumbra:(id)sender;
- (IBAction)brightnessSlide:(id)sender;

@property (weak) IBOutlet NSButton *settingsButton;


@end
