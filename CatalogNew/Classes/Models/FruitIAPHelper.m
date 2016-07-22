//
//  FruitIAPHelper.m
//  CatalogNew
//
//  Created by Marcin Niedźwiecki on 05.03.2014.
//  Copyright (c) 2014 Marcin Niedźwiecki. All rights reserved.
//

#import "FruitIAPHelper.h"
static NSString *kIdentifierApple       = @"de.tum.in.www1.sgdws13.BuyFruit.Apple";
static NSString *kIdentifierBlackberry  = @"de.tum.in.www1.sgdws13.BuyFruit.Blackberry";
static NSString *kIdentifierOrange      = @"de.tum.in.www1.sgdws13.BuyFruit.Orange";
static NSString *kIdentifierPear        = @"de.tum.in.www1.sgdws13.BuyFruit.Pear";
static NSString *kIdentifierTomato      = @"de.tum.in.www1.sgdws13.BuyFruit.Tomato";


@implementation FruitIAPHelper


+ (FruitIAPHelper *)sharedInstance {
    static FruitIAPHelper *sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSSet *productIdentifiers = [NSSet setWithObjects:
                                     kIdentifierApple,
                                     kIdentifierBlackberry,
                                     kIdentifierOrange,
                                     kIdentifierPear,
                                     kIdentifierTomato,
                                     nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}


@end
