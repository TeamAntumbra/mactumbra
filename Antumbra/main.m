//
//  main.m
//  Antumbra
//
//  Created by Nick Peretti on 6/26/14.
//  Copyright (c) 2014 Antumbra. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, const char * argv[])
{
    [[NSUserDefaults standardUserDefaults] setVolatileDomain:@{@"AppleAquaColorVariant": @6} forName:NSArgumentDomain];
    return NSApplicationMain(argc, argv);
}
//(;