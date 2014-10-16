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
    
    NSTrackingAreaOptions options = NSTrackingActiveAlways|NSTrackingMouseMoved;
    
    NSTrackingArea *area = [[NSTrackingArea alloc]initWithRect:self.view.bounds options:options owner:self userInfo:nil];
    
    [self.view addTrackingArea:area];
    
    
    [self setNextResponder:self.view];
    [self.view.subviews enumerateObjectsUsingBlock:^(NSView *subview, NSUInteger idx, BOOL *stop) { [subview setNextResponder:self]; }];
    
    
    
    if (self) {
        currentSelectedIndex = 0;
        circles = [[NSMutableArray alloc]init];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [controlBar setSegmentStyle:NSSegmentStyleAutomatic];
            float ballSize = 14;
            ReactiveView *v = [[ReactiveView alloc]initWithFrame:NSMakeRect(self.view.frame.size.width/2.0-(ballSize*0.5),self.view.frame.size.height/2.0-(ballSize*0.5),ballSize,ballSize)];
            [self.view addSubview:v];
            [v setNeedsDisplay:YES];
            [circles addObject:v];
            for (int i =1; i<6; i++) {
                [self addCircles:i*6 atPoint:NSMakePoint(self.view.frame.size.width/2.0,self.view.frame.size.height/2.0) withDistance:i*17 size:NSMakeSize(ballSize, ballSize)];
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
        v.color = [NSColor colorWithCalibratedHue:currentRadians/(M_PI*2) saturation:distance/(self.view.frame.size.width/2.0) brightness:1.0 alpha:1.0];
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


-(void)mouseUp:(NSEvent *)theEvent{
     NSPoint mouse = [theEvent.window mouseLocationOutsideOfEventStream];
    [[self viewAtLocation:mouse]selectAnimate];
    
}

-(void)mouseDragged:(NSEvent *)theEvent{
    
    if (currentSelectedIndex == 0) {
        NSPoint mouse = [theEvent.window mouseLocationOutsideOfEventStream];
        NSPoint center = NSMakePoint(self.view.frame.origin.x+self.view.frame.size.width/2.0, self.view.frame.origin.y+self.view.frame.size.height/2.0);
        float distance = sqrtf(((mouse.x-center.x)*(mouse.x-center.x))+((mouse.y-center.y)*(mouse.y-center.y)));
       
        float radians = 0;
        if(mouse.x>center.x){
            if(mouse.y>center.y){
                radians = asinf((mouse.y-center.y)/distance);
            } else {
                radians = asinf((mouse.x-center.x)/distance)+M_PI_2*3;
            }
        } else {
            if (mouse.y>center.y) {
         
                radians = asinf((center.x-mouse.x)/distance)+M_PI_2;
            } else {
                
                radians = asinf((center.y-mouse.y)/distance)+M_PI_2*2;
            }
        }
        [glowDevice setColor:[NSColor colorWithCalibratedHue:radians/(2*M_PI) saturation:distance/(self.view.frame.size.width/2.0) brightness:1.0 alpha:1.0]];
        [[self viewAtLocation:mouse]antimateGlow];
        
    }
    
}

-(ReactiveView *)viewAtLocation:(NSPoint)loc{
    float smallestDist = 200000000;
    int closestIndex = 0;
    int i = 0;
    for(ReactiveView *ve in circles){
        NSPoint center = NSMakePoint(ve.frame.origin.x+ve.frame.size.width+5, ve.frame.origin.y+ve.frame.size.height+5);
        
        float distance = sqrtf(((loc.x-center.x)*(loc.x-center.x))+((loc.y-center.y)*(loc.y-center.y)));
        if (distance<smallestDist) {
            smallestDist=distance;
            closestIndex = i;
        }
        i++;
    }
    ReactiveView *circ = circles[closestIndex];
    return circ;
    
}


@end
