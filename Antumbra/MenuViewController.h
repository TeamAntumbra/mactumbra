//
//  MenuViewController.h
//  Antumbra
//
//  Created by Nicholas Peretti on 9/21/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AXStatusItemPopup.h"
#import "AGlow.h"
#import "MRSubtleButton.h"

@interface MenuViewController : NSViewController <MRSubtleButtonDelegate>

@property(weak, nonatomic) AXStatusItemPopup *statusItemPopup;
@property(weak, nonatomic) AGlow *glowDevice;
@property (weak) IBOutlet NSColorWell *colorWell;

@property (weak) IBOutlet MRSubtleButton *closeBtn;


@end
