//
//  MyLocation.h
//  ParkPlace
//
//  Created by vperis on 7/7/14.
//  Copyright (c) 2014 PERISCODE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyLocation : NSObject <MKAnnotation>

- (id)initWithName:(NSString*)name address:(NSString*)address coordinate:(CLLocationCoordinate2D)coordinate;
- (MKMapItem*)mapItem;

@end
