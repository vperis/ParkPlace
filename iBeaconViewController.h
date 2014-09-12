//
//  iBeaconViewController.h
//  ParkPlace
//
//  Created by vperis on 9/10/14.
//  Copyright (c) 2014 PERISCODE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSInteger displayMode;
extern NSInteger displayView;

@interface iBeaconViewController : UIViewController <CLLocationManagerDelegate>


- (IBAction)tappedReturn:(id)sender;

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSDictionary *beaconPeripheralData;
@property (strong, nonatomic) CLLocationManager *beaconLocationManager;


@property (weak, nonatomic) IBOutlet UILabel *beaconFoundLabel;
@property (weak, nonatomic) IBOutlet UILabel *proximityUUIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *majorLabel;
@property (weak, nonatomic) IBOutlet UILabel *minorLabel;
@property (weak, nonatomic) IBOutlet UILabel *accuracyLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end
