//
//  ViewController.m
//  iBeaconSampleCentral
//
//  Created by kakegawa.atsushi on 2013/09/25.
//  Copyright (c) 2013年 kakegawa.atsushi. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
//#import "CLBeaconRegion"

@interface ViewController () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSUUID *proximityUUID;
@property (nonatomic) CLBeaconRegion *beaconRegion;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
        NSLog(@"isMonitoringAvailable");
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        //self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"A3ECA004-9E01-D24B-C7B7-41BEB1A8B51B"];
        self.proximityUUID = [[NSUUID alloc] initWithUUIDString:  @"e2c56db5-dffb-48d2-b060-d0f5a71096e0"];
        //self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"D456894A-02F0-4CB0-8258-81C187DF45C2"];
        //self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"740C8618-8F7B-438A-9A17-E0A4F954EE41"];
        //self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"E7B4DED1-0132-E5FF-78EA-DF8DA54596DD"];
        //self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"713D0003-503E-4C75-BA94-3148F18D941E"];
        //self.proximityUUID = [[NSUUID alloc] initWithUUIDString:@"713D0002-503E-4C75-BA94-3148F18D941E"];
        
        
        self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:self.proximityUUID
                                                               identifier:@"donkeykey.cenetral"];
        [self.locationManager startMonitoringForRegion:self.beaconRegion];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"start monitoring region");
    //[self sendLocalNotificationForMessage:@"Start Monitoring Region"];
    [self.locationManager requestStateForRegion:self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSLog(@"didDetermineState");
    switch (state) {
        case CLRegionStateInside: // リージョン内にいる
            NSLog(@"CLRegionStateInside");
            if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
                [self sendLocalNotificationForMessage:@"Enter Region"];
                label.text = [NSString stringWithFormat:@"Enter Region"];
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            }
            break;
        case CLRegionStateOutside:
            NSLog(@"CLRegionStateOutside");
            break;
        case CLRegionStateUnknown:
            NSLog(@"CLRegionStateUnknown");
            label.text = [NSString stringWithFormat:@"State Unknown"];
            break;
        default:
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"enter");
    label.text = [NSString stringWithFormat:@"enter Region"];
    
    /*
     [self sendLocalNotificationForMessage:@"Enter Region"];
     
     if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
     [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
     }
     */
    //[self sendLocalNotificationForMessage:@"Enter Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSLog(@"exit");
    [self sendLocalNotificationForMessage:@"Exit Region"];
    label.text = [NSString stringWithFormat:@"Exit Region"];
    
    if ([region isMemberOfClass:[CLBeaconRegion class]] && [CLLocationManager isRangingAvailable]) {
        [self.locationManager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
    }
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    NSLog(@"did range beacons");
    if (beacons.count > 0) {
        CLBeacon *nearestBeacon = beacons.firstObject;
        
        NSString *rangeMessage;
        
        switch (nearestBeacon.proximity) {
            case CLProximityImmediate:
                rangeMessage = @"Range Immediate: ";
                break;
            case CLProximityNear:
                rangeMessage = @"Range Near: ";
                break;
            case CLProximityFar:
                rangeMessage = @"Range Far: ";
                break;
            default:
                rangeMessage = @"Range Unknown: ";
                break;
        }
        
        NSString *message = [NSString stringWithFormat:@"major:%@, minor:%@, accuracy:%f, rssi:%ld",
                             nearestBeacon.major, nearestBeacon.minor, nearestBeacon.accuracy, (long)nearestBeacon.rssi];
        //[self sendLocalNotificationForMessage:[rangeMessage stringByAppendingString:message]];
        label.text = [NSString stringWithFormat:@"RSSI:%ld",(long)nearestBeacon.rssi];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    //[self sendLocalNotificationForMessage:@"Exit Region"];
    NSLog(@"monitoring failed");
    NSLog(@"%@",error);
}

//#pragma mark - Private methods

- (void)sendLocalNotificationForMessage:(NSString *)message
{
    NSLog(@"local notification");
    //UILocalNotification *localNotification = [UILocalNotification new];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = message;
    localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:0];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //localNotification.alertBody = [NSString stringWithFormat:@"test"];
    localNotification.alertAction = @"Open";
    //localNotification.applicationIconBadgeNumber = 1;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObject:@"通知を受信しました。" forKey:@"EventKey"];
    localNotification.userInfo = infoDict;
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

@end
