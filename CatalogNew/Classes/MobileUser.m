//
//  MobileUser.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 21.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "MobileUser.h"
#import "DBController.h"

@implementation MobileUser


- (id)initWithMuId: (int)mu_id
{
    DBController* DBC = [[DBController alloc] init];
    self = [super init];
    if (self) {
        NSDictionary* mudata = [DBC getMobileUser:mu_id];
        NSDictionary* data = [mudata objectForKey:@"mobile_user"];
        self.mu_id = [NSNumber numberWithInt:[[data objectForKey:@"id"] intValue]];
        self.token = [data objectForKey:@"token"];
        self.device_id = [data objectForKey:@"device_id"];
        self.fav_ishues = [[NSMutableDictionary alloc] init];
        self.fav_pages = [[NSMutableDictionary alloc] init];
        self.location = nil;
    }
    return self;
}


-(void)updateUserLocation: (CLLocation *)locationNew {
    
    DBController* DBC = [[DBController alloc] init];
    CLLocationDistance meters = [locationNew distanceFromLocation:self.location];
    self.location = locationNew;
    if( meters > 20.0 || meters < 0 ){
        [DBC addLog:[self.mu_id intValue] action:1 param1:[NSString stringWithFormat:@"%f", locationNew.coordinate.latitude]
             param2:[NSString stringWithFormat:@"%f", locationNew.coordinate.longitude]];
    }
}



-(void)updateUserToken: (NSString*)token appId:(int)appId {
    DBController* DBC = [[DBController alloc] init];
    self.token = token;
    [DBC setMobileUserToken:[self.mu_id intValue] token:token appId:appId];
}


@end
