//
//  DescriptiveView.m
//  Antumbra
//
//  Created by Nicholas Peretti on 10/17/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "DescriptiveView.h"

NSString * const kButtonTappedNotification = @"ButtonDidGetTappedNotification";

@implementation DescriptiveView {
    BOOL selected;
    BOOL inside;
    NSTrackingArea *trackingArea;
    BOOL setup;
}

@synthesize descriptiveTitle,mainTitle,smallFont,largeFont;

-(void)awakeFromNib{
    [self setUpAll];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
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
    selected = false;
    inside = false;
    mainTitle = @"Tittle";
    descriptiveTitle = @"Short Description";
    smallFont = [[NSFontManager sharedFontManager]fontWithFamily:@"Helvetica" traits:NSNarrowFontMask weight:2 size:18];
    largeFont = [[NSFontManager sharedFontManager]fontWithFamily:@"Helvetica" traits:NSNarrowFontMask weight:2 size:22];

}


- (void)drawRect:(NSRect)dirtyRect
{
    
    [super drawRect:dirtyRect];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:8 yRadius:8];
    
    [path setLineWidth:1.5];
    
    if (selected) {
        [[NSColor colorWithCalibratedWhite:0.168 alpha:0.500]setFill];
    }else{
        [[NSColor clearColor]setFill];
    }
    [[NSColor whiteColor]setStroke];
    [path fill];
    [path stroke];
    
    NSString *toBeWritten;
    NSFont *fontToBeUsed;
    NSDictionary *attributes;
    if (inside) {
        toBeWritten = descriptiveTitle;
        fontToBeUsed = smallFont;
      
    }else{
        toBeWritten = mainTitle;
        fontToBeUsed = largeFont;
    }
    
    attributes = [NSDictionary dictionaryWithObjectsAndKeys:fontToBeUsed, NSFontAttributeName,[NSColor colorWithCalibratedWhite:0.888 alpha:1.0], NSForegroundColorAttributeName, nil];
   
    
    NSAttributedString *titleString = [[NSAttributedString alloc]initWithString:toBeWritten attributes:attributes];
    NSSize textSize = [titleString size];
    
    
    NSPoint drawPoint = NSMakePoint((self.bounds.size.width/2.0)-(textSize.width/2.0), (self.bounds.size.height/2.0)-(textSize.height/2.0));
    
    [titleString drawAtPoint:drawPoint];
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
    [[NSNotificationCenter defaultCenter]postNotificationName:kButtonTappedNotification object:self];
}

-(void)mouseUp:(NSEvent *)theEvent{
    selected = false;
    [self setNeedsDisplay:YES];
}

@end
