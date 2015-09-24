//
//  MenuViewController.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/21/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "MenuViewController.h"
#import "FlatSegmentedView.h"

@interface MenuViewController (){
    NSUInteger currentSelectedIndex;
    NSMutableArray *circles;
    NSPoint centerOffset;
}

@end

@implementation MenuViewController

@synthesize statusItemPopup;
@synthesize manager;
@synthesize controlBar;
@synthesize mirrorButton,augmentButton,smoothMirrorButton;
@synthesize HSVButton,RGBButtpn,DeepBlueButtpn;
@synthesize tickSlider;
@synthesize fastLabel,slowLabel;
@synthesize settingsButton;
@synthesize brightnessSlider;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    centerOffset = NSMakePoint(0, 0);
    NSTrackingAreaOptions options = NSTrackingActiveAlways|NSTrackingMouseMoved;
    
    NSTrackingArea *area = [[NSTrackingArea alloc]initWithRect:self.view.bounds options:options owner:self userInfo:nil];
    
    [self.view addTrackingArea:area];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedNotification:) name:kButtonTappedNotification object:nil];
    [mirrorButton setMainTitle:@"Mirror"];
    [mirrorButton setDescriptiveTitle:@"Best for work"];
    [augmentButton setMainTitle:@"Augment"];
    [augmentButton setDescriptiveTitle:@"Best for play"];
    [smoothMirrorButton setMainTitle:@"Smooth"];
    [smoothMirrorButton setDescriptiveTitle:@"Best for anything"];
    
    [HSVButton setMainTitle:@"Rainbow"];
    [HSVButton setDescriptiveTitle:@"Rainbow Colors"];
    [RGBButtpn setMainTitle:@"Black & White"];
    [RGBButtpn setDescriptiveTitle:@"B&W Fades"];
    [DeepBlueButtpn setMainTitle:@"Neon"];
    [DeepBlueButtpn setDescriptiveTitle:@"Neon colors!"];
    
    NSArray *buttons = @[mirrorButton,augmentButton,smoothMirrorButton,HSVButton,RGBButtpn,DeepBlueButtpn];
    
    FlatSegmentedView *fView = [[FlatSegmentedView alloc]initWithFrame:NSMakeRect(0, self.view.frame.size.height-40, self.view.frame.size.width, 40)];
    [fView setTitles:@[@"glow",@"mirror",@"fade",@"quit"]];
    [fView setDelegate:self];
    [controlBar setHidden:YES];
    [self.view addSubview:fView];
    
    for (DescriptiveView *vie in buttons) {
        [vie setLargeFont:[NSFont systemFontOfSize:20]];
        [vie setSmallFont:[NSFont systemFontOfSize:14]];
    }
    
    if (self) {
        currentSelectedIndex = 0;
        circles = [[NSMutableArray alloc]init];
        
        [controlBar setSegmentStyle:NSSegmentStyleAutomatic];
        float ballSize = 14;
        ReactiveView *v = [[ReactiveView alloc]initWithFrame:NSMakeRect(self.view.frame.size.width/2.0-(ballSize*0.5)+centerOffset.x,self.view.frame.size.height/2.0-(ballSize*0.5)+centerOffset.y,ballSize,ballSize)];
        [self.view addSubview:v];
        [v setNeedsDisplay:YES];
        [circles addObject:v];
        for (int i =1; i<6; i++) {
            [self addCircles:i*6 atPoint:NSMakePoint(self.view.frame.size.width/2.0+centerOffset.x,self.view.frame.size.height/2.0+centerOffset.y) withDistance:i*17 size:NSMakeSize(ballSize, ballSize)];
        }
        
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
        v.color = [NSColor colorWithCalibratedHue:currentRadians/(M_PI*2) saturation:distance/((self.view.frame.size.width/2.0)-30) brightness:1.0 alpha:1.0];
        [self.view addSubview:v];
        [v setNeedsDisplay:YES];
        [circles addObject:v];
        currentRadians+=radiansToAddEachTime;
    }
}




- (IBAction)tickSliderChanged:(id)sender {
    NSSlider *slider = sender;
    [manager setFadeSpeed:slider.intValue];
}

- (IBAction)settingsTapped:(id)sender {
    [manager showWindows];
}

-(void)receivedNotification:(NSNotification *)note {
    DescriptiveView *obj = [note object];
    [self handleButtonTap:obj.mainTitle];
    
}

- (IBAction)quiteAntumbra:(id)sender
{
    [[NSApplication sharedApplication]terminate:self];
}

-(void)segmentedView:(FlatSegmentedView *)view didChangeSelectionToIndex:(NSInteger)index titled:(NSString *)title
{
    NSUInteger newIndex = index;
    if (currentSelectedIndex==0&&newIndex!=currentSelectedIndex) {
        for(ReactiveView *ve in circles){
            [ve setHidden:YES];
        }
        // brightnessSlider.hidden = YES;
    }
    if (currentSelectedIndex==1&&newIndex!=currentSelectedIndex) {
        [mirrorButton setHidden:YES];
        [augmentButton setHidden:YES];
        [smoothMirrorButton setHidden:YES];
        [settingsButton setHidden:YES];
        
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
        for(ReactiveView *ve in circles){
            [ve setHidden:NO];
        }
        // brightnessSlider.hidden = NO;
    }
    if (currentSelectedIndex==1) {
        [mirrorButton setHidden:NO];
        [augmentButton setHidden:NO];
        [smoothMirrorButton setHidden:NO];
        [settingsButton setHidden:NO];
    }
    if (currentSelectedIndex==2) {
        [tickSlider setHidden:NO];
        [HSVButton setHidden:NO];
        [DeepBlueButtpn setHidden:NO];
        [RGBButtpn setHidden:NO];
        [fastLabel setHidden:NO];
        [slowLabel setHidden:NO];
    }
    if (currentSelectedIndex==3) {
        [[NSApplication sharedApplication]terminate:self];
    }
}

- (IBAction)brightnessSlide:(id)sender {
    [manager brightness:brightnessSlider.floatValue/100.0];
}




-(void)mouseUp:(NSEvent *)theEvent{
    
    if (currentSelectedIndex == 0) {
        NSPoint mouse = [theEvent.window mouseLocationOutsideOfEventStream];
        NSColor *color = [self colorAtLocation:mouse];
        [manager stopMirroring];
        [manager manualColor:color];
        [[self viewAtLocation:mouse]selectAnimate];
    }
}

-(void)mouseDragged:(NSEvent *)theEvent{
    
    if (currentSelectedIndex == 0) {
        NSPoint mouse = [theEvent.window mouseLocationOutsideOfEventStream];
        NSColor *color = [self colorAtLocation:mouse];
        [manager stopMirroring];
        [manager manualColor:color];
        [[self viewAtLocation:mouse] antimateGlow];
    }
    
}

-(void)mouseDown:(NSEvent *)theEvent
{
    
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

-(NSColor *)colorAtLocation:(NSPoint)loc{
    NSPoint center = NSMakePoint(self.view.frame.origin.x+self.view.frame.size.width/2.0+centerOffset.x, self.view.frame.origin.y+self.view.frame.size.height/2.0+centerOffset.y);
    float distance = sqrtf(((loc.x-center.x)*(loc.x-center.x))+((loc.y-center.y)*(loc.y-center.y)));
    
    float radians = 0;
    if(loc.x>center.x){
        if(loc.y>center.y){
            radians = asinf((loc.y-center.y)/distance);
        } else {
            radians = asinf((loc.x-center.x)/distance)+M_PI_2*3;
        }
    } else {
        if (loc.y>center.y) {
            
            radians = asinf((center.x-loc.x)/distance)+M_PI_2;
        } else {
            
            radians = asinf((center.y-loc.y)/distance)+M_PI_2*2;
        }
    }
    return [NSColor colorWithCalibratedHue:radians/(2*M_PI) saturation:distance/((self.view.frame.size.width/2.0)-30) brightness:1.0 alpha:1.0];
    
    
}
-(void)handleButtonTap:(NSString *)buttonTitle{
    if([buttonTitle isEqualToString:@"Mirror"]){
        [manager stopMirroring];
        [manager mirror];
    }
    if([buttonTitle isEqualToString:@"Augment"]){
        [manager stopMirroring];
        [manager augment];
    }
    if([buttonTitle isEqualToString:@"Smooth"]){
        [manager stopMirroring];
        [manager balance];
    }
    
    if([buttonTitle isEqualToString:@"Rainbow"]){
        [manager fadeHSV];
    }
    if([buttonTitle isEqualToString:@"Black & White"]){
        [manager fadeBlackAndWhite];
        
    }
    if([buttonTitle isEqualToString:@"Neon"]){
        [manager fadeNeon];
       
    }
   
}



@end
