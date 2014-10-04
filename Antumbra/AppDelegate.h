//
//  AppDelegate.h
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "libantumbra/libantumbra.h"
#import "AXStatusItemPopup.h"
#import "hsv.h"


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

typedef struct {uint8_t r; uint8_t g; uint8_t b;} Color;

-(void)resizePopover:(CGSize)newSize;
-(BOOL)isHiden;

@end
