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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentSelectedIndex = 0;
    }
    return self;
}



- (IBAction)controlBarChanged:(id)sender {
    //undraw whatever
    if (currentSelectedIndex==0) {
        [colorWell setHidden:YES];
    }
    if (currentSelectedIndex==1) {
        
    }
    if (currentSelectedIndex==2) {
        
    }
    
    currentSelectedIndex = [(NSSegmentedControl *)sender selectedSegment];
    //draw new items
    if (currentSelectedIndex==0) {
        [colorWell setHidden:NO];
    }
    if (currentSelectedIndex==1) {
        
    }
    if (currentSelectedIndex==2) {
        
    }
    
}




@end
