//
//  FlatSegmentedView.m
//  Antumbra
//
//  Created by Nick Peretti on 12/31/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "FlatSegmentedView.h"

@implementation FlatSegmentedView {
    BOOL selected;
    BOOL inside;
    NSTrackingArea *trackingArea;
    BOOL setup;
    

}

-(instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setUpAll];
    }
    return self;
}

-(void)setUpAll{
    
    [self.window setAcceptsMouseMovedEvents:YES];
    [self setAcceptsTouchEvents:YES];
    if(!setup){
        NSTrackingAreaOptions options = NSTrackingActiveAlways|NSTrackingMouseMoved|NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow;
        trackingArea = [[NSTrackingArea alloc]initWithRect:self.bounds options:options owner:self userInfo:nil];
        [self addTrackingArea:trackingArea];
        setup = true;
    }
    
}

-(void)mouseEntered:(NSEvent *)theEvent{
    inside = true;
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent{
    inside = false;
    [self setNeedsDisplay:YES];
}

-(void)mouseDown:(NSEvent *)theEvent{
    selected = true;
    [self setNeedsDisplay:YES];
}

-(void)mouseUp:(NSEvent *)theEvent{
    selected = false;
    [self setNeedsDisplay:YES];
}
@end
