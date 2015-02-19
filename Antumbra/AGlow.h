//
//  AGlow.h
//  Antumbra
//
//  Created by Nicholas Peretti on 9/22/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libantumbra/libantumbra.h>
#import <GPUImage/GPUImage.h>
#import "ScreenColor.h"
#import "hsv.h"


#define maxDifference = 5;

@interface AGlow : NSObject

@property (nonatomic) AnDevice * device;
@property (nonatomic) AnCtx * context;
@property (nonatomic) float smoothFactor; // 1.0 means no smoothinh 0.1 means VERY smooth hardly any change
@property (nonatomic) NSColor *currentColor;
@property (nonatomic) NSWindow *mirrorAreaWindow;
@property (nonatomic) float maxBrightness;


-(id)initWithAntumbraDevice:(AnDevice *)dev andContext:(AnCtx *)con;
-(void)fadeToColor:(NSColor *)col inTime:(NSTimeInterval)time;
-(void)updateSetColor:(NSColor *)color smooth:(BOOL)s;
-(void)openWindow;

@end
