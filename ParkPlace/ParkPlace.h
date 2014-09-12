//
//  ParkPlace.h
//  ParkPlace
//
//  Created by vperis on 9/11/14.
//  Copyright (c) 2014 PERISCODE. All rights reserved.
//

#ifndef ParkPlace_ParkPlace_h
#define ParkPlace_ParkPlace_h

#define NDEBUG

// use NSLog only when I am doing debug builds, else skip
#ifdef NDEBUG
// do nothing
#define MyLog(...)
#else
#define MyLog NSLog
#endif

#define METERS_PER_MILE 1609.344

#define START_LATITUDE 37.327795
#define START_LONGITUDE -122.065158

// view Region that is 1 Mile x 1 Mile wide has value 0.5
#define VIEW_REGION1 0.5
#define VIEW_REGION100 500

// define display operations when there is motion

#define INIT_VIEW 1
#define DROP_PIN 2
#define PIN_ON_MAP 3

#define MINUS_VIEW -1
#define PLUS_VIEW 1


// definitions for calculations of distance
#define kDistanceCalculationInterval 5 // the interval (seconds) at which we calculate the user's distance
#define kNumLocationHistoriesToKeep 5 // the number of locations to store in history so that we can look back at them and determine which is most accurate
#define kValidLocationHistoryDeltaInterval 10 // the maximum valid age in seconds of a location stored in the location history
#define kMinLocationsNeededToUpdateDistance 3 // the number of locations needed in history before we will even update the current distance
#define kRequiredHorizontalAccuracy 40.0f // the required accuracy in meters for a location.  anything above this number will be discarded
#define kSecondsInTimeLimit 2 * 60 * 60 // #seconds in 2 hours
//#define kSecondsInTimeLimit 30 // #seconds in half a minute -- for DEBUG only




#endif
