//
//  POPButton.m
//  Antumbra
//
//  Created by Nicholas Peretti on 9/29/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "POPButton.h"

@implementation POPButton {
    NSTrackingArea *trackingArea;
}
-(void)awakeFromNib{
    //[self updateTrackingAreas];
    [self setTitle:@"A"];
    [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:YES];
    [self setNeedsDisplay];
}

-(void)updateTrackingAreas{
    [super updateTrackingAreas];
    if (trackingArea) {
        [self removeTrackingArea:trackingArea];
    }
    NSTrackingAreaOptions options = NSTrackingInVisibleRect|NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow;
    trackingArea = [[NSTrackingArea alloc]initWithRect:NSZeroRect options:options owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    
}

-(void)mouseEntered:(NSEvent *)theEvent{
    
}
-(void)mouseExited:(NSEvent *)theEvent{
    
}

-(void)drawRect:(NSRect)dirtyRect{
    
    [self drawWithSize:self.bounds];

}


- (void)drawWithSize: (NSRect)frame ;
{
    //// Color Declarations
    NSColor* mainColor = [NSColor colorWithCalibratedRed: 0.405 green: 0.405 blue: 0.405 alpha: 1];
    
    //// Oval Drawing
    NSBezierPath* ovalPath = [NSBezierPath bezierPathWithOvalInRect:frame];
    [mainColor setFill];
    [ovalPath fill];
}

@end
