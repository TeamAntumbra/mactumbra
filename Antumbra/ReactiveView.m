//
//  ReactiveView.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/29/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "ReactiveView.h"
#import "AppDelegate.h"
#import <Quartz/Quartz.h>

@implementation ReactiveView {
    BOOL canUndraw;
    CGRect originalSize;
    CGRect modedSize;
}

@synthesize growthFactor,color;

-(void)setUpThings{
    self.growthFactor = 20;
    self.color = [NSColor whiteColor];
    NSTrackingAreaOptions options = NSTrackingActiveAlways|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow;
    NSTrackingArea *area = [[NSTrackingArea alloc]initWithRect:self.bounds options:options owner:self userInfo:nil];
    originalSize = self.frame;
    modedSize = CGRectMake(self.frame.origin.x-(growthFactor/2.0), self.frame.origin.y-(growthFactor/2.0), self.frame.size.width+growthFactor, self.frame.size.height+growthFactor);
    [self addTrackingArea:area];
}

-(void)awakeFromNib{
    [self setUpThings];
}
-(id)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setUpThings];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawWithSize:self.bounds];
}

-(void)mouseEntered:(NSEvent *)theEvent{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        // Start some animations.
        [context setDuration:0.2];
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[self animator] setFrame:NSRectFromCGRect(modedSize)];
       
    } completionHandler:^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            // Start some animations.
            [context setDuration:0.2];
            [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [[self animator] setFrame:NSRectFromCGRect(originalSize)];
            
        } completionHandler:^{
            
        }];
        
    }];
    
}
-(void)mouseMoved:(NSEvent *)theEvent{
    
}
-(void)mouseExited:(NSEvent *)theEvent{
    
}


- (void)drawWithSize: (NSRect)frame ;
{
    //// Color Declarations
    NSColor* mainColor = self.color;
    
    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect:frame];
    [mainColor setFill];
    [ovalPath fill];
}


@end
