//
//  AGlowManager.m
//  Antumbra
//
//  Created by Nicholas Peretti on 2/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "AGlowManager.h"

@implementation AGlowManager {
    AnCtx *context;
    BOOL mirroring;
    BOOL canMirror;
    NSTimer *timer;
    AGlowFade *currentFade;
    dispatch_queue_t _glowQueue;
    dispatch_source_t _timer;
}

@synthesize glows;
@synthesize targetFPS;

-(instancetype)init{
    self = [super init];
    if (self) {
        mirroring = NO;
        canMirror = YES;
        glows = [[NSMutableArray alloc]init];
        targetFPS = 30.0;
        currentFade = nil;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopedMirroring) name:@"doneMirroring" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fadeTick) name:@"fadeTick" object:nil];

        typeof(self) weakSelf = self;
        void (^glowLoop)() = ^void()
        {
            if([weakSelf glowsPlugedIn]!=glows.count)
            {
                [weakSelf scanForGlows];
            }
        };
        
        _glowQueue = dispatch_queue_create("io.antumbra.glowQ", DISPATCH_QUEUE_SERIAL);
         _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _glowQueue);
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), 0.5 * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(_timer, glowLoop);
        dispatch_resume(_timer);

        
    }
    return self;
}

dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}

-(NSInteger)glowsPlugedIn
{
    AnDeviceInfo **devs;
    size_t nDevices;
    AnCtx *testcontext;
    if (AnCtx_Init(&testcontext)) {
        fputs("ctx init failed\n", stderr);
        return glows.count;
    } else {
        AnDevice_GetList(testcontext, &devs, &nDevices);
    }
    return nDevices;
}

- (void)scanForGlows
{
    
    for (AGlow *g in glows) {
        
        AnDevice_Close(g.context, g.device);
    }
    
    [glows removeAllObjects];
    if (context) {
        AnCtx_Deinit(context);
        context = nil;
    }
    if (AnCtx_Init(&context)) {
        fputs("ctx init failed\n", stderr);
    }
    AnDeviceInfo **devs;
    size_t nDevices;
    
    AnDevice_GetList(context, &devs, &nDevices);
    if (nDevices>=1) {
        for (int i =0; i<nDevices; i++) {
            AnDeviceInfo *inf = devs[i];
            AnDevice *newDevice;
            AnError er = AnDevice_Open(context, inf, &newDevice);
            if (er) {
                //error deal with it
                NSLog(@"%s",AnError_String(er));
            }else{
                AGlow *g = [[AGlow alloc]initWithAntumbraDevice:newDevice andContext:context];
                g.index = glows.count;
                [glows addObject:g];
            }
        }
        AnDevice_FreeList(devs);
    }else{
        NSLog(@"no antumbras found");
    }

}



-(void)colorFromGlow:(AGlow *)glow{
    if (!mirroring) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"doneMirroring" object:nil];
        return;
    }
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[glow.mirrorAreaWindow.screen deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, glow.mirrorAreaWindow.frame);
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    [pic addTarget:average];
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        [glow updateSetColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:a] smooth:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/targetFPS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self colorFromGlow:glow];
        });
    }];
    [pic processImage];
    CFRelease(first);
}

-(void)augmentFromGlow:(AGlow *)glow{
    if (!mirroring) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"doneMirroring" object:nil];
        return;
    }
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[glow.mirrorAreaWindow.screen deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, glow.mirrorAreaWindow.frame);
    if (!first) {
        //CFRelease(first);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/targetFPS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self augmentFromGlow:glow];
        });
        return;
    }
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    GPUImageSaturationFilter *sat = [[GPUImageSaturationFilter alloc]init];
    sat.saturation = 2.0;
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    [pic addTarget:sat];
    [sat addTarget:average];
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        [glow updateSetColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:a] smooth:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/targetFPS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self augmentFromGlow:glow];
        });
    }];
    [pic processImage];
    CFRelease(first);
}


-(void)balancedFromGlow:(AGlow *)glow{
    if (!mirroring) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"doneMirroring" object:nil];
        return;
    }
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[glow.mirrorAreaWindow.screen deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, glow.mirrorAreaWindow.frame);
    GPUImagePicture *pic = [[GPUImagePicture alloc]initWithCGImage:first];
    GPUImageSaturationFilter *sat = [[GPUImageSaturationFilter alloc]init];
    sat.saturation = 1.5;
    GPUImageAverageColor *average = [[GPUImageAverageColor alloc]init];
    [pic addTarget:sat];
    [sat addTarget:average];
    [average setColorAverageProcessingFinishedBlock:^(CGFloat r, CGFloat g, CGFloat b, CGFloat a, CMTime time) {
        
        [glow updateSetColor:[NSColor colorWithCalibratedRed:r green:g blue:b alpha:a] smooth:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0/targetFPS * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self balancedFromGlow:glow];
        });
    }];
    [pic processImage];
    CFRelease(first);
}



-(void)mirror{
    [self endFading];
    if (canMirror) {
        canMirror = false;
        mirroring = true;
        for (AGlow *gl in glows) {
            gl.smoothFactor = 0.1;
            [self colorFromGlow:gl];
        }
    }else {
        mirroring = false;
    }
}
-(void)augment{
    [self endFading];
    if(canMirror){
        canMirror = false;
        mirroring = true;
        for (AGlow *gl in glows) {
            gl.smoothFactor = 0.5;
            [self augmentFromGlow:gl];
        }
    }else{
        mirroring = false;
    }
}
-(void)balance{
    [self endFading];
    if (canMirror) {
        canMirror = false;
        mirroring = true;
        for (AGlow *gl in glows) {
            gl.smoothFactor = 0.1;
            [self balancedFromGlow:gl];
        }
    }else{
        mirroring =false;
        
    }
}

-(void)stopMirroring{
    mirroring = NO;
}
-(void)stopedMirroring{
    canMirror = YES;
    
}

-(void)manualColor:(NSColor *)color{
    [self endFading];
    if (mirroring) {
        mirroring = NO;
    } else {
        for (AGlow *g in glows) {
            [g updateSetColor:color smooth:NO];
        }
    }
}

-(void)fadeBlackAndWhite{
    [self endFading];
    currentFade = [[AGlowBlackAndWhiteFade alloc]init];
    [currentFade start];
    
}
-(void)fadeHSV{
    [self endFading];
    currentFade = [[AGlowHSVFade alloc]init];
    [currentFade start];
    
}
-(void)fadeNeon{
    [self endFading];
    currentFade = [[AGlowNeonFade alloc]init];
    [currentFade start];
}
-(void)endFading{
    mirroring = false;
    if (currentFade!=nil) {
        [currentFade stop];
    }
    currentFade = nil;
}

-(void)setFadeSpeed:(int)ticksPS{
    if (currentFade!=nil) {
        [currentFade stop];
        [currentFade setTicksPerSecond:ticksPS];
        [currentFade start];
    }
}

-(void)fadeTick{
    for (AGlow *g in glows) {
        [g fadeToColor:currentFade.currentColor inTime:1.0/currentFade.ticksPerSecond];
    }
}

-(void)showWindows{
    for (AGlow *g in glows) {
        [g openWindow];
    }
}

-(void)brightness:(float)bright{
    for (AGlow *g in glows) {
        [g setMaxBrightness:bright];
        [g updateSetColor:g.currentColor smooth:NO];
    }
}


@end
