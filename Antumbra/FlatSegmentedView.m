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
    NSArray *_titles;
    NSInteger _currentIndex;
    NSInteger _downSegment;
    
    
}

-(instancetype)initWithFrame:(NSRect)frameRect andTitles:(NSArray *)titles{
    self = [super initWithFrame:frameRect];
    if (self) {
        _titles = titles;
        [self setUpAll];
        _currentIndex = 0;
        _downSegment = -1;
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
    _currentIndex = 0;
    
}


-(void)mouseDown:(NSEvent *)theEvent{
    
    [self setNeedsDisplay:YES];
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger segment = floor(p.x/(self.frame.size.width/self.titles.count));
    _downSegment = segment;
}
-(void)mouseDragged:(NSEvent *)theEvent
{
    [self setNeedsDisplay:YES];
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger segment = floor(p.x/(self.frame.size.width/self.titles.count));
    _downSegment = segment;
}

-(void)mouseExited:(NSEvent *)theEvent
{
    _downSegment = -1;
}

-(void)mouseUp:(NSEvent *)theEvent{
    
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger segment = floor(p.x/(self.frame.size.width/self.titles.count));
    _currentIndex = segment;
    if (self.delegate) {
        [self.delegate segmentedView:self didChangeSelectionToIndex:_currentIndex titled:self.titles[_currentIndex]];
    }
    _downSegment = -1;
    [self setNeedsDisplay:YES];
}

-(void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithCalibratedWhite:0.800 alpha:1.000] setFill];
    [[NSBezierPath bezierPathWithRect:self.bounds]fill];
    NSInteger offset = 0;
    for (NSString *s in self.titles)
    {
        if(offset<self.titles.count-1){
            NSBezierPath *line = [NSBezierPath bezierPath];
            [line moveToPoint:NSMakePoint((self.frame.size.width/self.titles.count)*(offset+1), 6)];
            [line lineToPoint:NSMakePoint((self.frame.size.width/self.titles.count)*(offset+1), self.frame.size.height-6)];
            [[NSColor darkGrayColor]  setStroke];
            [line setLineWidth:0.5];
            [line stroke];
        }
        NSMutableParagraphStyle *paragrapg = [[NSMutableParagraphStyle alloc]init];
        [paragrapg setAlignment:NSTextAlignmentCenter];
        NSMutableAttributedString *a = [[NSMutableAttributedString alloc]initWithString:s];
        NSColor *textColor = [NSColor colorWithCalibratedWhite:0.190 alpha:1.000];
        if (offset == _currentIndex) {
            textColor = [NSColor colorWithHue:((1.0/self.titles.count)*_currentIndex) saturation:0.85 brightness:0.65 alpha:1.0];
        }
        if (offset == _downSegment) {
            textColor = [NSColor blackColor];
        }
        [a setAttributes:@{NSFontAttributeName:[NSFont systemFontOfSize:14],NSForegroundColorAttributeName:textColor,NSParagraphStyleAttributeName:paragrapg} range:NSMakeRange(0, a.length)];
        NSRect box = [a boundingRectWithSize:NSMakeSize(0, 0) options:0];
        
        [a drawInRect:NSMakeRect(offset*(self.frame.size.width/self.titles.count), (self.frame.size.height*0.5)-(box.size.height*0.5), (self.frame.size.width/self.titles.count), box.size.height)];
        offset++;
    }
}
@end
