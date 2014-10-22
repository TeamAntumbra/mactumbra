//
//  DescriptiveView.h
//  Antumbra
//
//  Created by Nicholas Peretti on 10/17/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

extern NSString * const kButtonTappedNotification;

@interface DescriptiveView : NSView


@property (nonatomic) NSString *mainTitle;
@property (nonatomic) NSString *descriptiveTitle;
@property (nonatomic) NSFont *smallFont;
@property (nonatomic) NSFont *largeFont;




@end

