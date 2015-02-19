//
//  AGlowFade.h
//  Antumbra
//
//  Created by Nicholas Peretti on 2/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AGlowFade : NSObject {
    
}

-(instancetype)init;
-(void)start;
-(void)stop;
-(void)tick;

@property (nonatomic) int ticksPerSecond;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSColor *currentColor;

@end
