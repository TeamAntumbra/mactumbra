//
//  ScreenColor.h
//  Antumbra
//
//  Created by Nick Peretti on 8/13/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScreenColor : NSObject

+(NSColor *)colorFromRect:(NSRect)rect;
+(NSColor *)highlightColorFromRect:(NSRect)rect;


@end
