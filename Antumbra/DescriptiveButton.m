//
//  DescriptiveButton.m
//  Antumbra
//
//  Created by Nicholas Peretti on 10/16/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import "DescriptiveButton.h"

@implementation DescriptiveButton

@synthesize mainTitle, descriptiveTitle;



- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

-(void)mouseEntered:(NSEvent *)theEvent{
    self.title = descriptiveTitle;
    
}

-(void)mouseExited:(NSEvent *)theEvent{
    self.title = mainTitle;
}


@end
