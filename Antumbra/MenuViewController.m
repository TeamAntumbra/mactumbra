//
//  MenuViewController.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/21/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController (){
    NSUInteger currentSelectedIndex;
}

@end

@implementation MenuViewController

@synthesize statusItemPopup;
@synthesize glowDevice;
@synthesize colorWell;
@synthesize controlBar;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentSelectedIndex = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [controlBar setSegmentStyle:NSSegmentStyleAutomatic];
        });
        
    }
    return self;
}



- (IBAction)controlBarChanged:(id)sender {
    
    
    
    if (currentSelectedIndex==0) {
        [colorWell setHidden:YES];
    }
    if (currentSelectedIndex==1) {
        
    }
    if (currentSelectedIndex==2) {
        
    }
    
    currentSelectedIndex = [(NSSegmentedControl *)sender selectedSegment];
    AppDelegate *deligateLOL = (AppDelegate *)[NSApp delegate];
    //draw new items
    if (currentSelectedIndex==0) {
       [deligateLOL resizePopover:CGSizeMake(200, 200)];
        [colorWell setHidden:NO];
    }
    if (currentSelectedIndex==1) {
        [deligateLOL resizePopover:CGSizeMake(200, 300)];
    }
    if (currentSelectedIndex==2) {
        [deligateLOL resizePopover:CGSizeMake(200, 400)];
    }
    
}

- (IBAction)quiteAntumbra:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}




@end
