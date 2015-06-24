//
//  AGlowFade.m
//  Antumbra
//
//  Created by Nicholas Peretti on 2/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "AGlowFade.h"

@implementation AGlowFade{

    
}

@synthesize ticksPerSecond,timer,currentColor;

-(instancetype)init{
    self = [super init];
    if (self) {
        ticksPerSecond = 30.0;
        currentColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
        }
    return self;
}

-(void)start{
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0/ticksPerSecond target:self selector:@selector(tick) userInfo:nil repeats:YES];
}
-(void)stop{
    [timer invalidate];
}
-(void)tick{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fadeTick" object:self];
}

@end
