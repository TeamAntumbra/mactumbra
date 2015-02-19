//
//  AGlowNeonFade.m
//  Antumbra
//
//  Created by Nicholas Peretti on 2/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "AGlowNeonFade.h"

@implementation AGlowNeonFade {
    NSArray *neons;
    NSColor *current;
    float j;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        neons = [NSArray arrayWithObjects:[NSColor colorWithCalibratedRed:0.991 green:1.000 blue:0.047 alpha:1.000],
                 [NSColor colorWithCalibratedRed:0.000 green:0.000 blue:0.993 alpha:1.000],
                 [NSColor colorWithCalibratedRed:0.143 green:1.000 blue:0.033 alpha:1.000],
                 [NSColor colorWithCalibratedRed:0.980 green:0.000 blue:0.955 alpha:1.000],
                 [NSColor colorWithCalibratedRed:0.981 green:0.000 blue:0.031 alpha:1.000], nil];
        current = neons[0];
        j = 0.01;
    }
    return self;
}

-(void)tick{
    j+=0.01;
    int currentIndex = floorf(j);
    int nextIndex = ceil(j);
    NSColor *cur = neons[currentIndex%neons.count];
    NSColor *next = neons[nextIndex%neons.count];
    self.currentColor = [cur blendedColorWithFraction:(j-currentIndex) ofColor:next];
    [super tick];
}

@end
