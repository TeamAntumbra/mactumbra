//
//  AGlowBlackAndWhiteFade.m
//  Antumbra
//
//  Created by Nicholas Peretti on 2/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "AGlowBlackAndWhiteFade.h"

@implementation AGlowBlackAndWhiteFade {
    float i;
}


-(instancetype)init{
    self = [super init];
    if (self) {
        i = 0;
    }
    return self;
}

-(void)tick{
    i += 0.01;
    float whiteval = (sinf(i)+1)*0.5;
    NSColor *col = [NSColor colorWithRed:whiteval green:whiteval blue:whiteval alpha:1.0];
    self.currentColor = col;
    
    [super tick];
}

@end
