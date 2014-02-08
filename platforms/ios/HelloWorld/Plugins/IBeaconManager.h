//
//  IBeaconManager.h
//  iBeacon-Sample
//
//  Created by Toshiya Nakakura on 2/6/14.
//  Copyright (c) 2014 Toshiya Nakakura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Cordova/CDVPlugin.h>
#import "IBeaconManager.h"

@protocol IBeaconManagerProtocol
- (void) display: (NSString*)message;
@end

@interface IBeaconManager : NSObject<IBeaconManagerProtocol>{
    NSString *displayMessage;
}

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@property (nonatomic) id<IBeaconManagerProtocol> delegate;

- (id) init: (NSString*) uuid Identifier: (NSString*) identifier;

@end

