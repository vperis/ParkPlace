//
//  iBeaconViewController.m
//  ParkPlace
//
//  Created by vperis on 9/10/14.
//  Copyright (c) 2014 PERISCODE. All rights reserved.
//

#import "iBeaconViewController.h"
#import "ParkPlace.h"

@interface iBeaconViewController ()

@end


NSString * estimoteUUIDstr = @"B9407F30-F5F8-466E-AFF9-25556B57FE6D";  // estimote UUID
CLBeaconMajorValue myBeaconMajor = 49914;
CLBeaconMinorValue myBeaconMinor = 9023;


@implementation iBeaconViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.beaconLocationManager = [[CLLocationManager alloc] init];
    self.beaconLocationManager.delegate = self;
    self.beaconFoundLabel.text = @"No Beacon Found";
    [self initRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Failed monitoring region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"Location manager failed: %@", error);
}

- (void)initRegion {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:estimoteUUIDstr]; // Estimote UUID
    
    self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:uuid
                                                                major: myBeaconMajor
                                                                minor: myBeaconMinor
                                                           identifier:@"ParkPlace beacon"];
    
    self.beaconRegion.notifyEntryStateOnDisplay = YES;
    
    if ([CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]]) {
        [self.beaconLocationManager startMonitoringForRegion:self.beaconRegion];
        MyLog(@"CLBeaconRegion monitoring is started");

        [self.beaconLocationManager startRangingBeaconsInRegion:self.beaconRegion]; // this is added for quicker detection
        
        MyLog(@"CLBeaconRegion ranging is started");

    }
    else {
        NSLog(@"CLBeaconRegion monitoring not available");
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]] ) {
        [self.beaconLocationManager startRangingBeaconsInRegion:self.beaconRegion];
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if ([region isKindOfClass:[CLBeaconRegion class]] ) {
        [self.beaconLocationManager stopRangingBeaconsInRegion:self.beaconRegion];
        self.beaconFoundLabel.text = @"No Beacon Found";
        
        UILocalNotification *notification = [[UILocalNotification alloc] init];
        notification.alertBody = @"Are you forgetting something?";
        notification.soundName = @"Default";
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];

    }
}


-(void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    CLBeacon *beacon = [[CLBeacon alloc] init];
    beacon = [beacons lastObject];

//    if ([self.proximityUUIDLabel.text isEqualToString:estimoteUUIDstr]) {
        self.beaconFoundLabel.text = @"Found my Estimote";
        self.proximityUUIDLabel.text = beacon.proximityUUID.UUIDString;
//    }
    self.majorLabel.text = [NSString stringWithFormat:@"Major: %@", beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"Minor: %@", beacon.minor];
    self.accuracyLabel.text = [NSString stringWithFormat:@"Accuracy: %f", beacon.accuracy];
    if (beacon.proximity == CLProximityUnknown) {
        self.distanceLabel.text = @"Unknown Proximity";
    } else if (beacon.proximity == CLProximityImmediate) {
        self.distanceLabel.text = @"Location: Immediate";
    } else if (beacon.proximity == CLProximityNear) {
        self.distanceLabel.text = @"Location: Near";
    } else if (beacon.proximity == CLProximityFar) {
        self.distanceLabel.text = @"Location: Far";
    }
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %li", (long) beacon.rssi];
}





/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)tappedReturn:(id)sender {
    
    [self dismissModalViewControllerAnimated: YES];

}
@end
