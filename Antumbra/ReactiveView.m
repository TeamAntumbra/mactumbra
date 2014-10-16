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
    BOOL growing;
}

@synthesize growthFactor,color;

-(void)setUpThings{
    growing = false;
    self.growthFactor = 15;
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


- (void)drawWithSize: (NSRect)frame ;
{
    //// Color Declarations
    NSColor* mainColor = self.color;
    
    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect:frame];
    [mainColor setFill];
    [ovalPath fill];
}
-(void)antimateGlow{
    if (growing) {
        return;
    }
    growing = true;
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
            growing = false;
        }];
        
    }];

}
-(void)selectAnimate{
    
    growing = true;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        // Start some animations.
        [context setDuration:0.1];
        [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
        [[self animator] setFrame:NSRectFromCGRect([self scaleRect:originalSize scale:0.5])];
        
    } completionHandler:^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            // Start some animations.
            [context setDuration:0.2];
            [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
            [[self animator] setFrame:NSRectFromCGRect([self scaleRect:originalSize scale:2.5])];
        } completionHandler:^{
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
                // Start some animations.
                [context setDuration:0.2];
                [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
                [[self animator] setFrame:NSRectFromCGRect([self scaleRect:originalSize scale:0.65])];
            } completionHandler:^{
                [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
                    // Start some animations.
                    [context setDuration:0.2];
                    [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
                    [[self animator] setFrame:NSRectFromCGRect([self scaleRect:originalSize scale:1.0])];
                } completionHandler:^{
                    growing = false;
                }];
            }];
        }];
    }];
}

-(CGRect)scaleRect:(CGRect)rect scale:(float)s{
    CGRect newRect;
    
    newRect.size.width = rect.size.width*s;
    newRect.size.height = rect.size.height*s;
    
    newRect.origin.x = rect.origin.x-(newRect.size.width-rect.size.width)*0.5;
    newRect.origin.y = rect.origin.y-(newRect.size.height-rect.size.height)*0.5;
    
    return newRect;
}

@end
