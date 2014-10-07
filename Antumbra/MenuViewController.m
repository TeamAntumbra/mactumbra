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
    NSMutableArray *circles;
}

@end

@implementation MenuViewController

@synthesize statusItemPopup;
@synthesize glowDevice;
@synthesize colorWell;
@synthesize controlBar;

@synthesize mirrorButton,augmentButton,smoothMirrorButton;
@synthesize HSVButton,RGBButtpn,DeepBlueButtpn;
@synthesize tickSlider;
@synthesize fastLabel,slowLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentSelectedIndex = 0;
        circles = [[NSMutableArray alloc]init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [controlBar setSegmentStyle:NSSegmentStyleAutomatic];
            float ballSize = 15;
             ReactiveView *v = [[ReactiveView alloc]initWithFrame:NSMakeRect(self.view.frame.size.width/2.0-(ballSize*0.5),self.view.frame.size.height/2.0-(ballSize*0.5),ballSize,ballSize)];
            [self.view addSubview:v];
            [v setNeedsDisplay:YES];
            [circles addObject:v];
            for (int i =1; i<6; i++) {
                [self addCircles:i*6 atPoint:NSMakePoint(self.view.frame.size.width/2.0,self.view.frame.size.height/2.0) withDistance:i*18 size:NSMakeSize(ballSize, ballSize)];
            }
            [[BFColorPickerPopover sharedPopover]setAppearance:NSPopoverAppearanceHUD];
            [[BFColorPickerPopover sharedPopover]setContentSize:NSMakeSize(200, 300)];
            [colorWell setPreferredEdgeForPopover:NSMaxXEdge];
            
            
            
        });
        
    }
    return self;
}



-(void)addCircles:(int)numCircles atPoint:(NSPoint)center withDistance:(float)distance size:(NSSize)fram{
    float radiansToAddEachTime = (M_PI*2)/numCircles;
    float currentRadians = 0;
    for (int i =0 ; i<numCircles; i++) {
        float xAdd = cos(currentRadians)*distance;
        float yAdd = sin(currentRadians)*distance;
        ReactiveView *v = [[ReactiveView alloc]initWithFrame:NSMakeRect(center.x+xAdd-fram.width/2.0, center.y+yAdd-fram.height/2.0, fram.width, fram.width)];
        //distance based saturation
        v.color = [NSColor colorWithCalibratedHue:currentRadians/(M_PI*2) saturation:distance/90 brightness:1.0 alpha:1.0];
        [self.view addSubview:v];
        [v setNeedsDisplay:YES];
        [circles addObject:v];
        currentRadians+=radiansToAddEachTime;
    }
}


- (IBAction)mirrorClicked:(id)sender {
    [glowDevice mirror];
}

- (IBAction)augmentClicked:(id)sender {
    [glowDevice augment];
}

- (IBAction)smoothClicked:(id)sender {
    [glowDevice mirror];
}

- (IBAction)tickSliderChanged:(id)sender {
    NSSlider *slider = sender;
   [glowDevice  setSweepSpeed:slider.floatValue/100.0];
}

- (IBAction)HSVSweepTapped:(id)sender {
    [glowDevice sweep];
}

- (IBAction)deepBlueTapped:(id)sender {
    [glowDevice sweep];
}

- (IBAction)rgbTapped:(id)sender {
    [glowDevice sweep];
}

- (IBAction)controlBarChanged:(id)sender {
    NSUInteger newIndex = [(NSSegmentedControl *)sender selectedSegment];
    if (currentSelectedIndex==0&&newIndex!=currentSelectedIndex) {
        [colorWell setHidden:YES];
        for(ReactiveView *ve in circles){
            [ve setHidden:YES];
        }
        
    }
    if (currentSelectedIndex==1&&newIndex!=currentSelectedIndex) {
        [mirrorButton setHidden:YES];
        [augmentButton setHidden:YES];
        [smoothMirrorButton setHidden:YES];
        
        
    }
    if (currentSelectedIndex==2&&newIndex!=currentSelectedIndex) {
        [tickSlider setHidden:YES];
        [HSVButton setHidden:YES];
        [DeepBlueButtpn setHidden:YES];
        [RGBButtpn setHidden:YES];
        [fastLabel setHidden:YES];
        [slowLabel setHidden:YES];
    }
    
    currentSelectedIndex = newIndex;
    if (currentSelectedIndex==0) {
        [colorWell setHidden:NO];
        for(ReactiveView *ve in circles){
            [ve setHidden:NO];
        }
        
    }
    if (currentSelectedIndex==1) {
        [mirrorButton setHidden:NO];
        [augmentButton setHidden:NO];
        [smoothMirrorButton setHidden:NO];
    }
    if (currentSelectedIndex==2) {
        [tickSlider setHidden:NO];
        [HSVButton setHidden:NO];
        [DeepBlueButtpn setHidden:NO];
        [RGBButtpn setHidden:NO];
        [fastLabel setHidden:NO];
        [slowLabel setHidden:NO];
    }
    
}

- (IBAction)quiteAntumbra:(id)sender {
    [[NSApplication sharedApplication]terminate:self];
}

-(void)fadeOut:(NSArray *)views withTime:(float)time{
    for (NSView *v in views) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            // Start some animations.
            [context setDuration:time];
            [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [[v animator] setAlphaValue:0.0];
            
        } completionHandler:^{
            [v setHidden:YES];
        }];
    }
}
-(void)fadeIn:(NSArray *)views withTime:(float)time{
    for (NSView *v in views) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            // Start some animations.
            [context setDuration:time];
            [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
            [[v animator] setAlphaValue:1.0];
            
        } completionHandler:^{
            [v setHidden:NO];
        }];
    }
}



@end
