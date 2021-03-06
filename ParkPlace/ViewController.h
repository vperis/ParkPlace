//
//  ViewController.h
//  ParkPlace
//
//  Created by vperis on 7/7/14.
//  Copyright (c) 2014 PERISCODE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>



@interface ViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate>{
    BOOL _doneInitialZoom;
}

@property (strong, nonatomic) CLBeaconRegion *beaconRegion;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@property (weak, nonatomic) IBOutlet UILabel *totalDIstanceLabel;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)refreshTapped:(id)sender;

- (IBAction)parkTapped:(id)sender;

- (IBAction)parkDistance:(id)sender;

- (IBAction)clearParkDistance:(id)sender;


@end


