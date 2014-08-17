//
//  AppDelegate.h
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "antumbra.h"
#import "hsv.h"



@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate>

@property (assign) IBOutlet NSWindow *window;


@property (strong) IBOutlet NSMenu *statusMenu;
@property (strong, nonatomic) NSStatusItem *statusBar;
- (IBAction)toggleOnOff:(id)sender;
- (IBAction)openSettings:(id)sender;
- (IBAction)setMirrorArea:(id)sender;


@property (strong) IBOutlet NSTextField *titleLabel;


@end
