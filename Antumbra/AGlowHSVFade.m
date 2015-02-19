//
//  AGlowHSVFade.m
//  Antumbra
//
//  Created by Nicholas Peretti on 2/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "AGlowHSVFade.h"

@implementation AGlowHSVFade {
    int b;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        b = 0;
    }
    return self;
}

-(void)tick{
    
    b += 1;
    int j = b%100;
    float v = j/100.0;
    NSColor *col = [NSColor colorWithCalibratedHue:v saturation:0.8 brightness:0.9 alpha:1.0];
    self.currentColor = col;
    
    [super tick];
}

@end
