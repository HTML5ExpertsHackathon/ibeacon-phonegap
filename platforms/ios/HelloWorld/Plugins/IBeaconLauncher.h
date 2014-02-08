#import <Cordova/CDVPlugin.h>
#import "Foundation/Foundation.h"
#import "IBeaconManager.h"

@interface IBeaconLauncher : CDVPlugin<IBeaconManagerProtocol> {
}

@property (retain) IBeaconManager *beaconManager;
- (void) launch:(CDVInvokedUrlCommand*)command;

@end