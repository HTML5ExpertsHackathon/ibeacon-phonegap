#import "Cordova/CDV.h"
#import "IBeaconLauncher.h"

@implementation IBeaconLauncher
@synthesize beaconManager;

- (void) launch:(CDVInvokedUrlCommand*)command {
    NSLog(@"Hello, this is a native function called from PhoneGap/Cordova!");
    beaconManager = [[IBeaconManager alloc]
                     init: @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"
                     Identifier: @"com.ntt.webcore"];
    beaconManager.delegate = self;
}

@end