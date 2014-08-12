//
//  AppDelegate.m
//  antumbra
//
//  Created by Nick Peretti on 6/7/14.
//  Copyright (c) 2014 Nicholas Peretti. All rights reserved.
//

#import "AppDelegate.h"
#import "antumbra.h"
#import "hsv.h"



@implementation AppDelegate {
    uint8_t red;
    uint8_t green;
    uint8_t blue;
    
    int tick;
    
    
    BOOL on;
    
    NSColorPanel *panel;
    
    NSTimer *sweepTimer;
    
    NSMutableArray *antumbras;
    AnDevice *dev;
    AnCtx *context;
    
    NSMutableArray *savedColorConfigurations;
}

@synthesize statusBar = _statusBar;
@synthesize titleLabel;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    antumbras = [[NSMutableArray alloc]init];
    self.statusBar = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusBar.title = @"A";
    [_window setTitle:@""];
    [_window makeKeyAndOrderFront:NSApp];
    self.statusMenu.delegate = self;
    self.statusBar.menu = self.statusMenu;
    self.statusBar.highlightMode = YES;
    panel = [NSColorPanel sharedColorPanel];
    [panel setTarget:self];
    [panel setAction:@selector(changeColor:)];
    [panel setContinuous:YES];
    
    tick=0;
    on = YES;
    
    for (int i = 2; i<self.statusMenu.itemArray.count; i++) {
        NSMenuItem *currentItem = self.statusMenu.itemArray[i];
        [currentItem setTarget:self];
        [currentItem setAction:@selector(itemClicked:)];
    }
    
    red = 255;
    green = 0;
    blue = 0;
    

    

    if (AnCtx_Init(&context)) {
        fputs("ctx init failed\n", stderr);
    }
    AnDevice_Populate(context);
    
    int count  = AnDevice_GetCount(context);
    NSLog(@"%i",count);
    for (int i = 0; i < AnDevice_GetCount(context); ++i) {
        const char *ser;
        dev = AnDevice_Get(context, i);
        AnDevice_Info(dev, NULL, NULL, &ser);
        puts(ser);
        if (AnDevice_Open(context, dev)) {
            fputs("device open failed\n", stderr);
            
        }
        //AnDevice_Close(ctx, dev);
        //AnDevice_Free(dev);
        //[antumbras addObject:(__bridge id)(dev)];
    }
    
    //AnCtx_Deinit(ctx);
        [self updateBoard];
    
}


- (IBAction)toggleOnOff:(id)sender {
    on = !on;
    [self updateBoard];
}


- (IBAction)openSettings:(id)sender {
    [_window makeKeyAndOrderFront:sender];
}
- (void)itemClicked:(NSMenuItem *)item{
    tick = 0;
    [sweepTimer invalidate];
    for (int i = 2; i<self.statusMenu.itemArray.count; i++) {
        NSMenuItem *currentItem = self.statusMenu.itemArray[i];
        [currentItem setState:NSOffState];
    }
    [item setState:NSOnState];
    if ([item.title isEqualTo:@"Custom Color"]) {
        
        [panel makeKeyWindow];
        [panel makeKeyAndOrderFront:item];
        
    }
    if ([item.title isEqualTo:@"Slow Sweep"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(slowSweep) userInfo:nil repeats:YES];
        red = 50;
        green = 200;
        blue = 100;
    }
    if ([item.title isEqualTo:@"Fast Sweep"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fastSweep) userInfo:nil repeats:YES];
        red = 0;
        green = 155;
        blue = 200;
    }
    if ([item.title isEqualTo:@"Sound Reactive"]){
        //Send Sound mode
        
    }
    if ([item.title isEqualTo:@"Mirror Screen"]){
        
        
        
        [self screenCaptureTick];
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.016 target:self selector:@selector(screenCaptureTick) userInfo:nil repeats:YES];
        
    }
    if ([item.title isEqualTo:@"Seizure"]){
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(randomColorTick) userInfo:nil repeats:YES];
    }
    if ([item.title isEqualTo:@"Fades"]){
        red=15;
        green=15;
        blue=15;
        
        sweepTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(fadeTick) userInfo:nil repeats:YES];
    }
    
    
}
-(void)screenCaptureTick{
    float width = [NSScreen mainScreen].frame.size.width;
    float height = [NSScreen mainScreen].frame.size.height;
    
    
    /*
     float r,g,b = 0;
     NSSize size = NSMakeSize(100, 100);
     float widthDivisions = 4;
     float heightDivisions = 4;
     NSArray *lePoints = [self pointsFromWidth:width height:height widthDivs:widthDivisions heightDivs:heightDivisions];
     float its = 0;
     for (NSValue *val in lePoints) {
     NSPoint p = val.pointValue;
     NSColor *c = [self colorFromRect:CGRectMake(p.x-size.width/2.0, p.y-size.height/2.0, size.width, size.height)];
     r+=c.redComponent;
     g+=c.greenComponent;
     b+=c.blueComponent;
     its++;
     }
     red = (r/its)*255;
     green = (g/its)*255;
     blue = (b/its)*255;
     */
    
    NSColor *c = [self colorFromRect:CGRectMake(width*0.0, height*0.0, width*1.0, height*1.0)];
    red = c.redComponent*255;
    green = c.greenComponent*255;
    blue = c.blueComponent*255;
    [self updateBoard];
    
}

-(NSColor *)colorFromRect:(CGRect )recTanlge{
    CGDirectDisplayID disp = (CGDirectDisplayID) [[[[NSScreen mainScreen]deviceDescription]objectForKey:@"NSScreenNumber"] intValue];
    CGImageRef first = CGDisplayCreateImageForRect(disp, recTanlge);
    
    NSImage *mage = [[NSImage alloc]initWithCGImage:first size:NSMakeSize(recTanlge.size.width, recTanlge.size.height)];
    [mage setScalesWhenResized:YES];
    
    NSImage *smallImage = [[NSImage alloc] initWithSize: NSMakeSize(1, 1)] ;
    [smallImage lockFocus];
    [mage setSize: NSMakeSize(1, 1)];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationMedium];
    [mage drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, 1, 1) operation:NSCompositeCopy fraction:1.0];
    [smallImage unlockFocus];
    
    NSRect rec = NSMakeRect(0, 0, smallImage.size.width, smallImage.size.height);
    CGImageRef ref = [smallImage CGImageForProposedRect:&rec context:nil hints:nil];
    NSBitmapImageRep *map = [[NSBitmapImageRep alloc]initWithCGImage:ref];
    NSColor *color = [map colorAtX:0 y:0];
    CFRelease(first);
    return color;
    
}

-(NSArray *)pointsFromWidth:(float)w height:(float)h widthDivs:(int)wDivs heightDivs:(int)hDivs{
    float widthAdd = w/wDivs;
    float hiteAdd = h/hDivs;
    NSMutableArray *points = [[NSMutableArray alloc]init];
    for (float y = hiteAdd; y<h; y+=hiteAdd) {
        for (float x = widthAdd; x<w; x+=widthAdd) {
            [points addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
        }
    }
    return [points copy];
    
}

-(void)fadeTick{
    
    [self updateBoard];
}

-(void)randomColorTick{
    red = arc4random()%256;
    blue = arc4random()%256;
    green = arc4random()%256;
    [self updateBoard];
}

-(void)fastSweep{
    uint8_t reed;
    uint8_t bluee;
    uint8_t greeen;
    hsv2rgb(tick/.4, 1.0, 1.0, &reed, &greeen, &bluee);
    red = reed;
    green = greeen;
    blue = bluee;
    
    tick++;
    [self updateBoard];
}

-(void)slowSweep{
    uint8_t reed;
    uint8_t bluee;
    uint8_t greeen;
    hsv2rgb(tick/20.0, 1.0, 1.0, &reed, &greeen, &bluee);
    red = reed;
    green = greeen;
    blue = bluee;
    tick++;
    [self updateBoard];
}

-(void)changeColor:(id)sender{
    [sweepTimer invalidate];
    NSColor *currentColor = [[NSColorPanel sharedColorPanel] color];
    red = floor(currentColor.redComponent*255.0);
    green = floor(currentColor.greenComponent*255.0);
    blue = floor(currentColor.blueComponent*255.0);
    [self updateBoard];
}

-(void)updateBoard{
    if (on) {
        //write RGB
       // NSLog(@"%i %i %i",red,green,blue);
        //self.window.backgroundColor = [NSColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
        uint8_t packet[8];
        packet[0] = (uint8_t)red;
        packet[1] = (uint8_t)green;
        packet[2] = (uint8_t)blue;
        AnDevice_SendBulkPacket_S(context, dev, sizeof packet, packet);
    } else {
        
    }
    
}

@end