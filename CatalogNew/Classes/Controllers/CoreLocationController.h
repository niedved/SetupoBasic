//
//  CoreLocationController.h
//  Opolgraf
//
//  Created by Marcin Niedźwiecki on 21.06.2012.
//  Copyright (c) 2012 XCITY Game Development Studio. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

//We will declare a new protocol that will allow anything using our class to adhere to and receive updated Core Location data. For that, we use the following code placed above our interface declaration and below our imports:
@protocol CoreLocationControllerDelegate 
@required
- (void)locationUpdate:(CLLocation *)location; // Our location updates are sent here
- (void)locationError:(NSError *)error; // Any errors are sent here
@end


//Now we must define our class and make it adhere to the CLLocationManagerDelegate protocol:
@interface CoreLocationController : NSObject <CLLocationManagerDelegate> {
	CLLocationManager *locMgr;
//	id delegate;
}

@property (nonatomic, retain) CLLocationManager *locMgr;
@property (nonatomic, assign) id delegate;

@end

//We define an instance variable of CLLocationManager type named locMgr.
//Apple’s description of CLLocationManager:
//The CLLocationManager class defines the interface for configuring the delivery of location- and heading-related events to your application. You use an instance of this class to establish the parameters that determine when location and heading events should be delivered and to start and stop the actual delivery of those events. You can also use a location manager object to retrieve the most recent location and heading data.
//We also define “delegate” if type “id” which allows any class implementing our 
//CoreLocationControllerDelegate protocol to register itself as the delegate.