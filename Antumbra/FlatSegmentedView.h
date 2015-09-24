//
//  FlatSegmentedView.h
//  Antumbra
//
//  Created by Nick Peretti on 12/31/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@protocol FlatSegmentedViewDelegate;


@interface FlatSegmentedView : NSView

@property (nonatomic) NSArray *titles;
@property (nonatomic) NSColor *lineColor;
@property(nonatomic, weak) id<FlatSegmentedViewDelegate> delegate;

-(instancetype)initWithFrame:(NSRect)frameRect andTitles:(NSArray *)titles;


@end

@protocol FlatSegmentedViewDelegate

@required
-(void)segmentedView:(FlatSegmentedView *)view didChangeSelectionToIndex:(NSInteger)index titled:(NSString *)title;

@end