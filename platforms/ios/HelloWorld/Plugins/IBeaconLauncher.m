#import "Cordova/CDV.h"
#import "IBeaconLauncher.h"

@implementation IBeaconLauncher
@synthesize beaconManager;

- (void) launch:(CDVInvokedUrlCommand*)command {
    NSLog(@"Hello, this is a native function called from PhoneGap/Cordova!");
    beaconManager = [[IBeaconManager alloc]
                     init: @"00000000-8E5B-1001-B000-001C4DB3DB2C"
                     Identifier: @"com.ntt.webcore"];
    beaconManager.delegate = self;
}

@end