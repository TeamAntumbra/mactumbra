//
//  AGlowManager.h
//  Antumbra
//
//  Created by Nicholas Peretti on 2/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AGlow.h"
#import "AGlowBlackAndWhiteFade.h"
#import "AGlowHSVFade.h"
#import "AGlowNeonFade.h"
#import <libantumbra/libantumbra.h>
#import <GPUImage/GPUImage.h>
#import "ScreenColor.h"
#import "hsv.h"

@interface AGlowManager : NSObject


typedef struct {uint8_t r; uint8_t g; uint8_t b;} Color;


-(instancetype)init;
-(void)scanForGlows;
-(void)augment;
-(void)mirror;
-(void)balance;
-(void)stopMirroring;
-(void)manualColor:(NSColor *)color;
-(void)showWindows;
-(void)fadeBlackAndWhite;
-(void)fadeNeon;
-(void)fadeHSV;
-(void)setFadeSpeed:(int)ticksPS;
-(void)brightness:(float)bright;

@property (nonatomic, retain) NSMutableArray *glows;
@property (nonatomic) int targetFPS;

@end
