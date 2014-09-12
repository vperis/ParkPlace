//
//  ViewController.m
//  ParkPlace
//
//  Created by vperis on 7/7/14.
//  Copyright (c) 2014 PERISCODE. All rights reserved.
//

#import "ViewController.h"
#import "MyLocation.h"
#import "ParkPlace.h"



NSString * clickDescription = @"Click Here";
NSString * address = @"to get directions";

static CLLocationCoordinate2D staticCoordinate;
static CLLocationCoordinate2D lastParkCoordinate;

NSInteger displayMode = INIT_VIEW;
NSInteger displayView = MINUS_VIEW;

static NSDate *backgroundTimeOut;



@implementation ViewController {
    CLLocationManager *locationManager;
    NSMutableArray  *locationHistory;
    CLLocation *lastRecordedLocation;
    NSTimeInterval lastDistanceCalculation;
    CLLocationDistance totalDistance;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //show the users location
    _mapView.showsUserLocation = YES;
    
	// Do any additional setup after loading the view, typically from a nib.
    
    staticCoordinate.latitude = START_LATITUDE;
    staticCoordinate.longitude = START_LONGITUDE;
    
    // setup the label font

    [self.distanceLabel setFont:[UIFont fontWithName:@"American Typewriter" size:40]];
    [self.totalDIstanceLabel setFont:[UIFont fontWithName:@"American Typewriter" size:40]];

    
    // setup the label text
    self.distanceLabel.text = @"";
    self.totalDIstanceLabel.text = @"";
    
    locationHistory = [NSMutableArray arrayWithCapacity:kNumLocationHistoriesToKeep];
    lastRecordedLocation = nil;
    lastDistanceCalculation = 0;
    totalDistance = 0;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
 
    [locationManager startUpdatingLocation];
    

}




// do not change orientation with rotation
-(BOOL)shouldAutorotate
{
    return NO;
}



#pragma mark - CLLocationManager

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    MyLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    MyLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    staticCoordinate.latitude = currentLocation.coordinate.latitude;
    staticCoordinate.longitude = currentLocation.coordinate.longitude;
    
    // since the oldLocation might be from some previous use of core location, we need to make sure we're getting data from this run
    if (oldLocation == nil) return;
    
   // [self.delegate locationManagerDebugText:[NSString stringWithFormat:@"accuracy: %.2f", newLocation.horizontalAccuracy]];
    
    if (newLocation.horizontalAccuracy >= 0.0f && newLocation.horizontalAccuracy < kRequiredHorizontalAccuracy) {
        
        [locationHistory addObject:newLocation];
        if ([locationHistory count] > kNumLocationHistoriesToKeep) {
            [locationHistory removeObjectAtIndex:0];
        }
        
        BOOL canUpdateDistance = NO;
        if ([locationHistory count] >= kMinLocationsNeededToUpdateDistance) {
            canUpdateDistance = YES;
        }
        
        if ([NSDate timeIntervalSinceReferenceDate] - lastDistanceCalculation > kDistanceCalculationInterval) {
            lastDistanceCalculation = [NSDate timeIntervalSinceReferenceDate];
            
            CLLocation *lastLocation = (lastRecordedLocation != nil) ? lastRecordedLocation : oldLocation;
            
            CLLocation *bestLocation = nil;
            CGFloat bestAccuracy = kRequiredHorizontalAccuracy;
            for (CLLocation *location in locationHistory) {
                if ([NSDate timeIntervalSinceReferenceDate] - [location.timestamp timeIntervalSinceReferenceDate] <= kValidLocationHistoryDeltaInterval) {
                    if (location.horizontalAccuracy < bestAccuracy && location != lastLocation) {
                        bestAccuracy = location.horizontalAccuracy;
                        bestLocation = location;
                    }
                }
            }
            if (bestLocation == nil) bestLocation = newLocation;
            
            CLLocationDistance distance = [bestLocation distanceFromLocation:lastLocation];
            if (canUpdateDistance) totalDistance += distance;
            lastRecordedLocation = bestLocation;
        }
    }
    
    
    switch (displayMode)
    
    {
         
        case INIT_VIEW:
        {
            
            // clear displayMode flag
            displayMode = 0;
            
            //calculate the view Region to display
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate,
                                                                               VIEW_REGION1 * METERS_PER_MILE,
                                                                               VIEW_REGION1 * METERS_PER_MILE);
            
            //set the view region
            [_mapView setRegion:viewRegion animated:YES];
            
            
            // This should set the tracking mode, but doesn't seem to work for me
            [_mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
            
        }
            
            break;
            
        case DROP_PIN:
        
        {
            //clear displayMode flag
            displayMode = PIN_ON_MAP;
            
            // save the last parked co-ordinate so we can get the distance later
            lastParkCoordinate = staticCoordinate;
            
            // Setup a label to place on the pin
            
            // Get current datetime
            NSDate *currentDateTime = [NSDate date];
            
            
            backgroundTimeOut = [NSDate dateWithTimeInterval:kSecondsInTimeLimit
                                                         sinceDate:currentDateTime];
            
            // Instantiate a NSDateFormatter
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            // Set the dateFormatter format
            [dateFormatter setDateFormat:@"hh:mm a"];
            
            // Get the date time in NSString
            NSString *dateInString = [dateFormatter stringFromDate:currentDateTime];
            
            
            NSString * clickDescription = [NSString stringWithFormat:@"%@", dateInString];
            NSString * address = @"I was here";
            
            
            MyLocation *annotation = [[MyLocation alloc] initWithName:clickDescription
                                                              address:address
                                                           coordinate:currentLocation.coordinate] ;
            
            [_mapView addAnnotation:annotation];
            
            //calculate the view Region to display
            MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate,
                                                                               VIEW_REGION1 * METERS_PER_MILE,
                                                                               VIEW_REGION1 * METERS_PER_MILE);
            
            //set the view region
            [_mapView setRegion:viewRegion animated:YES];
            
            
        }
        
            break;

            
        default:
            
            break;
    }
    
    
    if ( displayView == PLUS_VIEW ) {
        
        if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive) {
            
            MyLog(@"Location update received in active state");


        
            CLLocation *location1 = [[CLLocation alloc] initWithLatitude:lastParkCoordinate.latitude
                                                               longitude:lastParkCoordinate.longitude];
            CLLocation *location2 = [[CLLocation alloc] initWithLatitude:staticCoordinate.latitude
                                                               longitude:staticCoordinate.longitude];
            
            
            CLLocationDistance distance = [location1 distanceFromLocation:location2];
            
            //print the label
            self.distanceLabel.text = [NSString stringWithFormat:@" d:%4.0f m", distance];
            self.totalDIstanceLabel.text = [NSString stringWithFormat:@"td:%4.0f m", totalDistance];
        }
        
        NSComparisonResult result = [currentLocation.timestamp compare:backgroundTimeOut];
        
        if (result == NSOrderedDescending) {
            MyLog(@"Background update of location stopped");
            //stop location updates
            [locationManager stopUpdatingLocation];
        }
        
    }
    else {
        //stop location updates
        [locationManager stopUpdatingLocation];
    }

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {

    //1
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(staticCoordinate,
                                                                       VIEW_REGION100 * METERS_PER_MILE,
                                                                       VIEW_REGION100 * METERS_PER_MILE);
    
    //2
    [_mapView setRegion:viewRegion animated:YES];
    
    
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[MyLocation class]]) {
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"arrest.png"];//here we use a nice image instead of the default pins
            // Add to mapView:viewForAnnotation: after setting the image on the annotation view
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}



// Launches the Map tool to give the driving directions
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
   MyLocation *location = (MyLocation*)view.annotation;
    

    
    // make a note of the parking placemark
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate
                                                   addressDictionary:nil];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    [mapItem setName:@"Parking Place"];
    
    // Set the directions mode to "Walking"
    // Can use MKLaunchOptionsDirectionsModeDriving instead
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
    
    // Get the "Current User Location" MKMapItem
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    
    
    // Pass the current location and destination map items to the Maps app
    // Set the direction mode in the launchOptions dictionary
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                   launchOptions:launchOptions];
    
    
}



#pragma mark - Button Actions


// Clears the pins that have been placed on the map
- (IBAction)refreshTapped:(id)sender {
    
    displayMode = 0;
    displayView = -1;
    
    // clear the label text
    self.distanceLabel.text = @"";
    self.totalDIstanceLabel.text = @"";

    
    for (id<MKAnnotation> annotation in _mapView.annotations) {
        [_mapView removeAnnotation:annotation];
    }
    
    //stop updating location to save battery
    [locationManager stopUpdatingLocation];
    


}

// Start the location Update methods, which will ultimately trigger didUpdateToLocation()

- (IBAction)parkTapped:(id)sender {
    
    displayMode = DROP_PIN;
    
    MyLog(@"Touched the Park button");

    [locationManager startUpdatingLocation];
    
    
    
}

- (IBAction)parkDistance:(id)sender {
    
    MyLog(@"Touched the plus sign");
    
    if (displayMode == PIN_ON_MAP) {
        
        displayView = PLUS_VIEW;
    
        [locationManager startUpdatingLocation];
    }

    
}

- (IBAction)clearParkDistance:(id)sender {
    
    // clear the displayView flag
    displayView = -1;
    
    MyLog(@"Touched the minus sign");

    // clear the label text
    self.distanceLabel.text = @"";
    self.totalDIstanceLabel.text = @"";

    
    // no need to update location anymore
    [locationManager stopUpdatingLocation];
    

}



@end


//// Replace refreshTapped as follows
//- (IBAction)refreshTapped:(id)sender {
//    
//    // 1
//    MKCoordinateRegion mapRegion = [_mapView region];
//    CLLocationCoordinate2D centerLocation = mapRegion.center;
//    
//    // 2
//    NSString *jsonFile = [[NSBundle mainBundle] pathForResource:@"command" ofType:@"json"];
//    NSString *formatString = [NSString stringWithContentsOfFile:jsonFile encoding:NSUTF8StringEncoding error:nil];
//    NSString *json = [NSString stringWithFormat:formatString,
//                      centerLocation.latitude,
//                      centerLocation.longitude,
//                      0.5*METERS_PER_MILE];
//    
//    // 3
//    NSURL *url = [NSURL URLWithString:@"https://data.baltimorecity.gov/api/views/INLINE/rows.json?method=index"];
//    
//    // 4
//    ASIHTTPRequest *_request = [ASIHTTPRequest requestWithURL:url];
//    __weak ASIHTTPRequest *request = _request;
//    
//    request.requestMethod = @"POST";
//    [request addRequestHeader:@"Content-Type" value:@"application/json"];
//    [request appendPostData:[json dataUsingEncoding:NSUTF8StringEncoding]];
//    // 5
//    [request setDelegate:self];
//    [request setCompletionBlock:^{
//        NSString *responseString = [request responseString];
//        NSLog(@"Response: %@", responseString);
//        [self plotCrimePositions:request.responseData];
//    }];
//    [request setFailedBlock:^{
//        NSError *error = [request error];
//        NSLog(@"Error: %@", error.localizedDescription);
//    }];
//    
//    // 6
//    [request startAsynchronous];
//    
//}


// < start comment - VP> Commented out the following as I changed the function of refresh

// Add new method above refreshTapped
//- (void)plotCrimePositions:(NSData *)responseData {
//    for (id<MKAnnotation> annotation in _mapView.annotations) {
//        [_mapView removeAnnotation:annotation];
//    }
//
// I commented out the lines below since they weren't doing anything

//  NSDictionary *root = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
//  NSArray *data = [root objectForKey:@"data"];
//
//    for (NSArray *row in data) {
//        NSNumber * latitude = [[row objectAtIndex:17]objectAtIndex:1];
//        NSNumber * longitude = [[row objectAtIndex:17]objectAtIndex:2];
//        NSString * crimeDescription = [row objectAtIndex:12];
//        NSString * address = [row objectAtIndex:11];
//
//        CLLocationCoordinate2D coordinate;
//        coordinate.latitude = latitude.doubleValue;
//        coordinate.longitude = longitude.doubleValue;
//        MyLocation *annotation = [[MyLocation alloc] initWithName:crimeDescription address:address coordinate:coordinate] ;
//        [_mapView addAnnotation:annotation];
//	}


//}
// < end comment -- VP >





