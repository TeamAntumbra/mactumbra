//
//  MenuViewController.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/21/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

@synthesize statusItemPopup;
@synthesize glowDevice;
@synthesize closeBtn;
@synthesize colorWell;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        closeBtn.delegate = self;
        [closeBtn setGradientWithStartColor:[NSColor whiteColor] endColor:[NSColor blackColor]];
        [closeBtn setTitle:@"Close Antumbra"];
        [closeBtn setTitleAlignment:MRCenterTitleAlignment];
     
    }
    return self;
}


-(void)subtleButtonEvent:(NSEvent *)event from:(id)sender{
    if ([event type] == NSLeftMouseDown) {
        NSLog(@"down");
    }
    else if ([event type] == NSLeftMouseUp) {
        NSLog(@"out");
    }
}




@end
