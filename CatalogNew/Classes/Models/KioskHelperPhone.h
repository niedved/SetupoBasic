//
//  KioskHelper.h
//  SetupoBankowaPhone
//
//  Created by Marcin Niedźwiecki on 03.03.2015.
//  Copyright (c) 2015 Marcin Niedźwiecki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ViewController.h"

@interface KioskHelper : NSObject


+(CGRect)getBannerSize;

+(void)setColorsFromPlist: (ViewController*)viewController;
+(void)setKioskLargeIpadLandscape: (ViewController*)viewController;
+(void)setKioskLargeIpadPortrait: (ViewController*)viewController;
+(void)setTopBarViewInfoIpadPortrait: (ViewController*)viewController;
+(void)setTopBarViewInfoIpadLand: (ViewController*)viewController;


+(void)setKioskLargeOfflineIphone: (ViewController*)viewController;
+(void) setTopBarViewInfoIphoneLand: (ViewController*)viewController;
+(void) setCollectionViewInfoIphoneLandscape: (ViewController*)viewController;



+(void) setCollectionViewInfoIphonePortrait: (ViewController*)viewController;

+(UIButton*)preapreBannerButton: (ViewController*)viewController;
@end
