//
//  IBeaconManager.m
//  iBeacon-Sample
//
//  Created by Toshiya Nakakura on 2/6/14.
//  Copyright (c) 2014 Toshiya Nakakura. All rights reserved.
//

#import "IBeaconManager.h"

@implementation IBeaconManager
@synthesize locationManager;
@synthesize proximityUUID;
@synthesize beaconRegion;
@synthesize delegate;

- (id) init: (NSString*) uuid Identifier: (NSString*) identifier{
    self = [super init];
    if ( self ) {
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            self.locationManager = [CLLocationManager new];
            self.locationManager.delegate = self;
            
            self.proximityUUID = [[NSUUID alloc] initWithUUIDString: uuid];
            
            self.beaconRegion = [[CLBeaconRegion alloc]
                                 initWithProximityUUID:self.proximityUUID
                                 identifier: identifier];
            self.beaconRegion.notifyEntryStateOnDisplay = YES; // 画面起動時にチェック
            [self.locationManager startMonitoringForRegion:self.beaconRegion];
        }
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"start monitoring");
    [self.locationManager requestStateForRegion:self.beaconRegion];
    [self sendLocalNotificationForMessage:@"Start Monitoring Region"];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"enter region");
    [self sendLocalNotificationForMessage:@"Enter Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    NSLog(@"exit region");
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    [self sendLocalNotificationForMessage:@"Exit Region"];
    NSLog(@"exit region");
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    switch (state) {
        case CLRegionStateInside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            break;
        case CLRegionStateOutside:
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
            }
        case CLRegionStateUnknown:
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if (beacons.count > 0) {
        int counter = 0;
        displayMessage = @"";
        NSArray *sortedBeacons = [beacons sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            CLBeacon *item1 = obj1;
            CLBeacon *item2 = obj2;
            
            if(item1.proximity < item2.proximity) return NSOrderedAscending;
            else if(item1.proximity > item2.proximity) return NSOrderedAscending;
            
            if(item1.major < item2.major) return NSOrderedAscending;
            else if(item1.major > item2.major) return NSOrderedDescending;
            else{
                if(item1.minor < item2.minor) return NSOrderedAscending;
                else if(item1.minor > item2.minor) return NSOrderedDescending;
                else return NSOrderedSame;
            }
        }];
        
        for (CLBeacon *beacon in sortedBeacons){
            NSLog(@"%d 個めのbeacon", counter);
            counter++;
            NSString *rangeMessage;
            
            switch (beacon.proximity) {
                case CLProximityImmediate:
                    NSLog(@"immediate");
                    rangeMessage = @"immediate";
                    break;
                case CLProximityNear:
                    NSLog(@"near");
                    rangeMessage = @"near";
                    break;
                case CLProximityFar:
                    NSLog(@"far");
                    rangeMessage = @"far";
                    break;
                default:
                    NSLog(@"unknown");
                    rangeMessage = @"unknown";
                    break;
            }
            
            [self sendPostMessage: beacon proximity: rangeMessage];
            NSString *message = [NSString stringWithFormat:@"UUID:%@ range: %@ major:%@, minor:%@, accuracy:%f, rssi:%ld\n",
                                 beacon.proximityUUID,
                                 rangeMessage,
                                 beacon.major,
                                 beacon.minor,
                                 beacon.accuracy,
                                 beacon.rssi];
            displayMessage = [displayMessage stringByAppendingString: message];
        }

        NSLog(@"%@", displayMessage);
//        [delegate display: displayMessage];
    }
}

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    UILocalNotification *localNotification = [UILocalNotification new];
    localNotification.alertBody = message;
    localNotification.fireDate = [NSDate date];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (void)sendPostMessage: (CLBeacon*)beacon proximity: (NSString*)proximity{
    NSString *uuid = [[beacon.proximityUUID UUIDString] stringByReplacingOccurrencesOfString: @"-" withString: @""];
    NSString *query = [NSString stringWithFormat:@"uuid=%@&major=%d&minor=%d&rssi=%ld&accuracy=%f&proximity=%@&id=phonegap-iPhone",
                       uuid, [beacon.major intValue], [beacon.minor intValue], beacon.rssi, beacon.accuracy, proximity];
    NSData *queryData = [query dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *url = @"http://html5-export-hackathon-ibeacon.herokuapp.com/";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:queryData];
    
    NSURLResponse *response;
    NSError *error;
    
    [NSURLConnection sendSynchronousRequest:request
                          returningResponse:&response
                                      error:&error];
}

@end

