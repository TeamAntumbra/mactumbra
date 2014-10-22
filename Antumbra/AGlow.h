//
//  AGlow.h
//  Antumbra
//
//  Created by Nicholas Peretti on 9/22/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libantumbra/libantumbra.h>
#import "ScreenColor.h"
#import "hsv.h"


#define maxDifference = 5;

@interface AGlow : NSObject

@property (nonatomic) AnDevice * device;
@property (nonatomic) AnCtx * context;
@property (nonatomic) float sweepSpeed;
@property (nonatomic) bool isMirroring;
@property (nonatomic) float smoothFactor; // 1.0 means no smoothinh 0.1 means VERY smooth hardly any change



-(id)initWithAntumbraDevice:(AnDevice *)dev andContext:(AnCtx *)con;

-(void)augment;
-(void)mirror;

-(void)sweep;
-(void)setColor:(NSColor *)newColor;
-(void)openWindow;

-(void)stopUpdates;

@end
