//
//  MobileUser.h
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 21.01.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocationController.h"

@interface MobileUser : NSObject


@property (nonatomic, strong, readwrite) NSNumber *mu_id;
@property (nonatomic, strong, readwrite) NSString *token;
@property (nonatomic, strong, readwrite) NSNumber *device_id;
@property (nonatomic, strong, readwrite) NSMutableDictionary *fav_ishues;
@property (nonatomic, strong, readwrite) NSMutableDictionary *fav_pages;
@property (nonatomic, strong, readwrite) CLLocation *location;


- (id)initWithMuId: (int)mu_id;
-(void)updateUserLocation: (CLLocation *)location;
-(void)updateUserToken: (NSString*)token appId:(int)appId;
@end
